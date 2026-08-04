import 'package:flutter/material.dart';

enum AttendanceModeOption { manual, sdkLive, sdkPhoto }

class AttendanceModeDialog extends StatelessWidget {
  const AttendanceModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.how_to_reg_rounded,
                color: theme.primaryColor,
                size: 26,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Start Attendance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how you want to take attendance for this section',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildOptionCard(
                context: context,
                icon: Icons.assignment_ind_outlined,
                iconColor: theme.primaryColor,
                title: 'Manual Attendance',
                subtitle:
                    'Mark attendance manually student by student using cards',
                option: AttendanceModeOption.manual,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context: context,
                icon: Icons.videocam_rounded,
                iconColor: const Color(0xFF6366F1),
                title: 'Live Camera Scan',
                subtitle:
                    'Continuous live video sweep across classroom for real-time face matching',
                option: AttendanceModeOption.sdkLive,
                isBadge: true,
                badgeText: 'AUTOMATED',
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                context: context,
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFF0EA5E9),
                title: 'Multi-Photo Group Scan',
                subtitle:
                    'Capture small group snapshots to cover all students with deduplicated matching',
                option: AttendanceModeOption.sdkPhoto,
                isBadge: true,
                badgeText: 'GROUP SCAN',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required AttendanceModeOption option,
    bool isBadge = false,
    String? badgeText,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.pop(context, option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isBadge && badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.deepPurple.shade200,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.primaryColor,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
