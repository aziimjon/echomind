import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/providers/global_providers.dart';
import '../../core/models/user_settings.dart';
import '../../core/theme/app_theme.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  FutureOr<UserSettings> build() async {
    return await ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> toggleTheme(bool isDark) async {
    await ref.read(settingsRepositoryProvider).toggleTheme(isDark);
    ref.invalidateSelf();
  }
  
  Future<void> completeOnboarding() async {
    await ref.read(settingsRepositoryProvider).completeOnboarding();
    ref.invalidateSelf();
  }

  Future<void> markModelDownloaded() async {
    await ref.read(settingsRepositoryProvider).markModelDownloaded();
    ref.invalidateSelf();
  }

  Future<void> wipeAllData() async {
    state = const AsyncValue.loading();
    await ref.read(settingsRepositoryProvider).wipeAllData();
    ref.invalidateSelf();
  }
}

/// Screen-facing settings notifier with theme mode, export, etc.
class SettingsScreenState {
  final AppThemeMode themeMode;
  final bool isExporting;

  const SettingsScreenState({
    this.themeMode = AppThemeMode.light,
    this.isExporting = false,
  });

  SettingsScreenState copyWith({
    AppThemeMode? themeMode,
    bool? isExporting,
  }) {
    return SettingsScreenState(
      themeMode: themeMode ?? this.themeMode,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}

class SettingsScreenNotifier extends Notifier<SettingsScreenState> {
  @override
  SettingsScreenState build() {
    // Derive theme mode from settings
    final settingsAsync = ref.watch(settingsProvider);
    final isDark = settingsAsync.maybeWhen(
      data: (s) => s.isDarkMode,
      orElse: () => false,
    );
    return SettingsScreenState(
      themeMode: isDark ? AppThemeMode.dark : AppThemeMode.light,
    );
  }

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    ref
        .read(settingsProvider.notifier)
        .toggleTheme(mode == AppThemeMode.dark);
  }

  Future<Map<String, dynamic>?> exportData() async {
    state = state.copyWith(isExporting: true);
    try {
      final entries =
          await ref.read(journalRepositoryProvider).getAllEntries();
      final data = {
        'app': 'EchoMind',
        'exportedAt': DateTime.now().toIso8601String(),
        'entries': entries
            .map((e) => {
                  'content': e.content,
                  'mood': e.mood,
                  'energy': e.energy,
                  'tags': e.tags,
                  'createdAt': e.createdAt.toIso8601String(),
                })
            .toList(),
      };
      state = state.copyWith(isExporting: false);
      return data;
    } catch (e) {
      state = state.copyWith(isExporting: false);
      return null;
    }
  }

  Future<bool> deleteAllData() async {
    try {
      await ref.read(settingsProvider.notifier).wipeAllData();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final settingsScreenProvider =
    NotifierProvider<SettingsScreenNotifier, SettingsScreenState>(
        SettingsScreenNotifier.new);

// Additional provider specifically for theme brightness derived from Settings
@riverpod
AppThemeMode currentThemeMode(CurrentThemeModeRef ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.maybeWhen(
    data: (settings) => settings.isDarkMode ? AppThemeMode.dark : AppThemeMode.light,
    orElse: () => AppThemeMode.light,
  );
}
