import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../../models/vehicle.dart';
import '../../../providers/vehicle_provider.dart';
import '../../../services/hive_service.dart';
import '../../../widgets/inputfield.dart';
import '../../../widgets/no_data_widget.dart';

class CleaningLogPage extends StatefulWidget {
  const CleaningLogPage({super.key});

  @override
  State<CleaningLogPage> createState() => _CleaningLogPageState();
}

class _CleaningLogPageState extends State<CleaningLogPage> {
  int _currentStep = 0;

  final TextEditingController _searchController = TextEditingController();
  List<Vehicle> filteredVehicles = [];

  List<Map<String, dynamic>> selectedVehicles = [];
  List<int> selectedCleaningParts = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<VehicleProvider>(context, listen: false);
      prov.getVehicles();
      prov.getVehicleCleaningParts();
    });
  }

  void _onSearchChanged(String val, List<Vehicle> vehicles) {
    setState(() {
      if (val.trim().isEmpty) {
        filteredVehicles = vehicles;
      } else {
        filteredVehicles = vehicles
            .where((e) => e.number.toLowerCase().contains(val.toLowerCase()))
            .toList();
      }
    });
  }

  bool _isVehicleSelected(Vehicle v) =>
      selectedVehicles.any((m) => m['Id'] == v.id);

  void _toggleSelectVehicle(Vehicle vehicle) {
    setState(() {
      final map = {'Id': vehicle.id, 'VehicleNo': vehicle.number};
      if (_isVehicleSelected(vehicle)) {
        selectedVehicles.removeWhere((m) => m['Id'] == vehicle.id);
      } else {
        selectedVehicles.add(map);
      }
    });
  }

  Widget _buildStickySearch(BuildContext ctx, List<Vehicle> vehicles) {
    return Container(
      color: Theme.of(ctx).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InputField(
        label: 'Search Vehicle',
        showTitle: false,
        hintText: 'Search Vehicle...',
        filled: false,
        initialValue: _searchController.text,
        controller: _searchController,
        type: TextFieldType.search,
        textInputAction: TextInputAction.search,
        onChanged: (v) => _onSearchChanged(v, vehicles),
      ),
    );
  }

  Widget _buildVehicleList(List<Vehicle> vehicles, bool loading) {
    final showList = _searchController.text.trim().isEmpty
        ? vehicles
        : filteredVehicles;

    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (showList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: NoDataWidget(),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: showList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final v = showList[i];
        final selected = _isVehicleSelected(v);
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleSelectVehicle(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? Theme.of(ctx).colorScheme.primary
                    : Theme.of(ctx).dividerColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: ListTile(
              title: Text(
                v.number,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              trailing: selected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(ctx).colorScheme.primary,
                    )
                  : Icon(Icons.circle_outlined, color: Colors.grey[400]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCleaningPartsList(VehicleProvider prov) {
    final parts = prov.vehicleCleaningParts;
    if (prov.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (parts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: NoDataWidget(),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: parts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final p = parts[i];
        final selected = selectedCleaningParts.contains(p.id);
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => {
            setState(() {
              if (selected) {
                selectedCleaningParts.remove(p.id);
              } else {
                selectedCleaningParts.add(p.id);
              }
            }),
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(ctx).colorScheme.secondary.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? Theme.of(ctx).colorScheme.secondary
                    : Theme.of(ctx).dividerColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.cleaning_services_rounded,
                color: Theme.of(ctx).colorScheme.secondary,
              ),
              title: Text(
                p.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              trailing: selected
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(ctx).colorScheme.secondary,
                    )
                  : Icon(Icons.circle_outlined, color: Colors.grey[400]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons(BuildContext ctx) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (_currentStep == 0) {
                    Navigator.of(ctx).pop();
                  } else {
                    setState(() => _currentStep--);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: Theme.of(ctx).colorScheme.primary),
                ),
                child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    (_currentStep == 0
                        ? selectedVehicles.isNotEmpty
                        : selectedCleaningParts.isNotEmpty)
                    ? () {
                        if (_currentStep == 0) {
                          setState(() => _currentStep = 1);
                        } else {
                          Provider.of<VehicleProvider>(
                            context,
                            listen: false,
                          ).submitVehicleCleaningData(
                            context,
                            selectedCleaningParts,
                            selectedVehicles,
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(ctx).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(_currentStep == 0 ? 'Next' : 'Finish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<VehicleProvider>(context);
    final vehicles = HiveService.vehicleBox.values.toList();

    if (filteredVehicles.isEmpty && _searchController.text.isEmpty) {
      filteredVehicles = vehicles;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentStep == 0 ? 'Select Vehicles' : 'Select Cleaning Parts',
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
            child: Column(
              children: [
                if (_currentStep == 0) ...[
                  _buildStickySearch(context, vehicles),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: HiveService.vehicleBox.listenable(),
                      builder: (_, box, _) =>
                          _buildVehicleList(box.values.toList(), prov.loading),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Expanded(child: _buildCleaningPartsList(prov)),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomButtons(context),
          ),
        ],
      ),
    );
  }
}
