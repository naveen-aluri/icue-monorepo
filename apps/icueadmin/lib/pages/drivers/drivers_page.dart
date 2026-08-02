import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/drivers.dart';
import '../../providers/driver_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/inputfield.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  final TextEditingController _searchController = TextEditingController();
  // Use a ValueNotifier to efficiently rebuild only the list on search.
  final ValueNotifier<String> _searchNotifier = ValueNotifier('');

  final ValueNotifier<bool> _showFabNotifier = ValueNotifier(true);

  @override
  void dispose() {
    _searchController.dispose();
    _searchNotifier.dispose();
    _showFabNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch drivers after widget initialization
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<DriverProvider>().getDrivers();
    });

    // Listen to search input changes with debounce
    _searchController.addListener(() {
      _searchNotifier.value = _searchController.text.trim();
    });
  }

  void _onAddDriverPressed() {
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    context.go('/layout.drivers/add-driver');
  }

  Widget _buildAnimatedFab() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showFabNotifier,
      builder: (context, showFab, child) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: showFab ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: showFab ? 1 : 0,
            child: FloatingActionButton.extended(
              onPressed: _onAddDriverPressed,
              label: const Text('Add Driver'),
              icon: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDriverList(List<Driver> allDrivers) {
    if (allDrivers.isEmpty) {
      return const _EmptyState(
        icon: Icons.people_outline,
        message: 'No drivers have been added yet.',
      );
    }
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        final direction = notification.direction;
        if (direction == ScrollDirection.reverse) {
          _showFabNotifier.value = false;
        } else if (direction == ScrollDirection.forward) {
          _showFabNotifier.value = true;
        }
        return true;
      },
      child: ValueListenableBuilder<String>(
        valueListenable: _searchNotifier,
        builder: (context, searchQuery, _) {
          final filteredDrivers = allDrivers
              .where(
                (driver) => driver.firstName.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ),
              )
              .toList();

          if (filteredDrivers.isEmpty) {
            return const _EmptyState(
              icon: Icons.search_off,
              message: 'No drivers found matching your search.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDrivers.length,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemBuilder: (context, index) {
              final driver = filteredDrivers[index];
              return _DriverListItem(driver: driver);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: InputField(
              label: 'Search Driver',
              showTitle: false,
              hintText: 'Search Driver...',
              initialValue: _searchController.text,
              controller: _searchController,
              type: TextFieldType.search,
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
      floatingActionButton: _buildAnimatedFab(),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _buildDriverList(provider.drivers),
    );
  }
}

/// A stateless widget for a single driver card.
class _DriverListItem extends StatelessWidget {
  const _DriverListItem({required this.driver});

  final Driver driver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final licenceStatus = AppUtils.checkLicenseStatus(
      'License',
      driver.licenceExpiryDate.toDate(),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.grey),
        ),
        title: Text(
          '${driver.firstName} ${driver.middleName ?? ''} ${driver.lastName ?? ''}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: licenceStatus == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: _StatusChip(
                  label: licenceStatus,
                  color: theme.colorScheme.error,
                ),
              ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 20),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          context.go('/layout.drivers/driver-info?driverId=${driver.id}');
        },
      ),
    );
  }
}

/// A small, colored chip for displaying status.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// A reusable widget to display for empty states.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
