import 'package:flutter/material.dart';

import '../../data/models/student_model.dart';
import 'glass_card.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTapFingerprint;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTapFingerprint,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto =
        student.photoUrl != null && student.photoUrl!.isNotEmpty;

    // Status accent color based on photo availability
    final Color statusColor = hasPhoto
        ? const Color(0xFF00E5FF)
        : const Color(0xFFFF2A54);

    final initials = student.name
        .trim()
        .split(RegExp(r'\s+'))
        .map((s) => s.isNotEmpty ? s[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    final placeholderColor =
        Colors.primaries[student.id % Colors.primaries.length];

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      bgColor: const Color(0x14FFFFFF),
      bordercolor: statusColor.withValues(alpha: 0.25),
      child: Row(
        children: [
          // Cyber Avatar with Glowing Status Ring
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              // Image / Initials Avatar
              SizedBox(
                width: 58,
                height: 58,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(29),
                  child: hasPhoto
                      ? Image.network(
                          student.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(initials, placeholderColor),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.white.withValues(alpha: 0.05),
                              alignment: Alignment.center,
                              child: const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6C63FF),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : _buildPlaceholder(initials, placeholderColor),
                ),
              ),

              // Status Dot Indicator
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF15102A),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.8),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Student Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),

                // Admission Cyber Tag
                Text(
                  'ID // ${student.admissionNumber}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Standard & Section Tags
                Row(
                  children: [
                    _buildCyberChip(
                      'STD ${student.standard}',
                      const Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 6),
                    _buildCyberChip(
                      'SEC ${student.section}',
                      const Color(0xFF3D5AFE),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Action Fingerprint / Scan Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTapFingerprint,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF8C85FF),
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String initials, Color color) {
    return Container(
      color: color.withValues(alpha: 0.75),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCyberChip(String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accentColor.withValues(alpha: 0.95),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
