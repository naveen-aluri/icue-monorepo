import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'analytics_service.dart';

@injectable
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  AnalyticsRouteObserver(this._analyticsService);

  final AnalyticsService _analyticsService;

  @override
  void didPop(Route route, Route? previousRoute) {
    _analyticsService.logScreenDurationIfNeeded();
    _sendScreenView(previousRoute);
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _analyticsService.logScreenDurationIfNeeded();
    _sendScreenView(route);
    super.didPush(route, previousRoute);
  }

  void _sendScreenView(Route<dynamic>? route) {
    if (route is PageRoute) {
      final args = route.settings.arguments;
      String screenName = route.settings.name ?? 'Unknown';

      if (args is Map && args['screenName'] != null) {
        screenName = args['screenName'];
      }

      _analyticsService.logScreenView(screenName: screenName);
    }
  }
}
