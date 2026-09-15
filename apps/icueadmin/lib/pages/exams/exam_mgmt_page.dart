import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models/role_actions.dart';
import '../../services/hive_service.dart';

class ExamMgmtPage extends StatelessWidget {
  const ExamMgmtPage({super.key});

  static String _findSubActionName(
    List<RoleActions> subActions,
    String routeState,
    String defaultName,
  ) {
    final match = subActions.firstWhereOrNull(
      (a) => a.routeState == routeState,
    );
    return match?.displayName ?? defaultName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Exam Management')),
      body: ValueListenableBuilder(
        valueListenable: HiveService.getActionsByRoleBox.listenable(),
        builder: (context, box, _) {
          final examAction = box.values.firstWhereOrNull(
            (e) => e.routeState == 'layout.exams',
          );
          final subActions = examAction?.subActionItems ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EnterpriseFeatureCard(
                  title: _findSubActionName(
                    subActions,
                    'layout.marksentry',
                    'Marks Entry',
                  ),
                  subtitle:
                      'Rapid score entry with real-time validation, Present, Absent, and NA attendance controls.',
                  badgeText: 'Rapid Entry',
                  badgeColor: const Color(0xFF10B981),
                  icon: Icons.assignment_turned_in_rounded,
                  iconBgColor: const Color(0xFFECFDF5),
                  iconColor: const Color(0xFF059669),
                  onTap: () => context.go('/layout.exams/layout.marksentry'),
                ),

                const SizedBox(height: 12),

                _EnterpriseFeatureCard(
                  title: _findSubActionName(
                    subActions,
                    'layout.exam_results',
                    'Results & Leaderboards',
                  ),
                  subtitle:
                      'Class pass rates, top rankers with gold/silver medals, grade distribution, and subject marks.',
                  badgeText: 'Analytics',
                  badgeColor: const Color(0xFFF59E0B),
                  icon: Icons.military_tech_rounded,
                  iconBgColor: const Color(0xFFFFFBEB),
                  iconColor: const Color(0xFFD97706),
                  onTap: () => context.go('/layout.exams/layout.exam_results'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EnterpriseFeatureCard extends StatelessWidget {
  const _EnterpriseFeatureCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.onTap,
  });

  final Color badgeColor;
  final String badgeText;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String subtitle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
