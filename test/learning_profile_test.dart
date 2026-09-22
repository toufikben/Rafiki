import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/ai/learning_profile.dart';
import 'package:rafiq/core/models/behavior_type.dart';
import 'package:rafiq/core/models/pet_state.dart';

void main() {
  group('LearningProfile', () {
    test('round trips learned values and sample count through PetState', () {
      final pet = PetState();
      final profile = LearningProfile.fromPet(pet);

      profile.learn('playing', 1.0);
      profile.learn('walking', -1.0);
      profile.writeTo(pet);

      final restored = LearningProfile.fromPet(pet);
      expect(restored.samples, 2);
      expect(restored.rewardFor('playing'), greaterThan(0));
      expect(restored.rewardFor('walking'), lessThan(0));
      expect(jsonDecode(pet.learningProfileJson)['version'], 1);
    });

    test('corrupt and legacy payloads fall back safely', () {
      final corrupt = PetState()..learningProfileJson = '{not-json';
      expect(LearningProfile.fromPet(corrupt).values, isEmpty);

      final legacy = PetState()..learningProfileJson = jsonEncode({'mood': 'happy'});
      expect(LearningProfile.fromPet(legacy).values, isEmpty);
    });

    test('rewards and behavior bonuses remain bounded', () {
      final pet = PetState();
      final profile = LearningProfile.fromPet(pet);
      for (var i = 0; i < 80; i++) {
        profile.learn('playing', 100.0);
      }

      expect(profile.rewardFor('playing'), lessThanOrEqualTo(1.0));
      expect(
        profile.behaviorBonus(BehaviorType.playing),
        inInclusiveRange(0.0, 0.54),
      );
      expect(profile.preferredInteraction(), 'playing');
    });

    test('empty profile has a stable default interaction', () {
      final profile = LearningProfile.fromPet(PetState());
      expect(profile.preferredInteraction(), 'play');
      expect(profile.behaviorBonus(BehaviorType.idle), 0.0);
    });
  });
}
