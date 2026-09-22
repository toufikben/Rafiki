import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/core/models/pet_state.dart';
import 'package:rafiq/engine/needs_system.dart';

void main() {
  group('NeedsSystem', () {
    test('hunger decreases over time', () {
      final pet = PetState()
        ..hunger = 1.0
        ..energy = 1.0
        ..lastUpdated = DateTime.now();
      NeedsSystem.update(pet, const Duration(hours: 1));
      expect(pet.hunger, lessThan(1.0));
    });

    test('zero or negative elapsed time does not mutate vitals', () {
      final pet = PetState()
        ..hunger = 0.4
        ..energy = 0.7
        ..hydration = 0.6
        ..lastUpdated = DateTime(2026, 1, 1);
      NeedsSystem.update(pet, Duration.zero);
      expect(pet.hunger, 0.4);
      expect(pet.energy, 0.7);
      expect(pet.hydration, 0.6);
      expect(pet.lastUpdated, DateTime(2026, 1, 1));
    });

    test('feeding increases hunger value and awards experience', () {
      final pet = PetState()
        ..hunger = 0.2
        ..experiencePoints = 0;
      NeedsSystem.feed(pet);
      expect(pet.hunger, greaterThan(0.2));
      expect(pet.experiencePoints, 5);
    });

    test('all vital actions stay within normalized bounds', () {
      final pet = PetState()
        ..hunger = 0.99
        ..hydration = 0.99
        ..energy = 0.99
        ..stress = 0.01
        ..cleanliness = 0.01
        ..sleepDebt = 0.99;
      NeedsSystem.feed(pet, amount: 2.0);
      NeedsSystem.drink(pet, amount: 2.0);
      NeedsSystem.play(pet);
      NeedsSystem.clean(pet);
      NeedsSystem.rest(pet, hours: 10.0);

      for (final value in <double>[
        pet.hunger,
        pet.hydration,
        pet.energy,
        pet.happiness,
        pet.cleanliness,
        pet.affection,
        pet.stress,
        pet.sleepDebt,
      ]) {
        expect(value, inInclusiveRange(0.0, 1.0));
      }
    });

    test('low hydration and hunger produce hungry mood after time passes', () {
      final pet = PetState()
        ..hunger = 0.24
        ..hydration = 0.24
        ..energy = 0.7
        ..affection = 0.5
        ..stress = 0.1;
      NeedsSystem.update(pet, const Duration(hours: 1));
      expect(pet.mood, 'hungry');
    });

    test('low energy has priority over other mood signals', () {
      final pet = PetState()
        ..hunger = 0.8
        ..hydration = 0.8
        ..energy = 0.1
        ..sleepDebt = 0.1
        ..happiness = 0.9;
      NeedsSystem.update(pet, const Duration(minutes: 1));
      expect(pet.mood, 'sleepy');
    });

    test('mood becomes sad when happiness is low', () {
      final pet = PetState()
        ..happiness = 0.1
        ..hunger = 0.5
        ..energy = 0.5
        ..cleanliness = 0.1
        ..affection = 0.1;
      NeedsSystem.update(pet, const Duration(hours: 1));
      expect(pet.mood, 'sad');
    });
  });
}
