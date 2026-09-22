import 'dart:convert';
import 'dart:math' as math;

import '../core/models/behavior_type.dart';
import '../core/models/pet_state.dart';

/// Small, deterministic on-device contextual bandit.
///
/// Each action stores an exponentially smoothed reward and sample count. The
/// policy uses needs and mood as context, then adds a bounded learned bonus.
/// It is not a black box and never sends pet data outside the device.
class LearningProfile {
  LearningProfile._(this.values, this.samples);

  factory LearningProfile.fromPet(PetState pet) {
    try {
      final decoded = jsonDecode(pet.learningProfileJson);
      if (decoded is Map<String, dynamic>) {
        final values = <String, double>{};
        final rawValues = decoded['values'];
        if (rawValues is Map) {
          rawValues.forEach((key, value) {
            final parsed = value is num ? value.toDouble() : double.tryParse('$value');
            if (parsed != null && parsed.isFinite) values['$key'] = parsed.clamp(-1.0, 1.0);
          });
        }
        return LearningProfile._(values, pet.learningSamples);
      }
    } catch (_) {
      // Corrupt or legacy data is safely replaced by an empty profile.
    }
    return LearningProfile._(<String, double>{}, pet.learningSamples);
  }

  final Map<String, double> values;
  int samples;

  double rewardFor(String action) => values[action] ?? 0.0;

  /// Updates a preference using a decaying learning rate. Positive rewards
  /// represent actions followed by engagement; negative rewards represent
  /// avoidance, repeated interruption, or an unmet need.
  void learn(String action, double reward) {
    final normalized = reward.clamp(-1.0, 1.0);
    final previous = rewardFor(action);
    final learningRate = 1.0 / math.min(samples + 3, 18);
    values[action] = (previous + learningRate * (normalized - previous)).clamp(-1.0, 1.0);
    samples++;
  }

  void writeTo(PetState pet) {
    pet.learningProfileJson = jsonEncode(<String, dynamic>{
      'version': 1,
      'values': values,
      'samples': samples,
    });
    pet.learningSamples = samples;
  }

  /// Converts learned preferences into a bounded behavior bonus. Needs still
  /// dominate, so learning can shape personality but cannot override hunger or
  /// exhaustion safety rules.
  double behaviorBonus(BehaviorType behavior) {
    final key = behavior.name;
    final learned = rewardFor(key);
    return learned * (0.18 + math.min(samples, 30) / 150.0);
  }

  String preferredInteraction() {
    if (values.isEmpty) return 'play';
    return values.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
