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

class AddSalaryExpensePage extends StatefulWidget {
  const AddSalaryExpensePage({
    super.key,
    required this.expenseType,
    required this.vehicle,
  });

  final ExpenseType expenseType;
  final Vehicle vehicle;

  @override
  State<AddSalaryExpensePage> createState() => _AddSalaryExpensePageState();
}

class _AddSalaryExpensePageState extends State<AddSalaryExpensePage> {
  DateTime? billDate = DateTime.now();
  String? mode, name, billNo, billAmount, status = 'UnBilled', description;
  XFile? billFile;

  final TextEditingController _billDateController = TextEditingController(
    text: DateTime.now().formattedGatePassDate(),
  );

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'add-salary-expense-page',
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
        'Mode': mode,
        'Name': name,
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
      appBar: AppBar(title: const Text('Salary Expense')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Dropdown(
                      key: const Key('mode'),
                      title: 'Mode',
                      showTitle: true,
                      value: mode,
                      required: true,
                      onChanged: (val) {
                        setState(() {
                          mode = val;
                        });
                      },
                      items: getDropDownMenuItems(
                        null,
                        widget.expenseType.modes
                            ?.map((e) => MenuItem(id: e.code, name: e.name))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InputField(
                      key: const Key('Name'),
                      label: 'Name',
                      initialValue: name,
                      filled: false,
                      isRequired: true,
                      onSaved: (val) => name = val,
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
                      isRequired: true,
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
