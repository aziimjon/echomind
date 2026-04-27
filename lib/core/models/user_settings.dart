import 'package:isar/isar.dart';

part 'user_settings.g.dart';

/// Represents global user settings (theme, etc.)
@collection
@Name("UserSettings")
class UserSettings {
  Id isarId = 0; // Single row, so we always use 0

  @Index()
  bool isDarkMode;

  bool onboardingComplete;
  
  bool isModelDownloaded;

  UserSettings({
    this.isarId = 0,
    this.isDarkMode = false,
    this.onboardingComplete = false,
    this.isModelDownloaded = false,
  });
}
