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

    test('feeding increases hunger value', () {
      final pet = PetState()..hunger = 0.2;
      NeedsSystem.feed(pet);
      expect(pet.hunger, greaterThan(0.2));
    });

    test('mood becomes sad when happiness low', () {
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
