import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/vehicle.dart';
import '../../providers/expense_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/hive_service.dart';
import '../../widgets/inputfield.dart';
import 'options_page.dart';

class RepairsAndExpensePage extends StatefulWidget {
  const RepairsAndExpensePage({super.key});

  @override
  State<RepairsAndExpensePage> createState() => _RepairsAndExpensePageState();
}

final iconMap = {
  'fuel': Icons.local_gas_station,
  'tyres': Icons.attractions,
  'maintenance': Icons.engineering,
  'salary': Icons.payment,
  'battery': Icons.battery_charging_full,
};

class _RepairsAndExpensePageState extends State<RepairsAndExpensePage> {
  List<Vehicle> filterVehicles = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).reset();
      Provider.of<VehicleProvider>(context, listen: false).getVehicles();
      Provider.of<ExpenseProvider>(context, listen: false).getExpenseTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ValueListenableBuilder(
            valueListenable: HiveService.vehicleBox.listenable(),
            builder: (context, box, _) {
              final vehicles = box.values.toList();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: InputField(
                  label: 'Search Vehicle',
                  showTitle: false,
                  hintText: 'Search Vehicle...',
                  initialValue: _searchController.text,
                  controller: _searchController,
                  type: TextFieldType.search,
                  textInputAction: TextInputAction.search,
                  onChanged: (val) {
                    filterVehicles = vehicles
                        .where(
                          (e) => e.number.toLowerCase().contains(
                            val.toLowerCase(),
                          ),
                        )
                        .toList();
                    setState(() {});
                  },
                ),
              );
            },
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.vehicleBox.listenable(),
        builder: (context, box, _) {
          final vehicles = box.values.toList();
          if (filterVehicles.isEmpty && _searchController.text.isEmpty) {
            filterVehicles = vehicles;
          }
          return provider.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemBuilder: (context, index) {
                        final item = filterVehicles[index];
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          title: Text(
                            item.number,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(item.fuelType ?? ''),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OptionsPage(vehicle: item),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemCount: filterVehicles.length,
                    ),
                  ],
                );
        },
      ),
    );
  }
}

