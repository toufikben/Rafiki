import 'package:flutter_gemma/flutter_gemma.dart';

import '../core/models/pet_state.dart';
import 'chat_fallback_policy.dart';

/// On-device chat adapter backed by a small LiteRT-LM model when installed.
///
/// The app remains usable without a model file: [send] falls back to a local
/// deterministic companion response. This is important because model files
/// are large binary assets and should be installed explicitly rather than
/// silently downloaded on first launch.
class LocalChatService {
  InferenceChat? _chat;
  bool _initialized = false;
  bool _modelAvailable = false;

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
    final chat = _chat;
    if (chat == null) return ChatFallbackPolicy.respond(pet: pet, text: text);

    try {
      final prompt = _contextPrompt(pet, text);
      await chat.addQueryChunk(Message(text: prompt, isUser: true));
      final response = await chat.generateChatResponse();
      final value = switch (response) {
        TextResponse(:final token) => token.trim(),
        ThinkingResponse(:final content) => content.trim(),
        _ => '',
      };
      return value.isEmpty
          ? ChatFallbackPolicy.respond(pet: pet, text: text)
          : value;
    } catch (_) {
      return ChatFallbackPolicy.respond(pet: pet, text: text);
    }
  }

  String _contextPrompt(PetState pet, String text) {
    return 'Pet=${pet.name}; species=${pet.species}; '
        'hunger=${pet.hunger.toStringAsFixed(2)}; '
        'energy=${pet.energy.toStringAsFixed(2)}; '
        'hydration=${pet.hydration.toStringAsFixed(2)}; '
        'happiness=${pet.happiness.toStringAsFixed(2)}; '
        'stress=${pet.stress.toStringAsFixed(2)}; mood=${pet.mood}. '
        'User says: $text';
  }

  Future<void> dispose() async {
    try {
      await _chat?.close();
    } catch (_) {}
    _chat = null;
    _modelAvailable = false;
    _initialized = false;
  }
}
