import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../models/expense_type.dart';
import '../models/fuel_storage.dart';
import '../models/vehicle.dart';
import '../providers/expense_provider.dart';
import '../providers/vehicle_provider.dart';
import '../services/analytics_service.dart';
import '../services/hive_service.dart';
import '../services/injectable.dart';
import '../widgets/inputfield.dart';
import '../widgets/no_data_widget.dart';
import 'manage_expense/battery/add_battery_expense_page.dart';
import 'manage_expense/fuel/add_fuel_expense_page.dart';
import 'manage_expense/fuel/add_loose_fuel_expense_page.dart';
import 'manage_expense/fuel/end_filling_page.dart';
import 'manage_expense/maintenance/add_maintenance_expense_page.dart';
import 'manage_expense/salary/add_salary_expense_page.dart';
import 'manage_expense/tyres/add_types_expense_page.dart';
import 'vehicle_management/vehicle_details_page.dart';

class VehiclesListPage extends StatefulWidget {
  const VehiclesListPage({
    super.key,
    this.fuelType,
    this.expenseType,
    this.mode,
  });

  final ExpenseType? expenseType;
  final String? fuelType;
  final String? mode;

  @override
  State<VehiclesListPage> createState() => _VehiclesListPageState();
}

class _VehiclesListPageState extends State<VehiclesListPage> {
  List<StorageItem> filterStorages = [];
  List<Vehicle> filterVehicles = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'vehicles-list-page',
      parameters: {
        'fuelType': '${widget.fuelType}',
        'expenseType': '${widget.expenseType?.expenseType}',
        'mode': '${widget.mode}',
      },
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.mode == 'SelfFilling') {
        Provider.of<VehicleProvider>(
          context,
          listen: false,
        ).getFuelStorages(widget.fuelType);
      }
      Provider.of<VehicleProvider>(context, listen: false).getVehicles();
    });
  }

  void _showEndFillingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Filling'),
        content: const SizedBox(
          width: double.maxFinite,
          child: Text('Are you sure you want to end the fuel filling?'),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EndFillingPage(fuelType: widget.fuelType!),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final filledVehicleNumbers = expenseProvider.filledVehicleNumbers;
    final fuelStorages = HiveService.fuelStorageBox.values
        .where((e) => e.fuelType == widget.fuelType)
        .toList();

    return PopScope(
      canPop: widget.mode != 'SelfFilling' || filledVehicleNumbers.isEmpty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        _showEndFillingDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vehicles'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: ValueListenableBuilder(
              valueListenable: HiveService.vehicleBox.listenable(),
              builder: (context, box, _) {
                final vehicles = widget.fuelType == null
                    ? box.values.toList()
                    : box.values
                          .toList()
                          .where((e) => e.fuelType == widget.fuelType)
                          .toList();
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
                      filterStorages = fuelStorages
                          .where(
                            (e) => e.name.toLowerCase().contains(
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
        bottomNavigationBar:
            widget.mode != 'SelfFilling' || filledVehicleNumbers.isEmpty
            ? null
            : ElevatedButton(
                onPressed: _showEndFillingDialog,
                child: const Text('End Filling'),
              ),
        body: ValueListenableBuilder(
          valueListenable: HiveService.vehicleBox.listenable(),
          builder: (context, box, _) {
            final vehicles = widget.mode != 'SelfFilling'
                ? box.values.toList()
                : box.values
                      .toList()
                      .where((e) => e.fuelType == widget.fuelType)
                      .toList();
            if (filterVehicles.isEmpty && _searchController.text.isEmpty) {
              filterVehicles = vehicles;
            }
            if (filterStorages.isEmpty && _searchController.text.isEmpty) {
              filterStorages = fuelStorages;
            }
            return provider.loading
                ? const Center(child: CircularProgressIndicator())
                : filterStorages.isEmpty && filterVehicles.isEmpty
                ? const NoDataWidget()
                : ListView(
                    children: [
                      if (fuelStorages.isNotEmpty &&
                          widget.mode == 'SelfFilling')
                        ListView.separated(
                          primary: false,
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final item = filterStorages[index];
                            final isFilled = filledVehicleNumbers.contains(
                              item.name,
                            );
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.grey),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: isFilled
                                  ? const Text('Already Filled')
                                  : Text('${item.type} - ${item.fuelType}'),
                              enabled: !isFilled,
                              trailing: const Icon(Icons.keyboard_arrow_right),
                              onTap: isFilled
                                  ? null
                                  : () async {
                                      final res = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddLooseFuelExpensePage(
                                                expenseType: HiveService
                                                    .expenseTypesBox
                                                    .values
                                                    .singleWhere(
                                                      (e) =>
                                                          e.code == 'loosefuel',
                                                    ),
                                                storageItem: item,
                                              ),
                                        ),
                                      );
                                      if (res == 100) {
                                        setState(() {});
                                      }
                                    },
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemCount: filterStorages.length,
                        ),
                      ListView.separated(
                        primary: false,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemBuilder: (context, index) {
                          final item = filterVehicles[index];
                          final isFilled = filledVehicleNumbers.contains(
                            item.number,
                          );
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
                            subtitle: isFilled
                                ? const Text('Already Filled')
                                : Text(item.fuelType ?? ''),
                            enabled: !isFilled,
                            trailing: const Icon(Icons.keyboard_arrow_right),
                            onTap: isFilled
                                ? null
                                : () async {
                                    switch (widget.expenseType?.code) {
                                      case 'fuel':
                                        final res = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddFuelExpensePage(
                                                  expenseType:
                                                      widget.expenseType!,
                                                  vehicle: item,
                                                  mode: widget.mode!,
                                                ),
                                          ),
                                        );
                                        if (res == 100) {
                                          setState(() {});
                                        }
                                        break;
                                      case 'tyres':
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddTyresExpensePage(
                                                  expenseType:
                                                      widget.expenseType!,
                                                  vehicle: item,
                                                ),
                                          ),
                                        );
                                        break;
                                      case 'maintenance':
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddMaintenanceExpensePage(
                                                  expenseType:
                                                      widget.expenseType!,
                                                  vehicle: item,
                                                ),
                                          ),
                                        );
                                        break;
                                      case 'salary':
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddSalaryExpensePage(
                                                  expenseType:
                                                      widget.expenseType!,
                                                  vehicle: item,
                                                ),
                                          ),
                                        );
                                        break;
                                      case 'battery':
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddbatteryExpensePage(
                                                  expenseType:
                                                      widget.expenseType!,
                                                  vehicle: item,
                                                ),
                                          ),
                                        );
                                        break;
                                      default:
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VehicleDetailsPage(
                                                  vehicleNumber: item.number,
                                                ),
                                          ),
                                        );
                                    }
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
      ),
    );
  }
}
