import 'package:flutter_test/flutter_test.dart';
import 'package:icueadmin/models/role_actions.dart';

void main() {
  group('RoleActions JSON parsing for Exam Mgmt', () {
    final actionsJson = [
      {
        'Id': 265,
        'Name': 'Exam Mgmt - Admin App',
        'DisplayName': 'Exam Mgmt',
        'RouteState': 'layout.exams',
        'Icon':
            'https://stgthnxdev.blob.core.windows.net/appimgs/Attendance.png',
        'TabOrder': 1,
        'SubActions': true,
        'SubActionItems': [
          {
            'Id': 266,
            'Name': 'Marks Entry - Admin App',
            'DisplayName': 'Marks Entry',
            'RouteState': 'layout.marksentry',
            'Icon':
                'https://stgthnxdev.blob.core.windows.net/appimgs/Attendance.png',
            'TabOrder': 1,
          },
          {
            'Id': 267,
            'Name': 'Results - Admin App',
            'DisplayName': 'Results',
            'RouteState': 'layout.exam_results',
            'Icon':
                'https://stgthnxdev.blob.core.windows.net/appimgs/Attendance.png',
            'TabOrder': 2,
          },
        ],
      },
    ];

    test('parses exam actions and sub-actions correctly', () {
      final actions = actionsJson.map((x) => RoleActions.fromJson(x)).toList();

      expect(actions.length, equals(1));
      final examMgmt = actions.first;
      expect(examMgmt.id, equals(265));
      expect(examMgmt.name, equals('Exam Mgmt - Admin App'));
      expect(examMgmt.displayName, equals('Exam Mgmt'));
      expect(examMgmt.routeState, equals('layout.exams'));
      expect(
        examMgmt.icon,
        equals(
          'https://stgthnxdev.blob.core.windows.net/appimgs/Attendance.png',
        ),
      );
      expect(examMgmt.tabOrder, equals(1));
      expect(examMgmt.subActions, isTrue);

      expect(examMgmt.subActionItems, isNotNull);
      expect(examMgmt.subActionItems!.length, equals(2));

      final marksEntry = examMgmt.subActionItems![0];
      expect(marksEntry.id, equals(266));
      expect(marksEntry.name, equals('Marks Entry - Admin App'));
      expect(marksEntry.displayName, equals('Marks Entry'));
      expect(marksEntry.routeState, equals('layout.marksentry'));
      expect(marksEntry.tabOrder, equals(1));

      final results = examMgmt.subActionItems![1];
      expect(results.id, equals(267));
      expect(results.name, equals('Results - Admin App'));
      expect(results.displayName, equals('Results'));
      expect(results.routeState, equals('layout.exam_results'));
      expect(results.tabOrder, equals(2));
    });

    test('roundtrips through toJson()', () {
      final examMgmt = RoleActions.fromJson(actionsJson.first);
      final jsonMap = examMgmt.toJson();
      final roundtripped = RoleActions.fromJson(jsonMap);

      expect(roundtripped.id, equals(examMgmt.id));
      expect(roundtripped.name, equals(examMgmt.name));
      expect(roundtripped.routeState, equals(examMgmt.routeState));
      expect(roundtripped.subActions, isTrue);
      expect(roundtripped.subActionItems?.length, equals(2));
      expect(
        roundtripped.subActionItems?.first.routeState,
        equals('layout.marksentry'),
      );
    });
  });
}
