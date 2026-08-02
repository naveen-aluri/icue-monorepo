import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/injectable.dart';
import '../../utils/app_utils.dart';
import '../../widgets/file_upload_widget.dart';
import '../../widgets/inputfield.dart';

class FuelFillPage extends StatefulWidget {
  const FuelFillPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<FuelFillPage> createState() => _FuelFillPageState();
}

class _FuelFillPageState extends State<FuelFillPage> {
  XFile? file;
  String? currentKms, fuelLiters;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'fuel-fill-page',
      parameters: {'vehicleNumber': widget.vehicle.number},
    );
  }

  void onSubmit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      if (file == null) {
        AppUtils.showErrorMessage(context, 'Please upload Odometer readings!');
        return;
      }
      Provider.of<VehicleProvider>(context, listen: false).addFuelReading(
        context: context,
        vehicleNumber: widget.vehicle.number,
        km: currentKms!,
        fuelLiters: fuelLiters!,
        file: file!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.vehicle.number} - Fill Fuel')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            InputField(
              label: 'Current KMS Reading',
              initialValue: currentKms,
              isRequired: true,
              keyboardType: TextInputType.number,
              suffix: 'KMS',
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
              ],
              onSaved: (val) => currentKms = val,
            ),
            const SizedBox(height: 16),
            InputField(
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
              onSaved: (val) => fuelLiters = val,
            ),
            // ...((fuelLiters != null &&
            //         fuelLiters!.isNotEmpty &&
            //         _priceController.text.isNotEmpty)
            //     ? [
            //         const SizedBox(height: 10),
            //         Text(
            //           'Total Amount: ${(num.tryParse(fuelLiters!)! * num.tryParse(_priceController.text)!).toStringAsFixed(2)}',
            //           style: const TextStyle(fontSize: 16),
            //         ),
            //       ]
            //     : []),
            const SizedBox(height: 16),
            FileUploadWidget(
              title: 'Upload Odometer',
              file: file,
              onDelete: () {
                setState(() => file = null);
              },
              onFilePick: (xfile, _) {
                setState(() => file = xfile);
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: onSubmit, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}
