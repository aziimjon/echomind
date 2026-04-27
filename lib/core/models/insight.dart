import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'insight.g.dart';

/// Represents an AI-generated insight or pattern summary
@collection
@Name("Insight")
class Insight {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = const Uuid().v4();

  @Index()
  String title;

  @Index()
  String content;

  @Index()
  String type; // 'pattern', 'summary', 'suggestion'

  @Index()
  DateTime createdAt = DateTime.now();

  Insight({
    this.isarId = Isar.autoIncrement,
    required this.title,
    required this.content,
    required this.type,
  });
}
