import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// Beautiful animated mood picker with emoji cards
class MoodPicker extends StatefulWidget {
  final int? selectedMood;
  final ValueChanged<int> onMoodSelected;
  final bool compact;

  const MoodPicker({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
    this.compact = false,
  });

  @override
  State<MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<MoodPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final moodIndex = index + 1;
        final isSelected = widget.selectedMood == moodIndex;

        return AnimatedBuilder(
          listenable: _controller,
          builder: (context, child) {
            final delay = index * 0.15;
            final progress = (_controller.value - delay).clamp(0.0, 1.0);
            final scaleValue = Curves.elasticOut.transform(progress);

            return Transform.scale(
              scale: scaleValue,
              child: child,
            );
          },
          child: GestureDetector(
            onTapDown: (_) => setState(() => _hoveredIndex = index),
            onTapUp: (_) {
              setState(() => _hoveredIndex = null);
              HapticFeedback.lightImpact();
              widget.onMoodSelected(moodIndex);
            },
            onTapCancel: () => setState(() => _hoveredIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: widget.compact ? 52 : 62,
              height: widget.compact ? 68 : 82,
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.moodColors[index].withValues(alpha: 0.15)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.7),
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: isSelected
                      ? AppColors.moodColors[index]
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.moodColors[index]
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConstants.moodEmojis[index],
                    style: TextStyle(
                      fontSize: widget.compact ? 24 : 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.moodLabels[index],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppColors.moodColors[index]
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: widget.compact ? 9 : 10,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Reusable AnimatedBuilder helper (avoids naming conflict with Flutter's)
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
