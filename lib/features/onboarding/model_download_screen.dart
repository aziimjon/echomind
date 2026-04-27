import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/extensions/extensions.dart';
import '../../core/providers/global_providers.dart';
import '../../core/widgets/glass_card.dart';
import '../settings/settings_provider.dart';
import '../../core/widgets/gradient_button.dart';
import '../../router/app_shell.dart';

class ModelDownloadScreen extends ConsumerStatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  ConsumerState<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends ConsumerState<ModelDownloadScreen> {
  double _progress = 0.0;
  bool _isDownloading = false;
  String _statusMessage = 
    'EchoMind operates purely on-device for 100% privacy.\n\n'
    'To begin, we need to securely download your personal AI intelligence engine (~1.2 GB) directly onto your device. No cloud. No tracking.';

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = 'Downloading EchoMind Intelligence...';
    });
    
    try {
      final ai = ref.read(aiServiceProvider);
      await ai.downloadModel(
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _progress = p;
              if (p > 0.5) _statusMessage = 'Halfway there, preparing private neural weights...';
              if (p > 0.9) _statusMessage = 'Finishing up local environment...';
            });
          }
        }
      );
      
      await ref.read(settingsProvider.notifier).markModelDownloaded();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AppShell()));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
          _statusMessage = e.toString().contains('cancelled') 
              ? 'Download cancelled.' 
              : 'Download failed.\nPlease check your connection and storage space, then try again.';
        });
      }
    }
  }

  void _cancelDownload() {
    ref.read(aiServiceProvider).cancelDownload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryIndigo.withValues(alpha: 0.1),
              context.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GlassCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 64,
                      color: AppColors.accentTeal,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Privacy First',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_isDownloading) ...[
                      LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: AppColors.primaryIndigo.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentTeal),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(_progress * 100).toStringAsFixed(1)}%',
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _cancelDownload,
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Cancel Download'),
                      ),
                    ] else
                      GradientButton(
                        text: 'Download AI Model locally',
                        icon: Icons.download_rounded,
                        gradient: AppColors.calmGradient,
                        onPressed: _startDownload,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
