import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';
import '../services/hive_service.dart';
import '../widgets/inputfield.dart';
import '../widgets/no_data_widget.dart';

class AllVehiclesListPage extends StatefulWidget {
  const AllVehiclesListPage({super.key});

  @override
  State<AllVehiclesListPage> createState() => _AllVehiclesListPageState();
}

class _AllVehiclesListPageState extends State<AllVehiclesListPage> {
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
      appBar: AppBar(
        title: const Text('Vehicles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: ValueListenableBuilder(
            valueListenable: HiveService.vehicleBox.listenable(),
            builder: (context, box, _) {
              final vehicles = box.values.toList();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InputField(
                  label: 'Search Vehicle',
                  showTitle: false,
                  hintText: 'Search Vehicle...',
                  filled: false,
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
              : filterVehicles.isEmpty
              ? const NoDataWidget()
              : ListView.separated(
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
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {},
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
