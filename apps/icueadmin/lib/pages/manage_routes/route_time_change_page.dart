import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../models/routes.dart';
import '../../providers/vehicle_provider.dart';
import '../../widgets/dropdown.dart';
import '../../widgets/inputfield.dart';
import 'route_time_selection_page.dart';

class RouteTimeChangePage extends StatefulWidget {
  const RouteTimeChangePage({super.key});

  @override
  State<RouteTimeChangePage> createState() => _RouteTimeChangePageState();
}

class _RouteTimeChangePageState extends State<RouteTimeChangePage> {
  String? _mode;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchTermNotifier = ValueNotifier('');

  final Set<int> _selectedRoutes = {};

  @override
  void dispose() {
    _searchController.dispose();
    _searchTermNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().clearData();
    });

    _searchController.addListener(() {
      _searchTermNotifier.value = _searchController.text;
    });
  }

  void _onModeChanged(String? newMode) {
    if (newMode == null || newMode == _mode) return;

    setState(() {
      _mode = newMode;
      _selectedRoutes.clear();
      _searchController.clear();
    });

    context.read<VehicleProvider>().getRoutesAndPoints(
      newMode == 'Pickup' ? Mode.PICKUP : Mode.DROP,
    );
  }

  void _onSelectAll(bool? isSelected, List<Routee> filteredRoutes) {
    setState(() {
      if (isSelected ?? false) {
        _selectedRoutes.addAll(filteredRoutes.map((r) => r.id));
      } else {
        _selectedRoutes.removeAll(filteredRoutes.map((r) => r.id));
      }
    });
  }

  void _onRouteToggled(bool isSelected, int routeId) {
    setState(() {
      if (isSelected) {
        _selectedRoutes.remove(routeId);
      } else {
        _selectedRoutes.add(routeId);
      }
    });
  }

  /// Builds the main content area below the mode dropdown.
  Widget _buildContent() {
    final provider = context.watch<VehicleProvider>();

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_mode == null) {
      return const _EmptyState(
        icon: Icons.arrow_upward_rounded,
        message: 'Please select a mode to view routes.',
      );
    }

    if (provider.routes.isEmpty) {
      return const _EmptyState(
        icon: Icons.bus_alert_rounded,
        message: 'No routes found for the selected mode.',
      );
    }

    return Column(
      children: [
        InputField(
          label: 'Search Routes',
          hintText: 'Search by route number...',
          controller: _searchController,
          initialValue: '',
          filled: false,
          showTitle: false,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: _searchTermNotifier,
            builder: (context, searchTerm, _) {
              final filteredRoutes = provider.routes
                  .where(
                    (route) => route.routeNo.toLowerCase().contains(
                      searchTerm.toLowerCase(),
                    ),
                  )
                  .toList();

              if (filteredRoutes.isEmpty) {
                return const _EmptyState(
                  icon: Icons.search_off_rounded,
                  message: 'No routes match your search.',
                );
              }

              final isAllFilteredSelected =
                  filteredRoutes.isNotEmpty &&
                  filteredRoutes.every((r) => _selectedRoutes.contains(r.id));

              return _RouteList(
                filteredRoutes: filteredRoutes,
                selectedRoutes: _selectedRoutes,
                isAllFilteredSelected: isAllFilteredSelected,
                onSelectAll: (isSelected) =>
                    _onSelectAll(isSelected, filteredRoutes),
                onRouteToggled: _onRouteToggled,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the persistent bottom action bar.
  Widget _buildBottomActionBar() {
    if (_selectedRoutes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 5, 10),
      child: ElevatedButton.icon(
        icon: Text('Continue with ${_selectedRoutes.length} Routes'),
        label: const Icon(Icons.arrow_forward_rounded),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RouteTimeSelectionPage(
                selectedRoutes: _selectedRoutes.toList(),
                mode: _mode == 'Pickup' ? Mode.PICKUP : Mode.DROP,
                changeMode:
                    _selectedRoutes.length ==
                        context.read<VehicleProvider>().routes.length
                    ? 'ALL'
                    : 'ROUTE',
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Time Change'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Dropdown(
              title: 'Select Mode',
              value: _mode,
              required: true,
              filled: true,
              onChanged: _onModeChanged,
              items: getDropDownMenuItems(['Pickup', 'Drop']),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [Expanded(child: _buildContent())]),
      ),
    );
  }
}

/// A stateless widget to display the list of routes with checkboxes.
class _RouteList extends StatelessWidget {
  const _RouteList({
    required this.filteredRoutes,
    required this.selectedRoutes,
    required this.isAllFilteredSelected,
    required this.onSelectAll,
    required this.onRouteToggled,
  });

  final List<Routee> filteredRoutes;
  final bool isAllFilteredSelected;
  final Function(bool, int) onRouteToggled;
  final ValueChanged<bool?> onSelectAll;
  final Set<int> selectedRoutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        CheckboxListTile(
          title: Text(
            'Select All',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          value: isAllFilteredSelected,
          onChanged: onSelectAll,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: theme.colorScheme.primary,
        ),
        const Divider(),
        ...filteredRoutes.map((item) {
          final isSelected = selectedRoutes.contains(item.id);
          return CheckboxListTile(
            title: Text(item.routeNo),
            value: isSelected,
            onChanged: (_) => onRouteToggled(isSelected, item.id),
          );
        }),
      ],
    );
  }
}

/// A stateless widget to show when a list is empty.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
