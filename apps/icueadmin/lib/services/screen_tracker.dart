import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'analytics_service.dart';

class ScreenTracker extends StatefulWidget {
  const ScreenTracker({
    super.key,
    required this.child,
    required this.screenName,
    this.parameters,
  });

  final Widget child;
  final Map<String, dynamic>? parameters;
  final String screenName;

  @override
  State<ScreenTracker> createState() => _ScreenTrackerState();
}

class _ScreenTrackerState extends State<ScreenTracker> {
  late final AnalyticsService _analytics;

  @override
  void dispose() {
    _analytics.logScreenDurationIfNeeded();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _analytics = Provider.of<AnalyticsService>(context, listen: false);
    _analytics.logScreenView(
      screenName: widget.screenName,
      parameters: widget.parameters,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(top: false, child: widget.child);
  }
}
