import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../models/vehicle.dart';
import '../../services/analytics_service.dart';
import '../../services/injectable.dart';
import '../../utils/app_utils.dart';
import 'check_fuel_price_page.dart';
import 'reports/fuel_report_page.dart';
import 'reports/mileage_report_page.dart';
import 'reports/over_speed_report_page.dart';
import 'vehicle_details_page.dart';

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    getIt<AnalyticsService>().logScreenView(
      screenName: 'vehicle-management-options-page',
      parameters: {'vehicleNumber': vehicle.number},
    );
    return Scaffold(
      appBar: AppBar(title: Text(vehicle.number)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.green),
            ),
            dense: true,
            leading: const Icon(Icons.local_gas_station, color: Colors.green),
            title: const Text(
              'Fill the fuel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              if (vehicle.fuelType != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckFuelPricePage(vehicle: vehicle),
                  ),
                );
              } else {
                FirebaseCrashlytics.instance.recordError(
                  vehicle.toJson(),
                  StackTrace.empty,
                  fatal: true,
                  printDetails: true,
                  information: [
                    {'from': 'Fill the fuel'},
                  ],
                );
                AppUtils.showErrorMessage(
                  context,
                  'Fuel Type is not defined for this vehicle!',
                );
              }
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.green),
            ),
            dense: true,
            leading: const Icon(Icons.construction, color: Colors.green),
            title: const Text(
              'Repairs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              //
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.green),
            ),
            dense: true,
            leading: const Icon(Icons.bus_alert, color: Colors.green),
            title: const Text(
              'Services',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              //
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.green),
            ),
            dense: true,
            leading: const Icon(Icons.directions_bus, color: Colors.green),
            title: const Text(
              'Vehicle Info',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VehicleDetailsPage(vehicleNumber: vehicle.number),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            leading: const Icon(Icons.assessment, color: Colors.green),
            title: const Text(
              'Reports',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            dense: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              side: BorderSide(color: Colors.green),
            ),
            collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              side: BorderSide(color: Colors.green),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.local_gas_station_outlined,
                    color: Colors.green,
                  ),
                  title: const Text(
                    'Fuel Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FuelReportPage(vehicle: vehicle),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.gas_meter_outlined,
                    color: Colors.green,
                  ),
                  title: const Text(
                    'Mileage Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MileageReportPage(vehicle: vehicle),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.speed, color: Colors.green),
                  title: const Text(
                    'Over Speed Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OverSpeedReportPage(vehicle: vehicle),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
