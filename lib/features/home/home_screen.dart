import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/mood_picker.dart';
import '../../core/widgets/shimmer_loading.dart';
import 'home_provider.dart';

/// Main dashboard screen with mood check-in, streak, AI mirror, quick entry
class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onNewEntry;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenInsights;

  const HomeScreen({
    super.key,
    required this.onNewEntry,
    required this.onOpenChat,
    required this.onOpenInsights,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(dashboardProvider.future),
          color: AppColors.primaryIndigo,
          child: FadeTransition(
            opacity: _fadeController,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),

                dashboardAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: ShimmerLoading(height: 200, borderRadius: 16),
                    ),
                  ),
                  error: (error, stack) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Could not load dashboard data.\n${error.toString()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colorScheme.error),
                        ),
                      ),
                    ),
                  ),
                  data: (dashboard) => SliverList.list(
                    children: [
                       _buildMoodCheckIn(context, dashboard),
                       _buildStatsRow(context, dashboard),
                       _buildDailyMirror(context, dashboard),
                       _buildQuickActions(context),
                       _buildRecentEntries(context, dashboard),
                       const SizedBox(height: 100),
                    ]
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = 'Good Morning';
      emoji = '☀️';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '🌤️';
    } else if (hour < 21) {
      greeting = 'Good Evening';
      emoji = '🌅';
    } else {
      greeting = 'Good Night';
      emoji = '🌙';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting $emoji',
            style: context.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateTime.now().formatted,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCheckIn(BuildContext context, DashboardState dashboard) {
    if (dashboard.todaysMood != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: GlassCard(
          child: Row(
            children: [
              Text(
                AppConstants.moodEmojis[dashboard.todaysMood!.mood - 1],
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today you feel ${AppConstants.moodLabels[dashboard.todaysMood!.mood - 1]}',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Energy: ${AppConstants.energyLabels[dashboard.todaysMood!.energy - 1]}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.accentTeal,
                size: 28,
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
              'How are you feeling?',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Take a moment to check in with yourself',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            MoodPicker(
              onMoodSelected: (mood) {
                ref.read(dashboardProvider.notifier).logMood(mood.toInt(), 3);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, DashboardState dashboard) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1', // Logic for streak would go here
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Day Streak',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.book_rounded,
                      color: AppColors.accentTeal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${dashboard.recentEntries.length}',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Entries',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMirror(BuildContext context, DashboardState dashboard) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GlassCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: context.isDarkMode
              ? [
                  AppColors.primaryIndigo.withValues(alpha: 0.2),
                  AppColors.accentTeal.withValues(alpha: 0.1),
                ]
              : [
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
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Daily Mirror',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dashboard.dailyMirror != null)
              Text(
                dashboard.dailyMirror!,
                style: context.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Text(
                'Start journaling to receive your personalized daily reflection ✨',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.6,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickActionCard(
                icon: Icons.edit_note_rounded,
                label: 'New Entry',
                color: AppColors.primaryIndigo,
                onTap: widget.onNewEntry,
              ),
              const SizedBox(width: 12),
              _QuickActionCard(
                icon: Icons.chat_bubble_rounded,
                label: 'AI Chat',
                color: AppColors.accentTeal,
                onTap: widget.onOpenChat,
              ),
              const SizedBox(width: 12),
              _QuickActionCard(
                icon: Icons.insights_rounded,
                label: 'Insights',
                color: const Color(0xFF8B5CF6),
                onTap: widget.onOpenInsights,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context, DashboardState dashboard) {
    if (dashboard.recentEntries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: GlassCard(
          child: Column(
            children: [
              Icon(
                Icons.book_outlined,
                size: 48,
                color: context.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No entries yet',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start your journey with your first journal entry',
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
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
            'Recent Entries',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...dashboard.recentEntries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppConstants.moodEmojis[entry.mood - 1],
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            entry.createdAt.relativeLabel,
                            style: context.textTheme.labelMedium?.copyWith(
                              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            entry.createdAt.timeOnly,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        entry.content.length > 120
                            ? '${entry.content.substring(0, 120)}...'
                            : entry.content,
                        style: context.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      if (entry.tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: entry.tags
                              .take(3)
                              .map((tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      tag,
                                      style: context.textTheme.labelSmall?.copyWith(
                                        color: AppColors.primaryIndigo,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
