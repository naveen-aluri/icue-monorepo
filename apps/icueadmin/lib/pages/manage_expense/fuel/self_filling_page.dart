import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../models/expense_type.dart';
import '../../../providers/expense_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/injectable.dart';
import '../../../widgets/dropdown.dart';
import '../../../widgets/file_upload_widget.dart';
import '../../../widgets/inputfield.dart';
import '../../vehicles_list_page.dart';

class SelfFillingPage extends StatefulWidget {
  const SelfFillingPage({
    super.key,
    required this.expenseType,
    required this.mode,
  });

  final ExpenseType expenseType;
  final String mode;

  @override
  State<SelfFillingPage> createState() => _SelfFillingPageState();
}

class _SelfFillingPageState extends State<SelfFillingPage> {
  XFile? file;
  String? fuelType, startReading;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'self-filling-page',
      parameters: {
        'expenseType': widget.expenseType.expenseType,
        'mode': widget.mode,
      },
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).reset();
    });
  }

  Future<void> onSubmit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      final result = await Provider.of<ExpenseProvider>(context, listen: false)
          .updateSelfFillingStatus(
            context: context,
            fuelType: fuelType!,
            gaugeMode: 'start',
            startReading: startReading,
            gaugeFile: file,
          );
      if (result) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehiclesListPage(
              fuelType: fuelType,
              expenseType: widget.expenseType,
              mode: widget.mode,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Self Filling')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Dropdown(
              title: 'Fuel Type',
              showTitle: true,
              value: fuelType,
              required: true,
              onChanged: (val) => setState(() => fuelType = val),
              items: getDropDownMenuItems(['PETROL', 'DIESEL', 'LPG']),
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'Start Reading',
              initialValue: startReading,
              keyboardType: TextInputType.number,
              filled: false,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
              ],
              onSaved: (val) => startReading = val,
            ),
            Text(
              'NOTE: Start Reading is optional!',
              style: TextStyle(color: Colors.amber.shade700),
            ),
            const SizedBox(height: 16),
            FileUploadWidget(
              title: 'Upload Gauge Reading',
              file: file,
              onDelete: () {
                setState(() => file = null);
              },
              onFilePick: (xfile, _) {
                setState(() => file = xfile);
              },
            ),
            Text(
              'NOTE: Gauge Reading is optional!',
              style: TextStyle(color: Colors.amber.shade700),
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: onSubmit, child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}
