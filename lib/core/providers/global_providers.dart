import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/isar_data_source.dart';
import '../services/ai_service.dart';
import '../services/voice_service.dart';
import '../../features/journal/data/repositories/journal_repository.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/insights/data/repositories/insight_repository.dart';
import '../../features/settings/data/repositories/settings_repository.dart';

part 'global_providers.g.dart';

@Riverpod(keepAlive: true)
IsarDataSource isarDataSource(Ref ref) {
  return IsarDataSource.instance;
}

@Riverpod(keepAlive: true)
AIService aiService(Ref ref) {
  return AIService.instance;
}

@Riverpod(keepAlive: true)
VoiceService voiceService(Ref ref) {
  return VoiceService.instance;
}

@Riverpod(keepAlive: true)
JournalRepository journalRepository(Ref ref) {
  return JournalRepositoryImpl(ref.watch(isarDataSourceProvider));
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return ChatRepositoryImpl(ref.watch(isarDataSourceProvider));
}

@Riverpod(keepAlive: true)
InsightRepository insightRepository(Ref ref) {
  return InsightRepositoryImpl(ref.watch(isarDataSourceProvider));
}

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepositoryImpl(ref.watch(isarDataSourceProvider));
}
