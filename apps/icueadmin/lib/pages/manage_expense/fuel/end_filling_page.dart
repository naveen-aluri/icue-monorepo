import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../providers/expense_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/injectable.dart';
import '../../../widgets/file_upload_widget.dart';
import '../../../widgets/inputfield.dart';

class EndFillingPage extends StatefulWidget {
  const EndFillingPage({super.key, required this.fuelType});
  final String fuelType;

  @override
  State<EndFillingPage> createState() => _EndFillingPageState();
}

class _EndFillingPageState extends State<EndFillingPage> {
  String? endReading;
  XFile? gaugeFile, billFile;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'end-filling-page',
      parameters: {'fuelType': widget.fuelType},
    );
  }

  void onSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).updateSelfFillingStatus(
        context: context,
        fuelType: widget.fuelType,
        gaugeMode: 'end',
        endReading: endReading,
        gaugeFile: gaugeFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('End Fuel Filling')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InputField(
              label: 'End Reading',
              initialValue: endReading,
              keyboardType: TextInputType.number,
              filled: false,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
              ],
              onSaved: (val) => endReading = val,
            ),
            Text(
              'NOTE: End Reading is optional!',
              style: TextStyle(color: Colors.amber.shade700),
            ),
            const SizedBox(height: 16),
            FileUploadWidget(
              title: 'Upload Gauge Reading',
              file: gaugeFile,
              onDelete: () {
                setState(() => gaugeFile = null);
              },
              onFilePick: (xfile, _) {
                setState(() => gaugeFile = xfile);
              },
            ),
            Text(
              'NOTE: Gauge Reading is optional!',
              style: TextStyle(color: Colors.amber.shade700),
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
            Text(
              'NOTE: Upload Bill is optional!',
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