//   @override
//   void initState() {
//     super.initState();
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       Provider.of<ExpenseProvider>(context, listen: false).getExpenseTypes();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ExpenseProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Repairs and Expenses',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: provider.loading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               padding: const EdgeInsets.all(16),
//               children: [
//                 // ListTile(
//                 //   shape: RoundedRectangleBorder(
//                 //     borderRadius: BorderRadius.circular(8),
//                 //     side: const BorderSide(color: Colors.green),
//                 //   ),
//                 //   dense: true,
//                 //   leading: const Icon(Icons.local_gas_station, color: Colors.green),
//                 //   title: const Text(
//                 //     'Fill the fuel',
//                 //     style: TextStyle(
//                 //       fontSize: 16,
//                 //       fontWeight: FontWeight.w600,
//                 //     ),
//                 //   ),
//                 //   trailing: const Icon(Icons.keyboard_arrow_right),
//                 //   onTap: () {
//                 //     if (vehicle.fuelType != null) {
// Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => CheckFuelPricePage(vehicle: vehicle),
//   ),
// );
//                 //     } else {
//                 //       FirebaseCrashlytics.instance.recordError(
//                 //         vehicle.toJson(),
//                 //         StackTrace.empty,
//                 //         fatal: true,
//                 //         printDetails: true,
//                 //         information: [
//                 //           {'from': 'Fill the fuel'},
//                 //         ],
//                 //       );
//                 //       AppUtils.showErrorMessage(
//                 //         context,
//                 //         'Fuel Type is not defined for this vehicle!',
//                 //       );
//                 //     }
//                 //   },
//                 // ),
//                 // const SizedBox(height: 16),
//                 ListTile(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: const BorderSide(color: Colors.green),
//                   ),
//                   dense: true,
//                   leading: const Icon(Icons.construction, color: Colors.green),
//                   title: const Text(
//                     'Repairs',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   trailing: const Icon(Icons.keyboard_arrow_right),
//                   onTap: () {
//                     //
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ListTile(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: const BorderSide(color: Colors.green),
//                   ),
//                   dense: true,
//                   leading: const Icon(Icons.bus_alert, color: Colors.green),
//                   title: const Text(
//                     'Services',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   trailing: const Icon(Icons.keyboard_arrow_right),
//                   onTap: () {
//                     //
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ListTile(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: const BorderSide(color: Colors.green),
//                   ),
//                   dense: true,
//                   leading:
//                       const Icon(Icons.directions_bus, color: Colors.green),
//                   title: const Text(
//                     'Vehicle Info',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   trailing: const Icon(Icons.keyboard_arrow_right),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const VehiclesListPage(),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ValueListenableBuilder(
//                   valueListenable: HiveService.expenseTypesBox.listenable(),
//                   builder: (context, box, _) {
//                     final items = box.values.toList();
//                     return ExpansionTile(
//                       leading:
//                           const Icon(Icons.done_all_sharp, color: Colors.green),
//                       title: const Text(
//                         'Expenses',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       dense: true,
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8)),
//                         side: BorderSide(color: Colors.green),
//                       ),
//                       collapsedShape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8)),
//                         side: BorderSide(color: Colors.green),
//                       ),
//                       children: <Widget>[
//                         for (final item in items)
//                           ['fuel', 'loosefuel'].contains(item.code)
//                               ? const SizedBox()
//                               : Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 20,
//                                   ),
//                                   child: ListTile(
//                                     dense: true,
//                                     leading: Icon(
//                                       iconMap[item.code],
//                                       color: Colors.green,
//                                     ),
//                                     title: Text(
//                                       item.expenseTypeDesc,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     trailing:
//                                         const Icon(Icons.keyboard_arrow_right),
//                                     onTap: () {
//                                       switch (item.code) {
//                                         case 'tyres':
//                                         case 'maintenance':
//                                         case 'salary':
//                                         case 'battery':
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   VehiclesListPage(
//                                                 expenseType: item,
//                                                 mode: '',
//                                               ),
//                                             ),
//                                           );
//                                           break;
//                                         default:
//                                       }
//                                     },
//                                   ),
//                                 ),
//                       ],
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 ExpansionTile(
//                   leading: const Icon(Icons.assessment, color: Colors.green),
//                   title: const Text(
//                     'Reports',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   dense: true,
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(8)),
//                     side: BorderSide(color: Colors.green),
//                   ),
//                   collapsedShape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(8)),
//                     side: BorderSide(color: Colors.green),
//                   ),
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: ListTile(
//                         dense: true,
//                         leading: const Icon(
//                           Icons.local_gas_station_outlined,
//                           color: Colors.green,
//                         ),
//                         title: const Text(
//                           'Fuel Report',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         trailing: const Icon(Icons.keyboard_arrow_right),
//                         onTap: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) => FuelReportPage(vehicle: vehicle),
//                           //   ),
//                           // );
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: ListTile(
//                         dense: true,
//                         leading: const Icon(
//                           Icons.gas_meter_outlined,
//                           color: Colors.green,
//                         ),
//                         title: const Text(
//                           'Mileage Report',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         trailing: const Icon(Icons.keyboard_arrow_right),
//                         onTap: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) =>
//                           //         MileageReportPage(vehicle: vehicle),
//                           //   ),
//                           // );
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: ListTile(
//                         dense: true,
//                         leading: const Icon(
//                           Icons.speed,
//                           color: Colors.green,
//                         ),
//                         title: const Text(
//                           'Over Speed Report',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         trailing: const Icon(Icons.keyboard_arrow_right),
//                         onTap: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) =>
//                           //         OverSpeedReportPage(vehicle: vehicle),
//                           //   ),
//                           // );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//     );
//   }
// }
