import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/vehicle_data.dart';
import '../../providers/vehicle_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/inputfield.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final duration = const Duration(milliseconds: 300);

  List<VehicleData> _filteredVehicles = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showFab = true;

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(context, listen: false).getVehiclesData();
    });

    // Listen to search input changes with debounce
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final provider = Provider.of<VehicleProvider>(context, listen: false);
    final query = _searchController.text.trim().toLowerCase();

    if (_searchQuery != query) {
      _searchQuery = query;
      setState(() {
        _filteredVehicles = query.isEmpty
            ? provider.vehiclesData
            : provider.vehiclesData
                  .where(
                    (driver) => driver.number!.toLowerCase().contains(query),
                  )
                  .toList();
      });
    }
  }

  void _toggleFabVisibility(ScrollDirection direction) {
    setState(() {
      if (direction == ScrollDirection.reverse) {
        _showFab = false;
      } else if (direction == ScrollDirection.forward) {
        _showFab = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);

    _filteredVehicles = _searchQuery.isEmpty
        ? provider.vehiclesData
        : _filteredVehicles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: InputField(
              label: 'Search Vehicle',
              showTitle: false,
              hintText: 'Search Vehicle...',
              initialValue: _searchController.text,
              controller: _searchController,
              type: TextFieldType.search,
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: duration,
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: duration,
          opacity: _showFab ? 1 : 0,
          child: FloatingActionButton.extended(
            label: const Text('Add Vehicle'),
            icon: const Icon(Icons.add),
            onPressed: () {
              _searchController.clear();
              FocusManager.instance.primaryFocus?.unfocus();
              context.go('/layout.vehicles/add-vehicle');
            },
          ),
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                _toggleFabVisibility(notification.direction);
                return true;
              },
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filteredVehicles.length,
                padding: const EdgeInsets.all(16),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context, index) {
                  final vehicle = _filteredVehicles[index];
                  final insuranceStatus = AppUtils.checkLicenseStatus(
                    'Insurance',
                    vehicle.insuranceExpiryDate.toDate(),
                  );
                  final rcStatus = AppUtils.checkLicenseStatus(
                    'RC',
                    vehicle.rcExpiryDate.toDate(),
                  );
                  final fitnessStatus = AppUtils.checkLicenseStatus(
                    'Fitness',
                    vehicle.fitnessExpiryDate.toDate(),
                  );
                  final roadTaxStatus = AppUtils.checkLicenseStatus(
                    'Road Tax',
                    vehicle.roadTaxExpiryDate.toDate(),
                  );
                  final pollutionStatus = AppUtils.checkLicenseStatus(
                    'Pollution',
                    vehicle.pollutionExpiryDate.toDate(),
                  );
                  final permitStatus = AppUtils.checkLicenseStatus(
                    'Permit',
                    vehicle.permitExpiryDate.toDate(),
                  );
                  final status = [
                    insuranceStatus,
                    rcStatus,
                    fitnessStatus,
                    roadTaxStatus,
                    pollutionStatus,
                    permitStatus,
                  ].whereType<String>().toList();
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    title: Text(
                      vehicle.number ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: status.isEmpty
                        ? null
                        : const Text(
                            'Some documents for this vehicle have expired. Please review and update the expired documents',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      _searchController.clear();
                      FocusManager.instance.primaryFocus?.unfocus();
                      context.go(
                        '/layout.vehicles/vehicle-details?id=${vehicle.id}',
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
