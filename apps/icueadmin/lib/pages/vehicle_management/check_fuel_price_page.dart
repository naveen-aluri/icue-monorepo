import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/vehicle.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/hive_service.dart';
import '../../services/injectable.dart';
import '../../widgets/inputfield.dart';
import 'fuel_fill_page.dart';

class CheckFuelPricePage extends StatefulWidget {
  const CheckFuelPricePage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<CheckFuelPricePage> createState() => _CheckFuelPricePageState();
}

class _CheckFuelPricePageState extends State<CheckFuelPricePage> {
  bool isUpdate = false;

  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'check-fuel-price-page',
      parameters: {'vehicleNumber': widget.vehicle.number},
    );
  }

  @override
  Widget build(BuildContext context) {
    final price = HiveService.fuelPriceBox.get(widget.vehicle.fuelType) ?? '';
    if (_priceController.text.isEmpty) {
      _priceController.text = price;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.vehicle.number)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${widget.vehicle.fuelType} PRICE: ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0XFF16A087),
                  ),
                ),
                Text(
                  '₹${isUpdate ? price : _priceController.text}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...(isUpdate
                ? [
                    InputField(
                      initialValue: price,
                      label: 'Current Fuel Price',
                      controller: _priceController,
                      isRequired: true,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      suffix: '₹',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final result =
                            await Provider.of<VehicleProvider>(
                              context,
                              listen: false,
                            ).updateFuelPrice(
                              context: context,
                              fuelType: widget.vehicle.fuelType,
                              price: _priceController.text,
                            );
                        if (result) {
                          setState(() {
                            isUpdate = false;
                          });
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ]
                : [
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isUpdate = true;
                        });
                      },
                      child: const Text('Update Price'),
                    ),
                    const SizedBox(height: 20),
                    const Text('OR'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FuelFillPage(vehicle: widget.vehicle),
                          ),
                        );
                      },
                      child: const Text('Continue'),
                    ),
                  ]),
          ],
        ),
      ),
    );
  }
}
