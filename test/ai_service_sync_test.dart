import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/ai/ai_service.dart';
import 'package:rafiq/core/models/pet_state.dart';

void main() {
  group('AIService.recordInteractionSync', () {
    PetState newPet() {
      final now = DateTime(2026, 9, 25, 12);
      return PetState()
        ..name = 'Nimbus'
        ..species = 'dog'
        ..birthDate = now
        ..lastInteraction = now
        ..lastFed = now
        ..lastPlayed = now
        ..lastUpdated = now
        ..totalInteractions = 0
        ..learningSamples = 0
        ..learningProfileJson = '{}';
    }

    test('mutates the pet synchronously with no returned future', () {
      final service = AIService();
      final pet = newPet();
      final before = pet.lastInteraction;

      // The call is synchronous: it returns void, so a caller can capture
      // state, apply needs, record, and publish a clone with no await in
      // between (the race fix this pins).
      service.recordInteractionSync(
        pet: pet,
        action: 'feed',
        reward: 0.72,
      );

      expect(pet.totalInteractions, 1);
      expect(pet.learningSamples, 1);
      expect(pet.learningProfileJson, contains('feed'));
      expect(pet.lastInteraction.isAfter(before), isTrue);
    });

    test('accumulates samples across repeated interactions', () {
      final service = AIService();
      final pet = newPet();

      service.recordInteractionSync(pet: pet, action: 'play', reward: 0.92);
      service.recordInteractionSync(pet: pet, action: 'play', reward: 0.92);

      expect(pet.totalInteractions, 2);
      expect(pet.learningSamples, 2);
    });
  });

  group('AIService.ensureReady', () {
    test('is idempotent and leaves the service ready', () async {
      final service = AIService();
      await service.ensureReady();
      expect(service.isReady, isTrue);
      // A second call must not throw or re-run initialization destructively.
      await service.ensureReady();
      expect(service.isReady, isTrue);
    });
  });
}
