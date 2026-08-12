import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final T? value;
  final String? labelText;
  final Widget? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final Color dropdownColor;
  final double borderRadius;
  final bool isExpanded;

  const CustomDropdownField({
    super.key,
    required this.value,
    this.labelText,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.validator,
    this.dropdownColor = const Color(0xFF15102A),
    this.borderRadius = 10.0,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      dropdownColor: dropdownColor,
      isExpanded: isExpanded,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
