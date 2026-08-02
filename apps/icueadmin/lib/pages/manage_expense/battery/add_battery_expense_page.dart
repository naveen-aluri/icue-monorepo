import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/expense_type.dart';
import '../../../models/vehicle.dart';
import '../../../providers/expense_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/injectable.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/dropdown.dart';
import '../../../widgets/file_upload_widget.dart';
import '../../../widgets/inputfield.dart';

class AddbatteryExpensePage extends StatefulWidget {
  const AddbatteryExpensePage({
    super.key,
    required this.expenseType,
    required this.vehicle,
  });

  final ExpenseType expenseType;
  final Vehicle vehicle;

  @override
  State<AddbatteryExpensePage> createState() => _AddbatteryExpensePageState();
}

class _AddbatteryExpensePageState extends State<AddbatteryExpensePage> {
  DateTime? billDate = DateTime.now();
  XFile? billFile;
  DateTime? fixedDate = DateTime.now();
  String? vendorName,
      batteryName,
      batteryCapacity,
      batteryNumber,
      odometer,
      warranty,
      billNo,
      billAmount,
      status = 'UnBilled',
      description;

  final TextEditingController _billDateController = TextEditingController(
    text: DateTime.now().formattedGatePassDate(),
  );

  final TextEditingController _fixedDateController = TextEditingController(
    text: DateTime.now().formattedGatePassDate(),
  );

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'add-battery-expense-page',
      parameters: {
        'expenseType': widget.expenseType.expenseType,
        'vehicleNumber': widget.vehicle.number,
      },
    );
  }

  void onSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (status != 'UnBilled' && billFile == null) {
        AppUtils.showErrorMessage(context, 'Please upload Bill!');
        return;
      }

      final mapData = {
        'VehicleNumber': widget.vehicle.number,
        'ExpenseType': widget.expenseType.expenseType.toString(),
        'VendorName': vendorName,
        'BatteryName': batteryName,
        'BatteryCapacity': batteryCapacity,
        'BatteryNo': batteryNumber,
        'Speedometer': odometer,
        'Warranty': warranty,
        'FixedDate': fixedDate.formattedGatePassDate(),
        'Status': status,
        'BillDate': billDate.formattedGatePassDate(),
        'BillNo': billNo,
        'BillAmount': billAmount,
        'Amount': billAmount,
        'ExpenseDesc': description,
      };
      Provider.of<ExpenseProvider>(context, listen: false).storeExpense(
        context: context,
        data: mapData,
        billFile: billFile,
        expenseType: widget.expenseType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Battery')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    InputField(
                      key: const Key('Vendor Name'),
                      label: 'Vendor Name',
                      initialValue: vendorName,
                      filled: false,
                      onSaved: (val) => vendorName = val,
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      key: const Key('Battery Name'),
                      label: 'Battery Name',
                      initialValue: batteryName,
                      filled: false,
                      isRequired: true,
                      onSaved: (val) => batteryName = val,
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      key: const Key('Battery Capacity'),
                      label: 'Battery Capacity',
                      initialValue: batteryCapacity,
                      filled: false,
                      isRequired: true,
                      onSaved: (val) => batteryCapacity = val,
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      key: const Key('Battery Number'),
                      label: 'Battery Number',
                      initialValue: batteryNumber,
                      filled: false,
                      isRequired: true,
                      onSaved: (val) => batteryNumber = val,
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      key: const Key('Odometer'),
                      label: 'Odometer',
                      initialValue: odometer,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      suffix: 'KMS',
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                      ],
                      filled: false,
                      onSaved: (val) => odometer = val,
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      key: const Key('warranty'),
                      label: 'Warranty (In Months)',
                      initialValue: warranty,
                      isRequired: true,
                      keyboardType: TextInputType.number,
                      suffix: 'months',
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                      ],
                      filled: false,
                      onSaved: (val) => warranty = val,
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      key: const Key('Fixed Date'),
                      label: 'Fixed Date',
                      hintText: 'Select Date',
                      filled: false,
                      isRequired: true,
                      initialValue: _fixedDateController.text,
                      controller: _fixedDateController,
                      type: TextFieldType.datePicker,
                      onTap: () async {
                        fixedDate = await AppUtils.selectDate(
                          context: context,
                          initialDate: fixedDate,
                        );
                        if (fixedDate != null) {
                          _fixedDateController.text =
                              fixedDate.formattedGatePassDate() ?? '';
                        }
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
                      initialValue: _billDateController.text,
                      controller: _billDateController,
                      type: TextFieldType.datePicker,
                      onTap: () async {
                        billDate = await AppUtils.selectDate(
                          context: context,
                          initialDate: billDate,
                        );
                        if (billDate != null) {
                          _billDateController.text =
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
                      key: const Key('Amount'),
                      label: 'Amount',
                      initialValue: billAmount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      filled: false,
                      isRequired: true,
                      onSaved: (val) => billAmount = val,
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
                    ElevatedButton(
                      onPressed: onSubmit,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
