import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/ai_prompts.dart';

/// Service abstraction for full on-device AI inference using flutter_gemma!
/// 100% Private. 0% Cloud.
class AIService {
  static AIService? _instance;
  bool _isInitialized = false;
  
  // Suggested HuggingFace model link (Gemma-3-1B-IT LiteRT / int4 Quantized) ~ 1.2 GB
  // Note: For real world use, replace with exact HF model URL or release bucket
  static const String _modelUrl = 'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/model.litert';
  static const String _modelFileName = 'gemma-3-1b-it.litert';

  dio.CancelToken? _cancelToken;

  AIService._();

  static AIService get instance {
    _instance ??= AIService._();
    return _instance!;
  }

  bool get isInitialized => _isInitialized;

  /// Returns the absolute path where the model should be stored
  Future<String> get _modelPath async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_modelFileName';
  }

  /// Checks if the model exists on the device locally
  Future<bool> isModelDownloaded() async {
    final path = await _modelPath;
    return File(path).existsSync();
  }

  /// Download the model with a progress callback
  Future<void> downloadModel({
    required void Function(double progress) onProgress,
  }) async {
    final path = await _modelPath;
    final dioClient = dio.Dio();
    _cancelToken = dio.CancelToken();
    
    try {
      await dioClient.download(
        _modelUrl,
        path,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      
      // Load the model immediately after downloading
      await FlutterGemma.initialize();
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.litertlm,
      ).fromFile(path).install();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to download model: $e');
      if (File(path).existsSync()) {
        File(path).deleteSync(); // Clean up corrupted download
      }
      rethrow;
    }
  }

  /// Cancels an active download
  void cancelDownload() {
    _cancelToken?.cancel("User cancelled the download.");
    _cancelToken = null;
  }

  /// Ensure model is loaded into memory (if it exists)
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    final path = await _modelPath;
    if (File(path).existsSync()) {
      await FlutterGemma.initialize();
      await FlutterGemma.installModel(
        modelType: ModelType.gemmaIt,
        fileType: ModelFileType.litertlm,
      ).fromFile(path).install();
      _isInitialized = true;
    }
  }

  // ─── INFERENCE METHODS ──────────────────────────────────────────────

  /// Generate a reflection for a journal entry using Gemma
  Future<String> generateReflection({
    required String entryContent,
    required int mood,
    required int energy,
  }) async {
    if (!_isInitialized) throw Exception('Model not loaded');

    final prompt = AIPrompts.reflectionPrompt(entryContent, mood, energy);
    
    final model = await FlutterGemma.getActiveModel(maxTokens: 2048);
    final chat = await model.createChat();
    
    await chat.addQueryChunk(
      Message(text: AIPrompts.reflectionSystem, isUser: false),
    );
    await chat.addQueryChunk(
      Message(text: prompt, isUser: true),
    );
    
    final response = await chat.generateChatResponse();
    
    return response ?? "I couldn't reflect on this right now. Please try again.";
  }

  /// Generate daily mirror summary
  Future<String> generateDailyMirror({
    required String todaySummary,
    required int averageMood,
  }) async {
    if (!_isInitialized) throw Exception('Model not loaded');

    final prompt = "User logs abstract: $todaySummary. Avg Mood: $averageMood.";
    
    final model = await FlutterGemma.getActiveModel(maxTokens: 2048);
    final chat = await model.createChat();
    
    await chat.addQueryChunk(
      Message(text: AIPrompts.dailyMirrorSystem, isUser: false),
    );
    await chat.addQueryChunk(
      Message(text: prompt, isUser: true),
    );
    
    final response = await chat.generateChatResponse();
    
    return response ?? "You are doing great today. Keep it up!";
  }

  /// Stream a chat response token-by-token
  Stream<String> streamChatResponse({
    required String userMessage,
    required String sessionType,
    required List<Map<String, String>> history,
  }) async* {
    if (!_isInitialized) throw Exception('Model not loaded');

    final model = await FlutterGemma.getActiveModel(maxTokens: 2048);
    final chat = await model.createChat();

    // Add system message
    await chat.addQueryChunk(
      Message(
        text: '${AIPrompts.chatSystem} \nSession Type Focus: $sessionType',
        isUser: false,
      ),
    );
    
    // Add chat history
    for (final h in history) {
      await chat.addQueryChunk(
        Message(
          text: h['content'] ?? '',
          isUser: h['role'] == 'user',
        ),
      );
    }
    
    // Add current user message
    await chat.addQueryChunk(
      Message(text: userMessage, isUser: true),
    );

    // Stream the response
    await for (final token in chat.generateChatResponseStream()) {
      if (token != null) yield token;
    }
  }

  /// Generate pattern analysis from recent entries
  Future<String> generatePatternAnalysis({
    required List<Map<String, dynamic>> recentEntries,
  }) async {
    if (!_isInitialized) throw Exception('Model not loaded');

    final contextData = recentEntries.map((e) => "Mood: ${e['mood']}, Energy: ${e['energy']}, Content: '${e['content']}'").join(' | ');
    
    final prompt = "Analyze the following user data to find actionable mental-health patterns. Data: $contextData";
    
    final model = await FlutterGemma.getActiveModel(maxTokens: 2048);
    final chat = await model.createChat();
    
    await chat.addQueryChunk(
      Message(
        text: 'You are an analytical AI evaluating psychological patterns. Provide 2-3 brief insights correlating mood, energy, and activities.',
        isUser: false,
      ),
    );
    await chat.addQueryChunk(
      Message(text: prompt, isUser: true),
    );
    
    final response = await chat.generateChatResponse();
    
    return response ?? "Needs more data to generate accurate pattern matching.";
  }

  /// Dispose resources from GPU/Memory
  Future<void> dispose() async {
    if (_isInitialized) {
      // In flutter_gemma, model unloading might not be explicitly required natively if app dies
      // but if the API allows .release() we do it
      // await FlutterGemmaPlugin.instance.release();
    }
    _isInitialized = false;
  }
}
