import 'package:isar/isar.dart';
import '../../../../core/database/isar_data_source.dart';
import '../../../../core/models/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getSessionHistory(String sessionType, {int limit = 50});
  Future<void> saveMessage(ChatMessage message);
  Future<void> clearSessionHistory(String sessionType);
}

class ChatRepositoryImpl implements ChatRepository {
  final IsarDataSource _dataSource;

  ChatRepositoryImpl(this._dataSource);

  @override
  Future<List<ChatMessage>> getSessionHistory(String sessionType, {int limit = 50}) async {
    return await _dataSource.db.chatMessages
        .where()
        .sessionTypeEqualTo(sessionType)
        .sortByCreatedAt()
        .limit(limit)
        .findAll();
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    await _dataSource.db.writeTxn(() async {
      await _dataSource.db.chatMessages.put(message);
    });
  }

  @override
  Future<void> clearSessionHistory(String sessionType) async {
    await _dataSource.db.writeTxn(() async {
      await _dataSource.db.chatMessages
          .where()
          .sessionTypeEqualTo(sessionType)
          .deleteAll();
    });
  }
}
