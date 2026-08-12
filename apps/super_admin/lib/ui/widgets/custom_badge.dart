import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color? borderColor;

  const CustomBadge({
    super.key,
    required this.label,
    this.textColor = Colors.white70,
    this.bgColor = const Color(
      0x0CFFFFFF,
    ), // Colors.white.withValues(alpha: 0.05)
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.0)
            : Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
