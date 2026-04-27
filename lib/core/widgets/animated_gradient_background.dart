import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated gradient background with subtle floating orbs
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      listenable: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1.0 + sin(_controller.value * pi) * 0.5,
                -1.0 + cos(_controller.value * pi) * 0.3,
              ),
              end: Alignment(
                1.0 - sin(_controller.value * pi) * 0.3,
                1.0 - cos(_controller.value * pi) * 0.5,
              ),
              colors: isDark
                  ? [
                      AppColors.darkBackground,
                      const Color(0xFF1A1145),
                      AppColors.darkBackground,
                    ]
                  : [
                      AppColors.lightBackground,
                      const Color(0xFFF0EDFF),
                      const Color(0xFFE8F8F5),
                    ],
            ),
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          // Floating orbs
          if (widget.animate) ...[
            _FloatingOrb(
              controller: _controller,
              color: AppColors.primaryIndigo.withValues(alpha: 0.08),
              size: 200,
              offset: const Offset(0.8, 0.2),
            ),
            _FloatingOrb(
              controller: _controller,
              color: AppColors.accentTeal.withValues(alpha: 0.06),
              size: 160,
              offset: const Offset(0.2, 0.7),
              reversed: true,
            ),
          ],
          widget.child,
        ],
      ),
    );
  }
}

class _FloatingOrb extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  final double size;
  final Offset offset;
  final bool reversed;

  const _FloatingOrb({
    required this.controller,
    required this.color,
    required this.size,
    required this.offset,
    this.reversed = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      listenable: controller,
      builder: (context, child) {
        final value = reversed ? 1.0 - controller.value : controller.value;
        return Positioned(
          left: MediaQuery.of(context).size.width * offset.dx +
              sin(value * pi * 2) * 30,
          top: MediaQuery.of(context).size.height * offset.dy +
              cos(value * pi * 2) * 20,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color,
                  blurRadius: size * 0.5,
                  spreadRadius: size * 0.1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// AnimatedBuilder helper
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
