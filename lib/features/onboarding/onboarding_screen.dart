import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/animated_gradient_background.dart';

/// Beautiful 4-page onboarding flow
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.auto_awesome_rounded,
      title: 'Welcome to\nEchoMind',
      subtitle: 'Your private AI journal & mental mirror. A safe space for self-discovery, powered by on-device intelligence.',
      gradient: AppColors.primaryGradient,
    ),
    _OnboardingPage(
      icon: Icons.shield_rounded,
      title: '100% Private.\nAlways.',
      subtitle: 'Everything stays on your device. No cloud uploads, no data collection, no exceptions. Your thoughts belong to you alone.',
      gradient: AppColors.calmGradient,
    ),
    _OnboardingPage(
      icon: Icons.psychology_rounded,
      title: 'AI That\nUnderstands',
      subtitle: 'Get empathetic reflections, discover emotional patterns, and have meaningful conversations — all powered by on-device AI.',
      gradient: AppColors.oceanGradient,
    ),
    _OnboardingPage(
      icon: Icons.favorite_rounded,
      title: 'Let\'s Begin\nYour Journey',
      subtitle: 'Start journaling, check in with your mood, or just talk. EchoMind is here for you, whenever you need it.',
      gradient: AppColors.sunriseGradient,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _currentPage < _pages.length - 1
                      ? TextButton(
                          onPressed: widget.onComplete,
                          child: Text(
                            'Skip',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                          ),
                        )
                      : const SizedBox(height: 48),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    return _OnboardingPageWidget(page: _pages[index]);
                  },
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primaryIndigo
                            : AppColors.primaryIndigo.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Button
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: GradientButton(
                  text: _currentPage == _pages.length - 1
                      ? 'Get Started'
                      : 'Continue',
                  icon: _currentPage == _pages.length - 1
                      ? Icons.arrow_forward_rounded
                      : null,
                  onPressed: _nextPage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: page.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 52,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 20),

          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
