import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'mood_log.g.dart';

/// Represents a mood log entry for tracking daily mood check-ins
@collection
@Name("MoodLog")
class MoodLog {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = const Uuid().v4();

  @Index()
  int mood; // 1-5

  int energy; // 1-5

  @Index()
  String? note;

  @Index()
  DateTime createdAt = DateTime.now();

  MoodLog({
    this.isarId = Isar.autoIncrement,
    required this.mood,
    required this.energy,
    this.note,
  });
}
