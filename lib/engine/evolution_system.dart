import '../core/models/pet_state.dart';

class EvolutionStage {
  final int index;
  final String name;
  final int requiredXP;
  final double scaleFactor;
  final List<String> unlockedBehaviors;
  final String description;

  const EvolutionStage({
    required this.index,
    required this.name,
    required this.requiredXP,
    required this.scaleFactor,
    required this.unlockedBehaviors,
    required this.description,
  });
}

class EvolutionSystem {
  static const List<EvolutionStage> stages = [
    EvolutionStage(
      index: 0,
      name: 'Baby',
      requiredXP: 0,
      scaleFactor: 0.50,
      unlockedBehaviors: ['idle', 'sleeping', 'begging'],
      description: 'Tiny and completely dependent on you.',
    ),
    EvolutionStage(
      index: 1,
      name: 'Child',
      requiredXP: 150,
      scaleFactor: 0.75,
      unlockedBehaviors: ['walking', 'playing', 'followingCursor'],
      description: 'Starting to explore the world.',
    ),
    EvolutionStage(
      index: 2,
      name: 'Teen',
      requiredXP: 600,
      scaleFactor: 1.00,
      unlockedBehaviors: ['running', 'hiding', 'celebrating'],
      description: 'Energetic and curious.',
    ),
    EvolutionStage(
      index: 3,
      name: 'Adult',
      requiredXP: 2000,
      scaleFactor: 1.15,
      unlockedBehaviors: ['all'],
      description: 'A mature and wise companion.',
    ),
  ];

  static bool checkEvolution(PetState pet) {
    for (int i = stages.length - 1; i >= 0; i--) {
      if (pet.experiencePoints >= stages[i].requiredXP &&
          pet.evolutionStage < i) {
        pet.evolutionStage = i;
        pet.happiness = 1.0;
        pet.trustLevel = (pet.trustLevel + 0.15).clamp(0.0, 1.0);
        return true;
      }
    }
    return false;
  }

  static EvolutionStage getStage(PetState pet) => stages[pet.evolutionStage];

  static double getScale(PetState pet) => stages[pet.evolutionStage].scaleFactor;
}
