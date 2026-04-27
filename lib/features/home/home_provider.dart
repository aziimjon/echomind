import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/global_providers.dart';
import '../../core/models/journal_entry.dart';
import '../../core/models/mood_log.dart';

part 'home_provider.g.dart';

class DashboardState {
  final List<JournalEntry> recentEntries;
  final MoodLog? todaysMood;
  final String? dailyMirror;
  
  DashboardState({
    required this.recentEntries,
    required this.todaysMood,
    this.dailyMirror,
  });
}

@riverpod
class Dashboard extends _$Dashboard {
  @override
  FutureOr<DashboardState> build() async {
    final journalRepo = ref.watch(journalRepositoryProvider);
    final allEntries = await journalRepo.getAllEntries();
    final recentEntries = allEntries.take(5).toList();
    
    // Check mood logs
    final recentLogs = await journalRepo.getRecentMoodLogs(limit: 1);
    MoodLog? todaysMood;
    if (recentLogs.isNotEmpty) {
      final lastLog = recentLogs.first;
      if (lastLog.createdAt.day == DateTime.now().day &&
          lastLog.createdAt.month == DateTime.now().month &&
          lastLog.createdAt.year == DateTime.now().year) {
        todaysMood = lastLog;
      }
    }
    
    String? dailyMirror;
    if (recentEntries.isNotEmpty) {
      final ai = ref.read(aiServiceProvider);
      final summary = recentEntries.take(3).map((e) => e.content).join(' | ');
      int sum = 0;
      for (final e in recentEntries) { sum += e.mood; }
      final avgMood = (sum / recentEntries.length).round();
      
      dailyMirror = await ai.generateDailyMirror(
        todaySummary: summary.length > 200 ? summary.substring(0, 200) : summary,
        averageMood: avgMood,
      );
    }

    return DashboardState(
      recentEntries: recentEntries,
      todaysMood: todaysMood,
      dailyMirror: dailyMirror,
    );
  }

  Future<void> logMood(int mood, int energy, {String? note}) async {
    final moodLog = MoodLog(mood: mood, energy: energy, note: note);
    await ref.read(journalRepositoryProvider).saveMoodLog(moodLog);
    ref.invalidateSelf();
  }
}
