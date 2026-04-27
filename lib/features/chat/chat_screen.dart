import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/extensions/extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ai_response_bubble.dart';
import '../../core/widgets/glass_card.dart';
import 'chat_provider.dart';

/// AI Therapy Chat screen with streaming responses and session presets
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('AI Chat'),
            Text(
              chatState.sessionType,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.accentTeal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_session',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('New Session'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'change_type',
                child: Row(
                  children: [
                    Icon(Icons.psychology_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Change Mode'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'new_session') {
                ref
                    .read(chatNotifierProvider.notifier)
                    .startNewSession(chatState.sessionType);
              } else if (value == 'change_type') {
                _showSessionPicker();
              }
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: _buildMessagesList(context, chatState),
            ),

            // Input area
            _buildInputArea(context, chatState),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, ChatState chatState) {
    if (chatState.messages.isEmpty && !chatState.isTyping) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      physics: const BouncingScrollPhysics(),
      itemCount:
          chatState.messages.length + (chatState.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // Streaming response indicator
        if (index == chatState.messages.length && chatState.isTyping) {
          if (chatState.streamedResponse.isNotEmpty) {
            return AIResponseBubble(
              text: chatState.streamedResponse,
              isUser: false,
            );
          }
          return const AIResponseBubble(
            text: '',
            isUser: false,
            isTyping: true,
          );
        }

        final message = chatState.messages[index];
        return AIResponseBubble(
          text: message.content,
          isUser: message.isUser,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose a session',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a conversation style or just talk freely',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 32),

          // Session type cards
          ...AppConstants.sessionTypes.map((type) {
            final icons = {
              'Free Talk': Icons.chat_bubble_outline_rounded,
              'Anxiety Relief': Icons.spa_rounded,
              'Gratitude Practice': Icons.favorite_rounded,
              'Pattern Discovery': Icons.analytics_rounded,
              'Evening Wind Down': Icons.nightlight_rounded,
            };
            final colors = {
              'Free Talk': AppColors.primaryIndigo,
              'Anxiety Relief': AppColors.accentTeal,
              'Gratitude Practice': const Color(0xFFEC4899),
              'Pattern Discovery': const Color(0xFF8B5CF6),
              'Evening Wind Down': const Color(0xFF6366F1),
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () {
                  ref
                      .read(chatNotifierProvider.notifier)
                      .startNewSession(type);
                },
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (colors[type] ?? AppColors.primaryIndigo)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icons[type] ?? Icons.chat,
                        color: colors[type] ?? AppColors.primaryIndigo,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        type,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, ChatState chatState) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                style: context.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface
                        .withValues(alpha: 0.35),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: chatState.isTyping ? null : _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: chatState.isTyping
                    ? null
                    : AppColors.primaryGradient,
                color: chatState.isTyping
                    ? context.colorScheme.onSurface
                        .withValues(alpha: 0.1)
                    : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: chatState.isTyping
                    ? context.colorScheme.onSurface
                        .withValues(alpha: 0.3)
                    : Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionPicker() {
    final chatState = ref.read(chatNotifierProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 20),
              Text(
                'Session Type',
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...AppConstants.sessionTypes.map((type) {
                final isCurrentType = chatState.sessionType == type;
                return ListTile(
                  title: Text(type),
                  leading: Icon(
                    isCurrentType
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color:
                        isCurrentType ? AppColors.primaryIndigo : null,
                    size: 22,
                  ),
                  onTap: () {
                    ref
                        .read(chatNotifierProvider.notifier)
                        .startNewSession(type);
                    Navigator.pop(ctx);
                  },
                );
              }),
              SizedBox(
                  height: MediaQuery.of(ctx).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }
}
