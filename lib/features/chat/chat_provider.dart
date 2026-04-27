import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/global_providers.dart';
import '../../core/models/chat_message.dart';
import 'package:uuid/uuid.dart';

/// Immutable state for the chat session
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String streamedResponse;
  final String sessionType;
  final String sessionId;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.streamedResponse = '',
    this.sessionType = 'Free Talk',
    this.sessionId = '',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? streamedResponse,
    String? sessionType,
    String? sessionId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      streamedResponse: streamedResponse ?? this.streamedResponse,
      sessionType: sessionType ?? this.sessionType,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

/// Chat notifier managing AI therapy sessions
class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(sessionId: const Uuid().v4());
  }

  void startNewSession(String type) {
    state = ChatState(
      sessionType: type,
      sessionId: const Uuid().v4(),
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      sessionId: state.sessionId,
      content: content.trim(),
      isUser: true,
      sessionType: state.sessionType,
    );

    // Optimistic UI update
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
      streamedResponse: '',
    );

    await ref.read(chatRepositoryProvider).saveMessage(userMessage);

    try {
      final historyRaw = state.messages.take(20).map((m) {
        return <String, String>{
          'role': m.isUser ? 'user' : 'assistant',
          'content': m.content,
        };
      }).toList();

      final stream = ref.read(aiServiceProvider).streamChatResponse(
        userMessage: content.trim(),
        sessionType: state.sessionType,
        history: historyRaw,
      );

      String accumulatedResponse = '';

      await for (final token in stream) {
        accumulatedResponse += token;
        state = state.copyWith(streamedResponse: accumulatedResponse);
      }

      final aiMessage = ChatMessage(
        sessionId: state.sessionId,
        content: accumulatedResponse,
        isUser: false,
        sessionType: state.sessionType,
      );

      await ref.read(chatRepositoryProvider).saveMessage(aiMessage);

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isTyping: false,
        streamedResponse: '',
      );
    } catch (e) {
      final errorMsg = ChatMessage(
        sessionId: state.sessionId,
        content: "I'm having trouble responding right now. Please try again.",
        isUser: false,
        sessionType: state.sessionType,
      );
      await ref.read(chatRepositoryProvider).saveMessage(errorMsg);
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isTyping: false,
        streamedResponse: '',
      );
    }
  }
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
