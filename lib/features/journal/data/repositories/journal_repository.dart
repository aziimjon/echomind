import 'package:isar/isar.dart';
import '../../../../core/database/isar_data_source.dart';
import '../../../../core/models/journal_entry.dart';
import '../../../../core/models/mood_log.dart';

abstract class JournalRepository {
  Future<List<JournalEntry>> getAllEntries();
  Future<JournalEntry?> getEntryById(String id);
  Future<void> saveEntry(JournalEntry entry);
  Future<void> deleteEntry(String id);
  
  // Mood Log operations
  Future<void> saveMoodLog(MoodLog log);
  Future<List<MoodLog>> getRecentMoodLogs({int limit = 7});
}

class JournalRepositoryImpl implements JournalRepository {
  final IsarDataSource _dataSource;

  JournalRepositoryImpl(this._dataSource);

  @override
  Future<List<JournalEntry>> getAllEntries() async {
    return await _dataSource.db.journalEntrys
        .where()
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Future<JournalEntry?> getEntryById(String id) async {
    return await _dataSource.db.journalEntrys
        .where()
        .idEqualTo(id)
        .findFirst();
  }

  @override
  Future<void> saveEntry(JournalEntry entry) async {
    await _dataSource.db.writeTxn(() async {
      await _dataSource.db.journalEntrys.put(entry);
    });
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _dataSource.db.writeTxn(() async {
      await _dataSource.db.journalEntrys.where().idEqualTo(id).deleteAll();
    });
  }

  @override
  Future<void> saveMoodLog(MoodLog log) async {
    await _dataSource.db.writeTxn(() async {
      await _dataSource.db.moodLogs.put(log);
    });
  }

  @override
  Future<List<MoodLog>> getRecentMoodLogs({int limit = 7}) async {
    return await _dataSource.db.moodLogs
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }
}
