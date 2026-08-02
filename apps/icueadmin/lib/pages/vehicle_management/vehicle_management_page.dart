import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/vehicle_provider.dart';
import '../../services/hive_service.dart';
import 'options_page.dart';

class VehicleManagementPage extends StatefulWidget {
  const VehicleManagementPage({super.key});

  @override
  State<VehicleManagementPage> createState() => _VehicleManagementPageState();
}

class _VehicleManagementPageState extends State<VehicleManagementPage> {
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
      appBar: AppBar(title: const Text('Vehicle Management')),
      body: ValueListenableBuilder(
        valueListenable: HiveService.vehicleBox.listenable(),
        builder: (context, box, _) {
          return provider.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final item = box.values.toList()[index];
                    return Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: Text(
                          item.number,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon(
                            //   Icons.construction,
                            //   color: Colors.orange,
                            // ),
                            // Icon(
                            //   Icons.health_and_safety,
                            //   color: Colors.blueAccent,
                            // ),
                            // SizedBox(width: 16),
                            Icon(Icons.keyboard_arrow_right),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OptionsPage(vehicle: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: box.values.length,
                );
        },
      ),
    );
  }
}
