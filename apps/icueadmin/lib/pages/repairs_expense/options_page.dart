import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/vehicle.dart';
import '../../services/analytics_service.dart';
import '../../services/hive_service.dart';
import '../../services/injectable.dart';
import '../manage_expense/battery/add_battery_expense_page.dart';
import '../manage_expense/maintenance/add_maintenance_expense_page.dart';
import '../manage_expense/salary/add_salary_expense_page.dart';
import '../manage_expense/tyres/add_types_expense_page.dart';
import '../vehicle_management/reports/cleaning_report_page.dart';
import '../vehicle_management/reports/fuel_report_page.dart';
import '../vehicle_management/reports/mileage_report_page.dart';
import '../vehicle_management/reports/over_speed_report_page.dart';
import '../vehicle_management/vehicle_details_page.dart';

final iconMap = {
  'fuel': Icons.local_gas_station,
  'tyres': Icons.attractions,
  'maintenance': Icons.engineering,
  'salary': Icons.payment,
  'battery': Icons.battery_charging_full,
};

class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    getIt<AnalyticsService>().logScreenView(
      screenName: 'options-page',
      parameters: {'vehicleNumber': vehicle.number},
    );
    return Scaffold(
      appBar: AppBar(title: Text(vehicle.number)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ListTile(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(8),
          //     side: const BorderSide(color: Colors.green),
          //   ),
          //   dense: true,
          //   leading: const Icon(Icons.construction, color: Colors.green),
          //   title: const Text(
          //     'Repairs',
          //     style: TextStyle(
          //       fontSize: 16,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          //   trailing: const Icon(Icons.keyboard_arrow_right),
          //   onTap: () {
          //     //
          //   },
          // ),
          // const SizedBox(height: 16),
          // ListTile(
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(8),
          //     side: const BorderSide(color: Colors.green),
          //   ),
          //   dense: true,
          //   leading: const Icon(Icons.bus_alert, color: Colors.green),
          //   title: const Text(
          //     'Services',
          //     style: TextStyle(
          //       fontSize: 16,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          //   trailing: const Icon(Icons.keyboard_arrow_right),
          //   onTap: () {
          //     //
          //   },
          // ),
          // const SizedBox(height: 16),
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
          ValueListenableBuilder(
            valueListenable: HiveService.expenseTypesBox.listenable(),
            builder: (context, box, _) {
              final items = box.values.toList();
              return ExpansionTile(
                leading: const Icon(Icons.done_all_sharp, color: Colors.green),
                title: const Text(
                  'Expenses',
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
                  for (final item in items)
                    ['fuel', 'loosefuel', 'statutory'].contains(item.code)
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                iconMap[item.code],
                                color: Colors.green,
                              ),
                              title: Text(
                                item.expenseTypeDesc,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                switch (item.code) {
                                  case 'tyres':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddTyresExpensePage(
                                              expenseType: item,
                                              vehicle: vehicle,
                                            ),
                                      ),
                                    );
                                    break;
                                  case 'maintenance':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddMaintenanceExpensePage(
                                              expenseType: item,
                                              vehicle: vehicle,
                                            ),
                                      ),
                                    );
                                    break;
                                  case 'salary':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddSalaryExpensePage(
                                              expenseType: item,
                                              vehicle: vehicle,
                                            ),
                                      ),
                                    );
                                    break;
                                  case 'battery':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddbatteryExpensePage(
                                              expenseType: item,
                                              vehicle: vehicle,
                                            ),
                                      ),
                                    );
                                    break;
                                  default:
                                }
                              },
                            ),
                          ),
                ],
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.cleaning_services_outlined,
                    color: Colors.green,
                  ),
                  title: const Text(
                    'Cleaning Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CleaningReportPage(
                          vehicleId: vehicle.id,
                          vehicleNumber: vehicle.number,
                        ),
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
