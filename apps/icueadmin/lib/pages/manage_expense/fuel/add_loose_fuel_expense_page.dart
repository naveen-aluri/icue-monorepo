import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/expense_type.dart';
import '../../../models/fuel_storage.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/vehicle_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/injectable.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/dropdown.dart';
import '../../../widgets/file_upload_widget.dart';
import '../../../widgets/inputfield.dart';

class AddLooseFuelExpensePage extends StatefulWidget {
  const AddLooseFuelExpensePage({
    super.key,
    required this.storageItem,
    required this.expenseType,
  });

  final ExpenseType expenseType;
  final StorageItem storageItem;

  @override
  State<AddLooseFuelExpensePage> createState() =>
      _AddLooseFuelExpensePageState();
}

class _AddLooseFuelExpensePageState extends State<AddLooseFuelExpensePage> {
  DateTime? billDate = DateTime.now();
  XFile? billFile;
  String? vendorName,
      fuelLiters,
      status = 'UnBilled',
      billNo,
      price,
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
      screenName: 'add-loose-fuel-expense-page',
    );
    _priceController.text = widget.storageItem.fuelPrice!;
  }

  Future<void> onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (status != 'UnBilled' && billFile == null) {
        AppUtils.showErrorMessage(context, 'Please upload Bill!');
        return;
      }

      final mapData = {
        'StorType': widget.storageItem.type,
        'StorName': widget.storageItem.name,
        'StorCap': widget.storageItem.capacity,
        'VendorName': vendorName,
        'FuelFilled': fuelLiters,
        'PricePerLitre': widget.storageItem.fuelPrice,
        'ExpenseType': widget.expenseType.expenseType.toString(),
        'FuelType': widget.storageItem.fuelType,
        'Status': status,
        'BillDate': billDate.formattedGatePassDate(),
        'BillNo': billNo,
        'Amount':
            num.tryParse(fuelLiters!)! *
            num.tryParse(widget.storageItem.fuelPrice!)!,
        'BillAmount':
            num.tryParse(fuelLiters!)! *
            num.tryParse(widget.storageItem.fuelPrice!)!,
        'ExpenseDesc': description,
      };

      final result =
          widget.storageItem.fuelPrice == _priceController.text ||
          await Provider.of<VehicleProvider>(
            context,
            listen: false,
          ).updateFuelPrice(
            context: context,
            fuelType: widget.storageItem.fuelType ?? '',
            price: _priceController.text,
          );
      if (result) {
        await Provider.of<ExpenseProvider>(context, listen: false).storeExpense(
          context: context,
          data: mapData,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              InputField(
                key: const Key('Vendor Name'),
                label: 'Vendor Name',
                initialValue: vendorName,
                filled: false,
                onSaved: (val) => vendorName = val,
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
                validator: (value) => value == null || value.isEmpty
                    ? 'This is required'
                    : int.tryParse(value)! > widget.storageItem.capacity
                    ? 'Fuel Filled should not be more than max capacity'
                    : null,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                filled: false,
                onSaved: (val) => fuelLiters = val,
              ),
              Text(
                '⚠️ Max capacity ${widget.storageItem.capacity} L',
                style: TextStyle(color: Colors.amber.shade700),
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
