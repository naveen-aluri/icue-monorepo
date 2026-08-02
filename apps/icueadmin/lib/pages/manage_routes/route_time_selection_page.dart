import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/routes.dart';
import '../../providers/vehicle_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/injectable.dart';
import '../../utils/app_utils.dart';
import '../../widgets/inputfield.dart';

class RouteTimeSelectionPage extends StatefulWidget {
  const RouteTimeSelectionPage({
    super.key,
    required this.selectedRoutes,
    required this.mode,
    required this.changeMode,
  });
  final List<int> selectedRoutes;
  final Mode mode;
  final String changeMode;

  @override
  State<RouteTimeSelectionPage> createState() => _RouteTimeSelectionPageState();
}

class _RouteTimeSelectionPageState extends State<RouteTimeSelectionPage> {
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay? time;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'route-time-selection-page',
      parameters: {
        'mode': widget.mode.name,
        'selectedRoutes': widget.selectedRoutes.join(', '),
        'changeMode': widget.changeMode,
      },
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Select Time')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.05,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.mode == Mode.PICKUP
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.mode == Mode.PICKUP
                                  ? 'Pickup Mode'
                                  : 'Drop Mode',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Selected Routes: ${widget.selectedRoutes.length}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              InputField(
                label: 'Time',
                showTitle: false,
                hintText: 'Select Time',
                filled: false,
                initialValue: '',
                controller: _timeController,
                type: TextFieldType.timePicker,
                onTap: () async {
                  final selectedTime = await AppUtils.selectTime(
                    context: context,
                    initialTime: time,
                  );
                  if (selectedTime != null) {
                    setState(() {
                      time = selectedTime;
                      _timeController.text = selectedTime.format(context);
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _timeController.text.isEmpty
                    ? null
                    : () {
                        final selectedTime = time!;
                        Provider.of<VehicleProvider>(
                          context,
                          listen: false,
                        ).changeRouteTime(
                          context: context,
                          time: selectedTime.to24hours(),
                          mode: widget.mode,
                          changeMode: widget.changeMode,
                          selected: widget.selectedRoutes,
                        );
                      },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Update'),
              ),
              if (_timeController.text.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Please select a time before updating',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
