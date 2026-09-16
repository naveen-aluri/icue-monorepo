import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:icueadmin/utils/navigation/app_router.dart';

void main() {
  group('AppRouter Route Configuration Tests', () {
    test('contains routes for layout.leaves and layout.homeassignments', () {
      final routes = appRouter.configuration.routes;
      expect(routes.isNotEmpty, isTrue);

      // Search all routes recursively for path matching
      bool hasLeavesRoute = false;
      bool hasHomeAssignmentsRoute = false;

      void checkRoutes(List<RouteBase> dynamicRoutes) {
        for (final route in dynamicRoutes) {
          if (route is GoRoute) {
            if (route.path == 'layout.leaves') {
              hasLeavesRoute = true;
            }
            if (route.path == 'layout.homeassignments') {
              hasHomeAssignmentsRoute = true;
            }
          }
          if (route.routes.isNotEmpty) {
            checkRoutes(route.routes);
          }
        }
      }

      checkRoutes(routes);

      expect(
        hasLeavesRoute,
        isTrue,
        reason: 'appRouter should contain layout.leaves route',
      );
      expect(
        hasHomeAssignmentsRoute,
        isTrue,
        reason: 'appRouter should contain layout.homeassignments route',
      );
    });
  });
}
