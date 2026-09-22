import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/core/models/pet_state.dart';
import 'package:rafiq/engine/evolution_system.dart';

void main() {
  group('EvolutionSystem', () {
    test('pet evolves at 150 XP', () {
      final pet = PetState()..experiencePoints = 150;
      final evolved = EvolutionSystem.checkEvolution(pet);
      expect(evolved, true);
      expect(pet.evolutionStage, 1);
    });

    test('pet stays baby below 150 XP', () {
      final pet = PetState()..experiencePoints = 50;
      final evolved = EvolutionSystem.checkEvolution(pet);
      expect(evolved, false);
      expect(pet.evolutionStage, 0);
    });

    test('scale factor increases with stage', () {
      final pet = PetState()..evolutionStage = 3;
      expect(EvolutionSystem.getScale(pet), 1.15);
    });
  });
}
