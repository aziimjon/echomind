import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'settings_provider.dart';

/// Settings screen: theme, data management, privacy, about
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsScreenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Appearance ─────────────────────────────────
            const _SectionHeader(title: 'Appearance'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    title: 'Light',
                    isSelected:
                        settings.themeMode == AppThemeMode.light,
                    onTap: () => ref
                        .read(settingsScreenProvider.notifier)
                        .setThemeMode(AppThemeMode.light),
                  ),
                  _divider(context),
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark',
                    isSelected:
                        settings.themeMode == AppThemeMode.dark,
                    onTap: () => ref
                        .read(settingsScreenProvider.notifier)
                        .setThemeMode(AppThemeMode.dark),
                  ),
                  _divider(context),
                  _ThemeOption(
                    icon: Icons.spa_rounded,
                    title: 'Calm Mode',
                    subtitle: 'Extra soft colors for relaxation',
                    isSelected:
                        settings.themeMode == AppThemeMode.calm,
                    onTap: () => ref
                        .read(settingsScreenProvider.notifier)
                        .setThemeMode(AppThemeMode.calm),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── AI Model ───────────────────────────────────
            const _SectionHeader(title: 'AI Model'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.memory_rounded,
                    title: 'Model',
                    trailing: Text(
                      'Gemma 3 1B-IT',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.accentTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _divider(context),
                  _SettingsRow(
                    icon: Icons.download_rounded,
                    title: 'Download Model',
                    subtitle: 'Gemma-3 1B-IT (~1.2 GB)',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                    ),
                    onTap: () {
                      _showModelDownloadDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── Data Management ────────────────────────────
            const _SectionHeader(title: 'Data & Privacy'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.file_upload_outlined,
                    title: 'Export Data',
                    subtitle: 'Save all entries as JSON',
                    trailing: settings.isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                    onTap: () async {
                      final data = await ref
                          .read(settingsScreenProvider.notifier)
                          .exportData();
                      if (data != null && context.mounted) {
                        final json =
                            const JsonEncoder.withIndent('  ')
                                .convert(data);
                        await Clipboard.setData(
                            ClipboardData(text: json));
                        if (context.mounted) {
                          context.showSnack(
                              'Data copied to clipboard! Paste it into a file to save.');
                        }
                      }
                    },
                  ),
                  _divider(context),
                  _SettingsRow(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Your data never leaves your device',
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                    ),
                    onTap: () {
                      _showPrivacyPolicy(context);
                    },
                  ),
                  _divider(context),
                  _SettingsRow(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete All Data',
                    subtitle: 'This cannot be undone',
                    iconColor: Colors.red,
                    titleColor: Colors.red,
                    onTap: () {
                      _showDeleteConfirmation(context, ref);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ─── About ──────────────────────────────────────
            const _SectionHeader(title: 'About'),
            const SizedBox(height: 12),
            GlassCard(
              child: Column(
                children: [
                  const _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    title: 'EchoMind',
                    subtitle: 'Version 1.0.0',
                  ),
                  _divider(context),
                  const _SettingsRow(
                    icon: Icons.code_rounded,
                    title: 'Built with',
                    subtitle: 'Flutter + On-Device AI',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Made with 💜 for your mental wellbeing',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 52,
      color: context.colorScheme.onSurface.withValues(alpha: 0.06),
    );
  }

  void _showModelDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Download AI Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To enable real on-device AI, download the Gemma-3 1B model (~1.2 GB).',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'This feature will be available in a future update. Currently using demo mode with mock responses.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Privacy Policy',
                    style: context.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  const _PolicySection(
                    title: '🔒 100% On-Device',
                    content:
                        'All your data — journal entries, mood logs, chat conversations, and AI-generated insights — is stored exclusively on your device. Nothing is ever uploaded to any server.',
                  ),
                  const _PolicySection(
                    title: '🤖 On-Device AI',
                    content:
                        'All AI processing happens directly on your device. The language model runs locally, meaning your thoughts and feelings are never sent to any cloud service for processing.',
                  ),
                  const _PolicySection(
                    title: '📊 No Analytics',
                    content:
                        'EchoMind does not collect any usage analytics, crash reports, or behavioral data. Your usage patterns are entirely private.',
                  ),
                  const _PolicySection(
                    title: '🗑️ Data Deletion',
                    content:
                        'You can delete all your data at any time from Settings. When deleted, all data is permanently removed from your device with no backups.',
                  ),
                  const _PolicySection(
                    title: '📤 Data Export',
                    content:
                        'You can export all your data in JSON format at any time. Your data belongs to you, and you should always have access to it.',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your journal entries, mood logs, chat history, and insights. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(settingsScreenProvider.notifier)
                  .deleteAllData();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All data deleted'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.primaryIndigo
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primaryIndigo
                              : null,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryIndigo,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ??
                  Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: titleColor,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}
