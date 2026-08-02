import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../dialogs/boarding_zone_dialog.dart';
import '../../models/routes.dart';
import '../../providers/vehicle_provider.dart';

class DropVehiclesPage extends StatefulWidget {
  const DropVehiclesPage({super.key});

  @override
  State<DropVehiclesPage> createState() => _DropVehiclesPageState();
}

class _DropVehiclesPageState extends State<DropVehiclesPage> {
  final Set<int> _selectedRouteIds = {};

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(context, listen: false).getBoardingTypes();
    });
  }

  Future<void> _handleSubmit() async {
    if (_selectedRouteIds.isEmpty) return;

    final provider = context.read<VehicleProvider>();
    String? selectedZone;

    if (provider.boardingTypes.isNotEmpty) {
      selectedZone = await showDialog(
        context: context,
        builder: (context) => const BoardingZoneDialog(),
      );
    }

    if (provider.boardingTypes.isNotEmpty && selectedZone == null) return;

    final result = await provider.updateVehicleArrivalStatus(
      context,
      _selectedRouteIds.toList(),
      'ARRIVED',
      selectedZone,
    );

    if (result && mounted) {
      setState(() {
        _selectedRouteIds.clear();
      });
      await provider.getVehicleArrivals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Drop-off Vehicles')),
        bottomNavigationBar: ElevatedButton.icon(
          onPressed: _selectedRouteIds.isEmpty ? null : _handleSubmit,
          icon: const Icon(Icons.check_circle_rounded),
          label: Text('Mark as Boarding (${_selectedRouteIds.length})'),
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        body: Consumer<VehicleProvider>(
          builder: (context, provider, child) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final routes = provider.routesForDropOff;
            if (routes.isEmpty) {
              return const Center(child: Text('All vehicles have arrived.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                final isSelected = _selectedRouteIds.contains(route.id);
                return _RouteCard(
                  route: route,
                  isSelected: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedRouteIds.add(route.id);
                      } else {
                        _selectedRouteIds.remove(route.id);
                      }
                    });
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.isSelected,
    required this.onChanged,
  });

  final bool isSelected;
  final ValueChanged<bool?> onChanged;
  final Routee route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isSelected ? 2 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: onChanged,
        title: Row(
          spacing: 12,
          children: [
            Icon(Icons.directions_bus, color: theme.primaryColor),
            Text(
              route.routeNo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        activeColor: theme.primaryColor,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
