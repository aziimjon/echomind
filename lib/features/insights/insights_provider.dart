import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/global_providers.dart';
import '../../core/models/insight.dart';
import '../../core/models/journal_entry.dart';

/// Immutable state for Insights screen
class InsightsState {
  final List<Insight> insights;
  final List<JournalEntry> entries;
  final Map<String, int> tagFrequency;
  final List<double> weeklyMoods;
  final List<double> weeklyEnergy;
  final List<String> weeklyLabels;
  final double averageMood;
  final double averageEnergy;
  final bool isAnalyzing;
  final String? patternAnalysis;

  const InsightsState({
    this.insights = const [],
    this.entries = const [],
    this.tagFrequency = const {},
    this.weeklyMoods = const [0, 0, 0, 0, 0, 0, 0],
    this.weeklyEnergy = const [0, 0, 0, 0, 0, 0, 0],
    this.weeklyLabels = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.averageMood = 0,
    this.averageEnergy = 0,
    this.isAnalyzing = false,
    this.patternAnalysis,
  });

  InsightsState copyWith({
    List<Insight>? insights,
    List<JournalEntry>? entries,
    Map<String, int>? tagFrequency,
    List<double>? weeklyMoods,
    List<double>? weeklyEnergy,
    List<String>? weeklyLabels,
    double? averageMood,
    double? averageEnergy,
    bool? isAnalyzing,
    String? patternAnalysis,
  }) {
    return InsightsState(
      insights: insights ?? this.insights,
      entries: entries ?? this.entries,
      tagFrequency: tagFrequency ?? this.tagFrequency,
      weeklyMoods: weeklyMoods ?? this.weeklyMoods,
      weeklyEnergy: weeklyEnergy ?? this.weeklyEnergy,
      weeklyLabels: weeklyLabels ?? this.weeklyLabels,
      averageMood: averageMood ?? this.averageMood,
      averageEnergy: averageEnergy ?? this.averageEnergy,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      patternAnalysis: patternAnalysis ?? this.patternAnalysis,
    );
  }
}

/// Insights notifier — loads data and generates AI patterns
class InsightsNotifier extends Notifier<InsightsState> {
  @override
  InsightsState build() {
    return const InsightsState();
  }

  Future<void> loadInsights() async {
    try {
      final insights = await ref.read(insightRepositoryProvider).getAllInsights();
      final entries = await ref.read(journalRepositoryProvider).getAllEntries();
      final moodLogs = await ref.read(journalRepositoryProvider).getRecentMoodLogs(limit: 30);

      // Calculate tag frequency
      final freq = <String, int>{};
      for (final entry in entries) {
        for (final tag in entry.tags) {
          freq[tag] = (freq[tag] ?? 0) + 1;
        }
      }
      final sortedFreq = Map.fromEntries(
        freq.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );

      // Calculate weekly chart data
      final weeklyMoods = <double>[];
      final weeklyEnergy = <double>[];
      final weeklyLabels = <String>[];

      final now = DateTime.now();
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayStart = DateTime(day.year, day.month, day.day);
        final dayEnd = dayStart.add(const Duration(days: 1));

        final dayLogs = moodLogs.where((m) =>
            m.createdAt.isAfter(dayStart) && m.createdAt.isBefore(dayEnd));

        if (dayLogs.isNotEmpty) {
          weeklyMoods.add(
            dayLogs.map((m) => m.mood.toDouble()).reduce((a, b) => a + b) /
                dayLogs.length,
          );
          weeklyEnergy.add(
            dayLogs.map((m) => m.energy.toDouble()).reduce((a, b) => a + b) /
                dayLogs.length,
          );
        } else {
          weeklyMoods.add(0);
          weeklyEnergy.add(0);
        }

        weeklyLabels.add(weekdays[day.weekday - 1]);
      }

      // Averages
      double avgMood = 0;
      double avgEnergy = 0;
      if (moodLogs.isNotEmpty) {
        avgMood = moodLogs.map((m) => m.mood.toDouble()).reduce((a, b) => a + b) /
            moodLogs.length;
        avgEnergy = moodLogs.map((m) => m.energy.toDouble()).reduce((a, b) => a + b) /
            moodLogs.length;
      }

      // Check for existing pattern analysis
      String? patternAnalysis;
      final patternInsights =
          insights.where((i) => i.type == 'pattern').toList();
      if (patternInsights.isNotEmpty) {
        patternAnalysis = patternInsights.first.content;
      }

      state = InsightsState(
        insights: insights,
        entries: entries,
        tagFrequency: sortedFreq,
        weeklyMoods: weeklyMoods,
        weeklyEnergy: weeklyEnergy,
        weeklyLabels: weeklyLabels,
        averageMood: avgMood,
        averageEnergy: avgEnergy,
        patternAnalysis: patternAnalysis,
      );
    } catch (e) {
      // Keep default state on error
    }
  }

  Future<void> generatePatternAnalysis() async {
    if (state.entries.isEmpty) return;

    state = state.copyWith(isAnalyzing: true);

    try {
      final entryData = state.entries.take(10).map((e) {
        return <String, dynamic>{
          'content': e.content,
          'mood': e.mood,
          'energy': e.energy,
        };
      }).toList();

      final analysis =
          await ref.read(aiServiceProvider).generatePatternAnalysis(
                recentEntries: entryData,
              );

      final insight = Insight(
        title: 'Pattern Analysis',
        content: analysis,
        type: 'pattern',
      );
      await ref.read(insightRepositoryProvider).saveInsight(insight);

      state = state.copyWith(
        isAnalyzing: false,
        patternAnalysis: analysis,
      );
    } catch (e) {
      state = state.copyWith(isAnalyzing: false);
    }
  }
}

final insightsNotifierProvider =
    NotifierProvider<InsightsNotifier, InsightsState>(InsightsNotifier.new);
