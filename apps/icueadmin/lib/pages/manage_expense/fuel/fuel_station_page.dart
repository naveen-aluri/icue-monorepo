import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../../models/expense_type.dart';
import '../../../models/vehicle.dart';
import '../../../providers/vehicle_provider.dart';
import '../../../services/hive_service.dart';
import 'add_fuel_expense_page.dart';

class FuelStationPage extends StatefulWidget {
  const FuelStationPage({
    super.key,
    required this.expenseType,
    required this.mode,
  });

  final ExpenseType expenseType;
  final String mode;

  @override
  State<FuelStationPage> createState() => _FuelStationPageState();
}

class _FuelStationPageState extends State<FuelStationPage> {
  List<Vehicle> filterVehicles = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(context, listen: false).getVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles')),
      body: ValueListenableBuilder(
        valueListenable: HiveService.vehicleBox.listenable(),
        builder: (context, box, _) {
          final vehicles = box.values.toList();
          if (filterVehicles.isEmpty && _searchController.text.isEmpty) {
            filterVehicles = vehicles;
          }
          return provider.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
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
                      subtitle: Text(item.fuelType ?? '-'),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFuelExpensePage(
                              expenseType: widget.expenseType,
                              vehicle: item,
                              mode: widget.mode,
                            ),
                          ),
                        );
                        if (res == 100) {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: filterVehicles.length,
                );
        },
      ),
    );
  }
}
