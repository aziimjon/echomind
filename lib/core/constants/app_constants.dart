/// App-wide constants for EchoMind
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'EchoMind';
  static const String appTagline = 'Your Private Mental Mirror';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'echomind.db';
  static const int dbVersion = 1;

  // AI Model
  static const String defaultModelName = 'gemma-3-1b-it';
  static const int maxTokens = 512;
  static const double temperature = 0.7;

  // Mood scale (1-5)
  static const int moodMin = 1;
  static const int moodMax = 5;
  static const List<String> moodLabels = [
    'Terrible',
    'Bad',
    'Okay',
    'Good',
    'Amazing',
  ];
  static const List<String> moodEmojis = ['😢', '😟', '😐', '🙂', '😊'];

  // Energy scale (1-5)
  static const int energyMin = 1;
  static const int energyMax = 5;
  static const List<String> energyLabels = [
    'Exhausted',
    'Low',
    'Moderate',
    'High',
    'Energized',
  ];

  // Journal tags
  static const List<String> defaultTags = [
    'Work',
    'Family',
    'Health',
    'Relationships',
    'Self-care',
    'Gratitude',
    'Anxiety',
    'Growth',
    'Achievement',
    'Nature',
    'Exercise',
    'Sleep',
    'Social',
    'Creative',
    'Stress',
  ];

  // Chat session types
  static const List<String> sessionTypes = [
    'Free Talk',
    'Anxiety Relief',
    'Gratitude Practice',
    'Pattern Discovery',
    'Evening Wind Down',
  ];

  // Onboarding
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themePreferenceKey = 'theme_preference';

  // Animation durations (ms)
  static const int animFast = 200;
  static const int animNormal = 350;
  static const int animSlow = 600;
  static const int animVerySlow = 1000;
}
