import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'journal_entry.g.dart';

/// Represents a single journal entry with mood, energy, tags, and AI reflection
@collection
@Name("JournalEntry")
class JournalEntry {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = const Uuid().v4();

  @Index()
  String content;

  String? voiceTranscription;

  @Index()
  int mood; // 1-5

  int energy; // 1-5

  List<String> tags;

  String? aiReflection;

  @Index()
  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  JournalEntry({
    this.isarId = Isar.autoIncrement,
    required this.content,
    this.voiceTranscription,
    required this.mood,
    required this.energy,
    this.tags = const [],
    this.aiReflection,
  });

  /// Create a copy with updated fields
  JournalEntry copyWith({
    Id? isarId,
    String? content,
    String? voiceTranscription,
    int? mood,
    int? energy,
    List<String>? tags,
    String? aiReflection,
  }) {
    final entry = JournalEntry(
      isarId: isarId ?? this.isarId,
      content: content ?? this.content,
      voiceTranscription: voiceTranscription ?? this.voiceTranscription,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      tags: tags ?? this.tags,
      aiReflection: aiReflection ?? this.aiReflection,
    );
    entry.id = id;
    entry.createdAt = createdAt;
    entry.updatedAt = DateTime.now();
    return entry;
  }
}
