import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'chat_message.g.dart';

/// Represents a single chat message in an AI therapy session
@collection
@Name("ChatMessage")
class ChatMessage {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String id = const Uuid().v4();

  @Index()
  String sessionId;

  @Index()
  String content;

  bool isUser;

  @Index()
  String sessionType; // e.g. 'Anxiety Relief', 'Free Talk'

  @Index()
  DateTime createdAt = DateTime.now();

  ChatMessage({
    this.isarId = Isar.autoIncrement,
    required this.sessionId,
    required this.content,
    required this.isUser,
    required this.sessionType,
  });
}
