import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/chat_message.dart';
import '../models/insight.dart';
import '../models/journal_entry.dart';
import '../models/mood_log.dart';
import '../models/user_settings.dart';

/// Core Isar Data Source handling single database instance and basic CRUD
class IsarDataSource {
  static IsarDataSource? _instance;
  late final Isar db;

  IsarDataSource._();

  static IsarDataSource get instance {
    _instance ??= IsarDataSource._();
    return _instance!;
  }

  /// Initialize the Isar database. Must be called before accessing `db`.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    db = await Isar.open(
      [
        JournalEntrySchema,
        ChatMessageSchema,
        InsightSchema,
        MoodLogSchema,
        UserSettingsSchema,
      ],
      directory: dir.path,
      name: 'echomind_db',
    );
  }

  // ─── Generic CRUD ────────────────────────────────────────────────────────

  Future<int> put<T>(T object) async {
    return await db.writeTxn(() async {
      return await db.collection<T>().put(object);
    });
  }

  Future<List<int>> putAll<T>(List<T> objects) async {
    return await db.writeTxn(() async {
      return await db.collection<T>().putAll(objects);
    });
  }

  Future<T?> get<T>(int id) async {
    return await db.collection<T>().get(id);
  }

  Future<List<T>> getAll<T>() async {
    return await db.collection<T>().where().findAll();
  }

  Future<bool> delete<T>(int id) async {
    return await db.writeTxn(() async {
      return await db.collection<T>().delete(id);
    });
  }

  Future<void> clearAll() async {
    await db.writeTxn(() async {
      await db.clear();
    });
  }
}
