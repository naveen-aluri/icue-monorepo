import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/expense_type.dart';
import '../../../models/vehicle.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/vehicle_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/injectable.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/dropdown.dart';
import '../../../widgets/file_upload_widget.dart';
import '../../../widgets/inputfield.dart';

class AddFuelExpensePage extends StatefulWidget {
  const AddFuelExpensePage({
    super.key,
    required this.expenseType,
    required this.vehicle,
    required this.mode,
  });

  final ExpenseType expenseType;
  final String mode;
  final Vehicle vehicle;

  @override
  State<AddFuelExpensePage> createState() => _AddFuelExpensePageState();
}

class _AddFuelExpensePageState extends State<AddFuelExpensePage> {
  DateTime? billDate = DateTime.now();
  XFile? odometerFile, billFile;
  String? currentKms,
      fuelLiters,
      status,
      billNo,
      price,
      vendorName,
      description;

  final TextEditingController _dateController = TextEditingController(
    text: DateTime.now().formattedGatePassDate(),
  );

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'add-fuel-expense-page',
      parameters: {
        'expenseType': widget.expenseType.expenseType,
        'mode': widget.mode,
        'vehicleNumber': widget.vehicle.number,
      },
    );
    _priceController.text = widget.vehicle.price ?? '';
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        status = widget.mode == 'SelfFilling' ? 'UnBilled' : 'Billed';
      });
    });
  }

  Future<void> onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (odometerFile == null) {
        AppUtils.showErrorMessage(context, 'Please upload Odometer readings!');
        return;
      }
      if (status != 'UnBilled' && billFile == null) {
        AppUtils.showErrorMessage(context, 'Please upload Bill!');
        return;
      }

      final mapData = {
        'VehicleNumber': widget.vehicle.number,
        'KM': currentKms,
        'FuelFilled': fuelLiters,
        'ExpenseType': widget.expenseType.expenseType.toString(),
        'FuelType': widget.vehicle.fuelType,
        'Status': status,
        'BillDate': billDate.formattedGatePassDate(),
        'Mode': widget.mode,
        'BillNo': billNo,
        'VendorName': vendorName,
        'ExpenseDesc': description,
      };

      final result =
          widget.vehicle.price == _priceController.text ||
          await Provider.of<VehicleProvider>(
            context,
            listen: false,
          ).updateFuelPrice(
            context: context,
            fuelType: widget.vehicle.fuelType,
            price: _priceController.text,
          );

      if (result) {
        await Provider.of<ExpenseProvider>(context, listen: false).storeExpense(
          context: context,
          data: mapData,
          odometerFile: odometerFile,
          billFile: billFile,
          expenseType: widget.expenseType,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fill Fuel')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              InputField(
                key: const Key('Current Fuel Price'),
                initialValue: price,
                label: 'Current Fuel Price',
                controller: _priceController,
                isRequired: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffix: '₹',
                filled: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),
              InputField(
                key: const Key('Current KMS Reading'),
                label: 'Current KMS Reading',
                initialValue: currentKms,
                isRequired: true,
                keyboardType: TextInputType.number,
                suffix: 'KMS',
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                ],
                filled: false,
                onSaved: (val) => currentKms = val,
              ),
              const SizedBox(height: 16),
              InputField(
                key: const Key('Fuel Filled'),
                label: 'Fuel Filled',
                initialValue: fuelLiters,
                isRequired: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                suffix: 'Liters',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                filled: false,
                onSaved: (val) => fuelLiters = val,
                onChanged: (val) => setState(() => fuelLiters = val),
              ),
              ...((fuelLiters != null &&
                      fuelLiters!.isNotEmpty &&
                      _priceController.text.isNotEmpty)
                  ? [
                      const SizedBox(height: 10),
                      Text(
                        'Total Amount: ${((num.tryParse(fuelLiters!) ?? 0) * num.tryParse(_priceController.text)!).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ]
                  : []),
              const SizedBox(height: 16),
              FileUploadWidget(
                title: 'Upload Odometer',
                file: odometerFile,
                onDelete: () {
                  setState(() => odometerFile = null);
                },
                onFilePick: (xfile, _) {
                  setState(() => odometerFile = xfile);
                },
              ),
              const SizedBox(height: 16),
              Dropdown(
                key: const Key('Status'),
                title: 'Status',
                showTitle: true,
                value: status,
                required: true,
                onChanged: (val) {
                  setState(() {
                    status = val;
                    if (val == 'UnBilled') {
                      billNo = null;
                      billFile = null;
                    }
                  });
                },
                items: getDropDownMenuItems(
                  null,
                  [
                    'UnBilled',
                    'Billed',
                    'Paid',
                  ].map((e) => MenuItem(id: e, name: e)).toList(),
                ),
              ),
              const SizedBox(height: 16),
              InputField(
                key: const Key('Bill Date'),
                label: 'Bill Date',
                hintText: 'Select Date',
                filled: false,
                initialValue: _dateController.text,
                controller: _dateController,
                type: TextFieldType.datePicker,
                onTap: () async {
                  billDate = await AppUtils.selectDate(
                    context: context,
                    initialDate: billDate,
                  );
                  if (billDate != null) {
                    _dateController.text =
                        billDate.formattedGatePassDate() ?? '';
                  }
                },
              ),
              ...(status == 'UnBilled'
                  ? []
                  : [
                      const SizedBox(height: 16),
                      InputField(
                        key: const Key('Bill Number'),
                        label: 'Bill Number',
                        initialValue: billNo,
                        onSaved: (val) => billNo = val,
                        filled: false,
                      ),
                      const SizedBox(height: 16),
                      FileUploadWidget(
                        title: 'Upload Bill',
                        file: billFile,
                        onDelete: () {
                          setState(() => billFile = null);
                        },
                        onFilePick: (xfile, _) {
                          setState(() => billFile = xfile);
                        },
                      ),
                    ]),
              const SizedBox(height: 16),
              InputField(
                key: const Key('Vendor Name'),
                label: 'Vendor Name',
                initialValue: vendorName,
                filled: false,
                onSaved: (val) => vendorName = val,
              ),
              const SizedBox(height: 16),
              InputField(
                key: const Key('Description'),
                label: 'Description',
                initialValue: description,
                onSaved: (val) => description = val,
                filled: false,
              ),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: onSubmit, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
