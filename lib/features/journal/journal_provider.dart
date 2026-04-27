import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/global_providers.dart';
import '../../core/models/journal_entry.dart';

part 'journal_provider.g.dart';

@riverpod
class JournalEntries extends _$JournalEntries {
  @override
  FutureOr<List<JournalEntry>> build() async {
    return await ref.watch(journalRepositoryProvider).getAllEntries();
  }

  Future<JournalEntry?> saveEntry({
    required String content,
    required int mood,
    required int energy,
    List<String> tags = const [],
    String? voiceTranscription,
  }) async {
    state = const AsyncLoading();
    try {
      final entry = JournalEntry(
        content: content,
        mood: mood,
        energy: energy,
        tags: tags,
        voiceTranscription: voiceTranscription,
      );
      await ref.read(journalRepositoryProvider).saveEntry(entry);
      ref.invalidateSelf(); 
      return entry;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await ref.read(journalRepositoryProvider).deleteEntry(id);
      ref.invalidateSelf();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<String?> generateReflection({
    required String content,
    required int mood,
    required int energy,
  }) async {
    try {
      return await ref.read(aiServiceProvider).generateReflection(
        entryContent: content,
        mood: mood.toInt(),
        energy: energy.toInt(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> updateEntryWithReflection(String entryId, String reflection) async {
      final entry = await ref.read(journalRepositoryProvider).getEntryById(entryId);
      if (entry != null) {
        final updated = entry.copyWith(aiReflection: reflection);
        await ref.read(journalRepositoryProvider).saveEntry(updated);
        ref.invalidateSelf();
      }
  }
}
