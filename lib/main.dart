import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'router/app_shell.dart';
import 'core/providers/global_providers.dart';
import 'features/onboarding/model_download_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: EchoMindApp(),
    ),
  );
}

class EchoMindApp extends ConsumerWidget {
  const EchoMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(currentThemeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(AppThemeMode.light),
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      home: const _AppEntryPoint(),
    );
  }
}

/// Handles initialization (Isar) → Splash → Onboarding → Main Flow
class _AppEntryPoint extends ConsumerStatefulWidget {
  const _AppEntryPoint();

  @override
  ConsumerState<_AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends ConsumerState<_AppEntryPoint>
    with SingleTickerProviderStateMixin {
  bool _isInitDone = false;
  bool _isModelReady = false;
  late AnimationController _splashFadeController;

  @override
  void initState() {
    super.initState();
    _splashFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initApp();
  }

  @override
  void dispose() {
    _splashFadeController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    // 1. Minimum splash time
    final minSplashTime = Future.delayed(const Duration(seconds: 2));

    // 2. Init Isar Database & AI Service inside the global providers
    try {
      final isar = ref.read(isarDataSourceProvider);
      await isar.init();
      
      final ai = ref.read(aiServiceProvider);
      await ai.initialize();
      _isModelReady = await ai.isModelDownloaded();

      final stt = ref.read(voiceServiceProvider);
      await stt.initialize();
    } catch (e) {
      debugPrint('Initialization error: $e');
    }

    // Wait for splash time
    await minSplashTime;

    if (mounted) {
      setState(() {
        _isInitDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitDone) {
      return const _SplashScreen();
    }

    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const _SplashScreen(),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Initialization Error: $e')),
      ),
      data: (settings) {
        if (!settings.onboardingComplete) {
          return OnboardingScreen(onComplete: () {
            ref.read(settingsProvider.notifier).completeOnboarding();
          });
        }
        
        if (!_isModelReady) {
          return const ModelDownloadScreen();
        }
        
        return const AppShell();
      },
    );
  }
}

/// Premium animated splash screen
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1A1145),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF5F3FF),
                    const Color(0xFFEDE9FE),
                    const Color(0xFFE0F2FE),
                  ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SlideTransition(
              position: _textSlide,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    Text(
                      'EchoMind',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Private Mental Mirror',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            FadeTransition(
              opacity: _textOpacity,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
