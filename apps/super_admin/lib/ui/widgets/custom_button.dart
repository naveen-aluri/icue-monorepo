import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color> gradientColors;
  final IconData? icon;
  final bool isOutlined;
  final Color? outlineColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradientColors = const [Color(0xFF6C63FF), Color(0xFF3F3D56)],
    this.icon,
    this.isOutlined = false,
    this.outlineColor,
    this.height = 56.0,
    this.borderRadius = 16.0,
    this.fontSize = 16.0,
    this.textColor = Colors.white,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final hasCallback = widget.onPressed != null && !widget.isLoading;
    final fallbackOutlineColor = widget.outlineColor ?? Colors.white24;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: hasCallback ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isOutlined
                ? Border.all(
                    color: hasCallback ? fallbackOutlineColor : Colors.white10,
                    width: 1.5,
                  )
                : null,
            gradient: widget.isOutlined
                ? null
                : LinearGradient(
                    colors: hasCallback
                        ? widget.gradientColors
                        : [Colors.grey.shade800, Colors.grey.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            boxShadow: hasCallback && !widget.isOutlined
                ? [
                    BoxShadow(
                      color: widget.gradientColors.first.withValues(
                        alpha: 0.35,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isOutlined
                            ? (widget.outlineColor ?? const Color(0xFF6C63FF))
                            : Colors.white,
                      ),
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: hasCallback
                              ? (widget.isOutlined
                                    ? (widget.outlineColor ?? Colors.white)
                                    : Colors.white)
                              : Colors.white30,
                          size: widget.fontSize + 4,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: hasCallback
                              ? (widget.isOutlined
                                    ? (widget.outlineColor ?? widget.textColor)
                                    : widget.textColor)
                              : Colors.white30,
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
