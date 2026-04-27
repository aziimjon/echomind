import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/mood_picker.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/providers/global_providers.dart';
import 'journal_provider.dart';

/// Journal entry creation screen with rich text, mood/energy sliders, tags, AI reflect & Voice input
class JournalEntryScreen extends ConsumerStatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocus = FocusNode();
  int _mood = 3;
  int _energy = 3;
  final Set<String> _selectedTags = {};
  bool _showReflection = false;
  String? _currentReflection;
  bool _isReflecting = false;
  late AnimationController _animController;
  
  // Voice variables
  bool _isListening = false;
  String _cachedTextBeforeListen = "";

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_contentController.text.trim().isEmpty) {
      context.showSnack('Please write something first', isError: true);
      return;
    }

    final entry = await ref.read(journalEntriesProvider.notifier).saveEntry(
      content: _contentController.text.trim(),
      mood: _mood.toInt(),
      energy: _energy.toInt(),
      tags: _selectedTags.toList(),
    );

    if (entry != null && mounted) {
      context.showSnack('Entry saved ✨');
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _getReflection() async {
    if (_contentController.text.trim().isEmpty) {
      context.showSnack('Write your thoughts first', isError: true);
      return;
    }

    setState(() {
      _showReflection = true;
      _isReflecting = true;
    });

    final reflection = await ref.read(journalEntriesProvider.notifier).generateReflection(
      content: _contentController.text.trim(),
      mood: _mood.toInt(),
      energy: _energy.toInt(),
    );
    
    if (mounted) {
      setState(() {
         _currentReflection = reflection;
         _isReflecting = false;
      });
    }
  }

  void _toggleListening() {
    final stt = ref.read(voiceServiceProvider);
    if (_isListening) {
      stt.stopListening();
      setState(() => _isListening = false);
    } else {
      HapticFeedback.lightImpact();
      _cachedTextBeforeListen = _contentController.text;
      setState(() => _isListening = true);
      
      stt.startListening(
        onResult: (words) {
          setState(() {
            _contentController.text = '$_cachedTextBeforeListen $words'.trim();
          });
        },
        onDone: () {
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryStateAsync = ref.watch(journalEntriesProvider);
    final isSaving = entryStateAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: isSaving ? null : _saveEntry,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: const Text('Save'),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animController,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Text(
                DateTime.now().formattedWithTime,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 20),

              // Content field
              Stack(
                children: [
                  TextField(
                    controller: _contentController,
                    focusNode: _contentFocus,
                    maxLines: null,
                    minLines: 8,
                    textCapitalization: TextCapitalization.sentences,
                    style: context.textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind today?\n\nWrite freely — this stays on your device...',
                      hintStyle: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.3),
                        height: 1.8,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                      contentPadding: const EdgeInsets.only(bottom: 60),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleListening,
                        borderRadius: BorderRadius.circular(24),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: _isListening 
                                ? LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)])
                                : AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              if (_isListening)
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 4,
                                )
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Mood section
              Text(
                'How do you feel?',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              MoodPicker(
                selectedMood: _mood,
                compact: true,
                onMoodSelected: (mood) {
                  HapticFeedback.selectionClick();
                  setState(() => _mood = mood);
                },
              ),

              const SizedBox(height: 24),

              // Energy slider
              Text(
                'Energy Level',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('😴', style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.accentTeal,
                        inactiveTrackColor: AppColors.accentTeal.withValues(alpha: 0.15),
                        thumbColor: AppColors.accentTeal,
                        overlayColor: AppColors.accentTeal.withValues(alpha: 0.1),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: _energy.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() => _energy = v.round());
                        },
                      ),
                    ),
                  ),
                  Text('⚡', style: TextStyle(fontSize: 20)),
                ],
              ),
              Center(
                child: Text(
                  AppConstants.energyLabels[_energy - 1],
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.accentTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tags
              Text(
                'Tags',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.defaultTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryIndigo.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primaryIndigo,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primaryIndigo
                          : context.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              GradientButton(
                text: 'AI Reflect ✨',
                icon: Icons.auto_awesome,
                gradient: AppColors.calmGradient,
                onPressed: _getReflection,
              ),

              if (_showReflection) ...[
                const SizedBox(height: 20),
                if (_isReflecting)
                  const GlassCard(
                    child: ShimmerLoading(
                      height: 80,
                      borderRadius: 12,
                    ),
                  )
                else if (_currentReflection != null)
                  GlassCard(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryIndigo.withValues(alpha: 0.08),
                        AppColors.accentTeal.withValues(alpha: 0.05),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                gradient: AppColors.calmGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'EchoMind Reflection',
                              style: context.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryIndigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _currentReflection!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            height: 1.7,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  )
              ],

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
