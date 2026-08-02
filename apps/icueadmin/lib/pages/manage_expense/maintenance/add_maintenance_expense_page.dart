import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/expense_type.dart';
import '../../../models/vehicle.dart';
import '../../../providers/expense_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/hive_service.dart';
import '../../../services/injectable.dart';
import '../../../utils/app_utils.dart';
import '../../../widgets/dropdown.dart';
import '../../../widgets/file_upload_widget.dart';
import '../../../widgets/inputfield.dart';

class AddMaintenanceExpensePage extends StatefulWidget {
  const AddMaintenanceExpensePage({
    super.key,
    required this.expenseType,
    required this.vehicle,
  });

  final ExpenseType expenseType;
  final Vehicle vehicle;

  @override
  State<AddMaintenanceExpensePage> createState() =>
      _AddMaintenanceExpensePageState();
}

class _AddMaintenanceExpensePageState extends State<AddMaintenanceExpensePage> {
  DateTime? billDate = DateTime.now();
  DateTime? fixedDate = DateTime.now();
  String? subCategory,
      subCategoryName,
      categoryName,
      otherSubCategory,
      vendorName,
      odometer,
      billNo,
      billAmount,
      status = 'UnBilled',
      description;
  int? category;
  XFile? billFile;

  final TextEditingController _billDateController = TextEditingController(
    text: DateTime.now().formattedGatePassDate(),
  );

  final TextEditingController _fixedDateController = TextEditingController(
    text: DateTime.now().formattedGatePassDate(),
  );

  final _formKey = GlobalKey<FormState>();

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
        'Speedometer': odometer,
        'FixedDate': fixedDate.formattedGatePassDate(),
        'Status': status,
        'BillDate': billDate.formattedGatePassDate(),
        'BillNo': billNo,
        'BillAmount': billAmount,
        'CategoryId': category,
        'CategoryName': categoryName,
        'SubCategoryId': subCategory,
        'SubCategoryName': subCategory == 'others'
            ? otherSubCategory
            : subCategoryName,
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
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'add-maintenance-page',
      parameters: {
        'expenseType': widget.expenseType.expenseType,
        'vehicleNumber': widget.vehicle.number,
      },
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).getExpenseCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final subCategories = provider.subCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('Services & Maintenance Expense')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ValueListenableBuilder(
                valueListenable: HiveService.expenseCategorysBox.listenable(),
                builder: (context, box, _) {
                  final categories = box.values.toList();
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Dropdown<int>(
                          key: const Key('category'),
                          title: 'Category',
                          showTitle: true,
                          value: category,
                          required: true,
                          onChanged: (val) {
                            setState(() {
                              category = val;
                              categoryName = categories
                                  .firstWhere((e) => e.id == val)
                                  .name;
                              subCategory = null;
                            });
                            provider.getExpenseSubCategories(val!);
                          },
                          items: getDropDownMenuItems(
                            null,
                            categories
                                .map(
                                  (e) => MenuItem(
                                    id: e.id as int,
                                    name: e.name ?? '',
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        if (category != null) const SizedBox(height: 16),
                        if (category != null)
                          Dropdown<String>(
                            key: const Key('Sub Category'),
                            title: 'Sub Category',
                            showTitle: true,
                            value: subCategory,
                            required: true,
                            onChanged: (val) {
                              setState(() {
                                subCategory = val;
                                if (val != 'others') {
                                  subCategoryName = subCategories
                                      .firstWhere((e) => e.id == val)
                                      .name;
                                }
                              });
                            },
                            items: getDropDownMenuItems(
                              null,
                              subCategories
                                  .map(
                                    (e) => MenuItem(
                                      id: e.id as String,
                                      name: e.name ?? '',
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        if (subCategory == 'others') const SizedBox(height: 16),
                        if (subCategory == 'others')
                          InputField(
                            key: const Key('Other Sub Category'),
                            label: 'Other Sub Category',
                            initialValue: otherSubCategory,
                            filled: false,
                            isRequired: true,
                            onSaved: (val) => otherSubCategory = val,
                          ),
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
                  );
                },
              ),
            ),
    );
  }
}
