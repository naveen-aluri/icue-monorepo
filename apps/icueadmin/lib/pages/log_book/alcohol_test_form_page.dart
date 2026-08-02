import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/drivers.dart';
import '../../providers/alcohol_test_provider.dart';
import '../../providers/driver_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/file_upload_widget.dart';
import '../../widgets/inputfield.dart';

/// Helper to build a driver’s full name
String _fullName(Driver d) {
  final parts = [
    d.firstName,
    if ((d.middleName ?? '').isNotEmpty) d.middleName!,
    if ((d.lastName ?? '').isNotEmpty) d.lastName!,
  ];
  return parts.join(' ');
}

class AlcoholTestFormPage extends StatefulWidget {
  const AlcoholTestFormPage({super.key});

  @override
  State<AlcoholTestFormPage> createState() => _AlcoholTestFormPageState();
}

class _AlcoholTestFormPageState extends State<AlcoholTestFormPage> {
  static final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  );

  static final _errorBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.red),
    borderRadius: BorderRadius.circular(5),
  );

  static const _fieldPadding = EdgeInsets.all(10);

  XFile? _file;
  final _formKey = GlobalKey<FormState>();
  String? _testResult, _reading;
  Driver? _selectedDriver;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().getDrivers();
    });
  }

  void _onSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_selectedDriver == null) {
      AppUtils.showErrorMessage(context, 'Please select a driver.');
      return;
    }

    if (_testResult == 'FAIL' && _file == null) {
      AppUtils.showErrorMessage(
        context,
        'Please upload an image for failed test.',
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      context.read<AlcoholTestProvider>().submitAlcoholTestForm(
        context,
        personId: _selectedDriver!.id,
        personName: _fullName(_selectedDriver!),
        personMobile: _selectedDriver!.mobile,
        reading: num.tryParse(_reading ?? '') ?? 0.0,
        status: _testResult!,
        file: _file,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverProv = context.watch<DriverProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alcohol Test Form')),
      body: driverProv.loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Driver autocomplete
                  DriverAutocompleteField(
                    drivers: driverProv.drivers,
                    border: _border,
                    errorBorder: _errorBorder,
                    padding: _fieldPadding,
                    onSelected: (drv) => setState(() => _selectedDriver = drv),
                  ),
                  const SizedBox(height: 16),

                  // Reading input
                  InputField(
                    key: const ValueKey('Reading'),
                    width: 500,
                    label: 'Reading',
                    initialValue: _reading,
                    filled: false,
                    isRequired: true,
                    onSaved: (val) => _reading = val,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Test result dropdown
                  Dropdown(
                    key: const ValueKey('Test Result'),
                    width: 500,
                    showTitle: true,
                    title: 'Test Result',
                    required: true,
                    value: _testResult,
                    onChanged: (val) => setState(() => _testResult = val),
                    items: getDropDownMenuItems(['PASS', 'FAIL']),
                  ),
                  const SizedBox(height: 16),

                  // File upload
                  if (_testResult == 'FAIL')
                    FileUploadWidget(
                      title: 'Upload Image',
                      file: _file,
                      onDelete: () => setState(() => _file = null),
                      onFilePick: (xfile, _) => setState(() => _file = xfile),
                    ),
                  const SizedBox(height: 30),

                  // Submit button
                  ElevatedButton(
                    onPressed: _onSubmit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
    );
  }
}

class DriverAutocompleteField extends StatelessWidget {
  const DriverAutocompleteField({
    super.key,
    required this.drivers,
    required this.border,
    required this.errorBorder,
    required this.padding,
    required this.onSelected,
    this.initialSelection,
  });

  final OutlineInputBorder border;
  final List<Driver> drivers;
  final OutlineInputBorder errorBorder;
  final Driver? initialSelection;
  final ValueChanged<Driver> onSelected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              text: 'Driver',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Autocomplete<Driver>(
            // show first, middle, last
            displayStringForOption: _fullName,
            initialValue: TextEditingValue(
              text: initialSelection != null
                  ? _fullName(initialSelection!)
                  : '',
            ),

            optionsBuilder: (txt) {
              final query = txt.text.toLowerCase();
              return drivers.where((d) {
                return _fullName(d).toLowerCase().contains(query);
              });
            },

            fieldViewBuilder: (ctx, ctl, focusNode, onSubmit) {
              return TextFormField(
                controller: ctl,
                focusNode: focusNode,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'This is required';
                  if (!drivers.any(
                    (d) => _fullName(d).toLowerCase() == val.toLowerCase(),
                  )) {
                    return 'Invalid Driver';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: border,
                  focusedBorder: border,
                  errorBorder: errorBorder,
                  focusedErrorBorder: errorBorder,
                  contentPadding: padding,
                  hintText: 'Enter Driver',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                onFieldSubmitted: (_) => onSubmit(),
              );
            },

            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}
