import 'package:flutter_gemma/flutter_gemma.dart';

import '../core/models/pet_state.dart';
import 'chat_language.dart';
import 'chat_fallback_policy.dart';

/// On-device chat adapter backed by a small LiteRT-LM model when installed.
///
/// The app remains usable without a model file: [send] falls back to a local
/// deterministic companion response. This is important because model files
/// are large binary assets and should be installed explicitly rather than
/// silently downloaded on first launch.
class LocalChatService {
  LocalChatService({this.maxTurns = 12});

  final int maxTurns;
  InferenceChat? _chat;
  bool _initialized = false;
  bool _modelAvailable = false;
  int _turns = 0;
  bool _cancelRequested = false;

  bool get isInitialized => _initialized;
  bool get isModelAvailable => _modelAvailable;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final model = await FlutterGemma.getActiveModel(maxTokens: 1024);
      _chat = await model.createChat(
        temperature: 0.72,
        topK: 32,
        maxOutputTokens: 96,
        systemInstruction: 'You are a warm, concise virtual pet companion. '
            'Reply in the user language. Never claim to be human. '
            'Use the pet status as context and keep replies under 2 short sentences.',
      );
      _modelAvailable = true;
    } catch (_) {
      // No active model yet, or native engine unavailable on this device.
      // The local fallback is the supported first-run experience.
      _chat = null;
      _modelAvailable = false;
    }
  }

  Future<String> send({required PetState pet, required String text}) async {
    if (!_initialized) await init();
    if (_turns >= maxTurns && _chat != null) {
      await _resetChat();
    }
    final chat = _chat;
    if (chat == null) return ChatFallbackPolicy.respond(pet: pet, text: text);

    try {
      _cancelRequested = false;
      final prompt = _contextPrompt(pet, text);
      await chat.addQueryChunk(Message(text: prompt, isUser: true));
      final response = await chat.generateChatResponse();
      if (_cancelRequested) return '';
      final value = switch (response) {
        TextResponse(:final token) => token.trim(),
        ThinkingResponse(:final content) => content.trim(),
        _ => '',
      };
      _turns++;
      return value.isEmpty
          ? ChatFallbackPolicy.respond(pet: pet, text: text)
          : value;
    } catch (_) {
      if (_cancelRequested) return '';
      return ChatFallbackPolicy.respond(pet: pet, text: text);
    }
  }

  /// Cancels an in-flight native generation by closing its session. The next
  /// message lazily creates a fresh session, preventing an unbounded history
  /// or a poisoned native request from blocking the chat UI.
  Future<void> cancelGeneration() async {
    _cancelRequested = true;
    await _closeChat();
    _initialized = false;
    _modelAvailable = false;
  }

  String _contextPrompt(PetState pet, String text) {
    final language = ChatLanguageDetector.detect(text).code;
    return 'Pet=${pet.name}; species=${pet.species}; '
        'hunger=${pet.hunger.toStringAsFixed(2)}; '
        'energy=${pet.energy.toStringAsFixed(2)}; '
        'hydration=${pet.hydration.toStringAsFixed(2)}; '
        'happiness=${pet.happiness.toStringAsFixed(2)}; '
        'stress=${pet.stress.toStringAsFixed(2)}; mood=${pet.mood}; '
        'reply_language=$language. '
        'User says: $text';
  }

  Future<void> dispose() async {
    await _closeChat();
    _turns = 0;
    _initialized = false;
  }

  Future<void> _resetChat() async {
    await _closeChat();
    _turns = 0;
    _initialized = false;
    await init();
  }

  Future<void> _closeChat() async {
    try {
      await _chat?.close();
    } catch (_) {}
    _chat = null;
    _modelAvailable = false;
  }
}
