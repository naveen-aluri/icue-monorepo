import 'package:flutter/material.dart';

class KeyboardVisibilityDetector extends StatefulWidget {
  const KeyboardVisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChange,
  });

  final Widget child;
  final void Function(bool visibility) onVisibilityChange;

  @override
  State<KeyboardVisibilityDetector> createState() =>
      _KeyboardVisibilityDetectorState();
}

class _KeyboardVisibilityDetectorState
    extends State<KeyboardVisibilityDetector> {
  bool _isKeyboardVisible = false;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool newKeyboardVisibility = bottomInset > 0.0;

    if (newKeyboardVisibility != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newKeyboardVisibility;
        widget.onVisibilityChange(_isKeyboardVisible);
      });
    }
    return widget.child;
  }
}
