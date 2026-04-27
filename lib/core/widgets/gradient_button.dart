import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Premium gradient button with press animation
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool expanded;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradient,
    this.height = 56,
    this.borderRadius = AppTheme.radiusMedium,
    this.isLoading = false,
    this.expanded = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          height: widget.height,
          width: widget.expanded ? double.infinity : null,
          padding: widget.expanded
              ? null
              : const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            gradient: widget.onPressed != null
                ? (widget.gradient ?? AppColors.primaryGradient)
                : null,
            color: widget.onPressed == null
                ? Theme.of(context).disabledColor.withValues(alpha: 0.2)
                : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color:
                          AppColors.primaryIndigo.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        widget.text,
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
