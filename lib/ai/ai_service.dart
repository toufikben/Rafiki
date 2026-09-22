import 'dart:math';

import '../core/models/pet_state.dart';
import 'learning_profile.dart';
import 'local_chat_service.dart';

/// Lightweight on-device pet intelligence.
///
/// It is intentionally offline: needs, mood, trust, species, and a small
/// stochastic response policy are enough to make the companion feel alive
/// without shipping a large language model or exposing an API key.
class AIService {
  final Random _random = Random();
  final LocalChatService _localChat = LocalChatService();
  bool _ready = false;

  bool get isReady => _ready;

  Future<void> init() async {
    _ready = true;
    await _localChat.init();
  }

  bool get localModelAvailable => _localChat.isModelAvailable;

  Future<String> chat({required PetState pet, required String text}) {
    return _localChat.send(pet: pet, text: text);
  }

  Future<void> cancelChat() => _localChat.cancelGeneration();

  Future<String> generateReaction({
    required PetState pet,
    required String context,
  }) async {
    if (!_ready) await init();
    return _localReaction(pet, context);
  }

  /// Learns from a local interaction outcome. The reward is deliberately
  /// explicit and bounded so one accidental tap cannot permanently change
  /// the pet's personality.
  Future<void> recordInteraction({
    required PetState pet,
    required String action,
    required double reward,
  }) async {
    if (!_ready) await init();
    final profile = LearningProfile.fromPet(pet);
    profile.learn(action, reward);
    profile.writeTo(pet);
    pet.totalInteractions++;
    pet.lastInteraction = DateTime.now();
  }

  String _localReaction(PetState pet, String context) {
    final name = pet.name;
    final profile = LearningProfile.fromPet(pet);
    final hungry = pet.hunger < 0.3;
    final tired = pet.energy < 0.25;
    final happy = pet.happiness > 0.75;
    final trusted = pet.trustLevel > 0.65 || pet.affection > 0.7;

    final options = switch (context) {
      'greeting' => trusted
          ? <String>[
              '$name runs over and rubs against you.',
              '$name chirps happily: I missed you!',
              '$name looks up at you with bright eyes.',
            ]
          : <String>[
              '$name watches you carefully from nearby.',
              '$name gives a tiny welcoming sound.',
              '$name slowly comes closer to say hello.',
            ],
      'ignored' => <String>[
          hungry ? '$name looks at the food bowl and then at you.' : '$name waits patiently for your attention.',
          tired ? '$name curls up while waiting for you.' : '$name gently nudges your hand.',
        ],
      'fed' => <String>[
          'That was delicious! $name licks their little nose.',
          '$name purrs softly after the tasty meal.',
          '$name looks satisfied and gives you a grateful nudge.',
        ],
      'play' => <String>[
          '$name bounces forward, ready to play!',
          '$name makes a playful little leap.',
          '$name watches the moving target with focused eyes.',
        ],
      'pet' => <String>[
          '$name relaxes into your hand.',
          '$name closes their eyes and enjoys the gentle touch.',
          '$name leans closer: that feels nice.',
        ],
      'clean' => <String>[
          '$name feels fresh and proud.',
          '$name shakes off and looks sparkling clean.',
        ],
      'drink' => <String>[
          '$name takes a refreshing drink and looks more comfortable.',
          '$name laps the water happily.',
        ],
      'evolution' => <String>[
          '$name grew up! Look how strong they are now.',
          '$name celebrates the next step of their journey.',
        ],
      _ => <String>[
          happy ? '$name seems cheerful and full of energy.' : '$name stays close to you.',
        ],
    };

    final learnedHint = profile.preferredInteraction();
    if (context == learnedHint && profile.samples >= 3) {
      return '$name seems especially engaged when you $context.';
    }
    return options[_random.nextInt(options.length)];
  }

  Future<void> dispose() async {
    await _localChat.dispose();
  }
}
