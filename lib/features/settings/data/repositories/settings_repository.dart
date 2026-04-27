import '../../../../core/database/isar_data_source.dart';
import '../../../../core/models/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> getSettings();
  Future<void> updateSettings(UserSettings settings);
  Future<void> completeOnboarding();
  Future<void> toggleTheme(bool isDark);
  Future<void> markModelDownloaded();
  Future<void> wipeAllData();
}

class SettingsRepositoryImpl implements SettingsRepository {
  final IsarDataSource _dataSource;

  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<UserSettings> getSettings() async {
    final settings = await _dataSource.db.userSettings.get(0);
    if (settings != null) return settings;

    // Create default settings row if it doesn't exist
    final defaultSettings = UserSettings();
    await _dataSource.db.writeTxn(() async {
      await _dataSource.db.userSettings.put(defaultSettings);
    });
    return defaultSettings;
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    await _dataSource.db.writeTxn(() async {
      await _dataSource.db.userSettings.put(settings);
    });
  }
  
  @override
  Future<void> completeOnboarding() async {
    final settings = await getSettings();
    settings.onboardingComplete = true;
    await updateSettings(settings);
  }
  
  @override
  Future<void> markModelDownloaded() async {
    final settings = await getSettings();
    settings.isModelDownloaded = true;
    await updateSettings(settings);
  }
  
  @override
  Future<void> toggleTheme(bool isDark) async {
    final settings = await getSettings();
    settings.isDarkMode = isDark;
    await updateSettings(settings);
  }

  @override
  Future<void> wipeAllData() async {
    await _dataSource.clearAll();
  }
}
