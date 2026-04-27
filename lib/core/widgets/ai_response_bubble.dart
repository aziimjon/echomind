import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// AI chat response bubble with typing animation
class AIResponseBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isTyping;
  final DateTime? timestamp;

  const AIResponseBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: EdgeInsets.only(
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
          bottom: 12,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Avatar row for AI messages
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'EchoMind',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryIndigo,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primaryIndigo
                    : isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isTyping
                  ? const _TypingIndicator()
                  : Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isUser
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three-dot typing indicator animation
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = isDark
        ? AppColors.textLightSecondary
        : AppColors.textDarkSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          listenable: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor.withValues(
                    alpha: 0.3 + (_animations[index].value * 0.7)),
                shape: BoxShape.circle,
              ),
              transform: Matrix4.translationValues(
                0,
                -4 * _animations[index].value,
                0,
              ),
            );
          },
        );
      }),
    );
  }
}

/// AnimatedBuilder helper widget
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
