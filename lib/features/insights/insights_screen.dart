import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/shimmer_loading.dart';
import 'insights_provider.dart';

/// Insights & History screen with mood charts, timeline, and AI patterns
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(insightsNotifierProvider.notifier).loadInsights();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(insightsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: ShimmerList(itemCount: 4),
            )
          : FadeTransition(
              opacity: _fadeController,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Overview stats
                  SliverToBoxAdapter(
                    child: _buildOverviewStats(context, provider),
                  ),

                  // Weekly mood chart
                  SliverToBoxAdapter(
                    child: _buildMoodChart(context, provider),
                  ),

                  // Top tags
                  SliverToBoxAdapter(
                    child: _buildTopTags(context, provider),
                  ),

                  // AI Pattern Analysis
                  SliverToBoxAdapter(
                    child: _buildPatternAnalysis(context, provider),
                  ),

                  // Timeline entries
                  SliverToBoxAdapter(
                    child: _buildTimeline(context, provider),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewStats(BuildContext context, InsightsState provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _StatCard(
            label: 'Avg Mood',
            value: provider.averageMood > 0
                ? provider.averageMood.toStringAsFixed(1)
                : '—',
            emoji: provider.averageMood > 0
                ? AppConstants
                    .moodEmojis[(provider.averageMood.round() - 1).clamp(0, 4)]
                : '📊',
            color: AppColors.primaryIndigo,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Avg Energy',
            value: provider.averageEnergy > 0
                ? provider.averageEnergy.toStringAsFixed(1)
                : '—',
            emoji: '⚡',
            color: AppColors.accentTeal,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Entries',
            value: '${provider.entries.length}',
            emoji: '📝',
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context, InsightsState provider) {
    if (provider.weeklyMoods.every((m) => m == 0)) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: GlassCard(
          child: Column(
            children: [
              Icon(Icons.show_chart_rounded,
                  size: 48,
                  color:
                      context.colorScheme.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              Text(
                'Start logging moods to see your weekly chart',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color:
                      context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Mood & Energy',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.06),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value > 5) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            '${value.toInt()}',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 ||
                              idx >= provider.weeklyLabels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              provider.weeklyLabels[idx],
                              style:
                                  context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 5.5,
                  lineBarsData: [
                    // Mood line
                    LineChartBarData(
                      spots: List.generate(
                        7,
                        (i) => FlSpot(
                            i.toDouble(), provider.weeklyMoods[i]),
                      ),
                      isCurved: true,
                      color: AppColors.primaryIndigo,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, xPercentage, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.primaryIndigo,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryIndigo
                            .withValues(alpha: 0.08),
                      ),
                    ),
                    // Energy line
                    LineChartBarData(
                      spots: List.generate(
                        7,
                        (i) => FlSpot(
                            i.toDouble(), provider.weeklyEnergy[i]),
                      ),
                      isCurved: true,
                      color: AppColors.accentTeal,
                      barWidth: 3,
                      dashArray: [6, 4],
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, xPercentage, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.accentTeal,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(
                    color: AppColors.primaryIndigo, label: 'Mood'),
                const SizedBox(width: 24),
                _LegendDot(
                    color: AppColors.accentTeal, label: 'Energy'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTags(BuildContext context, InsightsState provider) {
    final tags = provider.tagFrequency;
    if (tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Used Tags',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.entries.take(8).map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        AppColors.primaryIndigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key,
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryIndigo
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${entry.value}',
                          style:
                              context.textTheme.labelSmall?.copyWith(
                            color: AppColors.primaryIndigo,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternAnalysis(
      BuildContext context, InsightsState provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Pattern Analysis',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (provider.isAnalyzing)
            const GlassCard(
              child: ShimmerLoading(height: 100, borderRadius: 16),
            )
          else if (provider.patternAnalysis != null)
            GlassCard(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryIndigo.withValues(alpha: 0.08),
                  AppColors.accentTeal.withValues(alpha: 0.05),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome,
                            size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Pattern Insights',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    provider.patternAnalysis!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            )
          else
            GradientButton(
              text: 'Analyze Patterns ✨',
              icon: Icons.psychology_rounded,
              gradient: AppColors.calmGradient,
              onPressed: provider.entries.isEmpty
                  ? null
                  : () => ref
                      .read(insightsNotifierProvider.notifier)
                      .generatePatternAnalysis(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, InsightsState provider) {
    if (provider.entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: GlassCard(
          child: Column(
            children: [
              Icon(Icons.timeline_rounded,
                  size: 48,
                  color:
                      context.colorScheme.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              Text(
                'Your journal timeline will appear here',
                style: context.textTheme.bodyMedium?.copyWith(
                  color:
                      context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...provider.entries.take(10).map((entry) {
            final moodColor =
                AppColors.moodColors[(entry.mood - 1).clamp(0, 4)];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline dot and line
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: moodColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: moodColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 80,
                        color: moodColor.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Entry card
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: moodColor.withValues(alpha: 0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppConstants
                                    .moodEmojis[(entry.mood - 1).clamp(0, 4)],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.createdAt.relativeLabel,
                                style: context.textTheme.labelMedium
                                    ?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                entry.createdAt.timeOnly,
                                style: context.textTheme.labelSmall
                                    ?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.content.length > 100
                                ? '${entry.content.substring(0, 100)}...'
                                : entry.content,
                            style: context.textTheme.bodySmall?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }
}
