import 'package:isar/isar.dart';

part 'pet_state.g.dart';

@collection
class PetState {
  Id id = Isar.autoIncrement;

  late String name;
  late String species;
  late DateTime birthDate;
  late DateTime lastInteraction;
  late DateTime lastFed;
  late DateTime lastPlayed;
  late DateTime lastUpdated;

  double hunger = 0.8;
  double energy = 1.0;
  double happiness = 0.7;
  double cleanliness = 1.0;
  double affection = 0.5;
  double hydration = 0.85;
  double stress = 0.15;
  double sleepDebt = 0.0;

  int evolutionStage = 0;
  int experiencePoints = 0;
  double trustLevel = 0.0;

  double posX = 100.0;
  double posY = 200.0;
  double velocityX = 0.0;
  double velocityY = 0.0;

  String currentBehavior = 'idle';
  String mood = 'neutral';

  int totalInteractions = 0;

  /// JSON-encoded on-device preference and reward profile.
  /// Kept as a String so Isar remains schema-stable across app versions.
  String learningProfileJson = '{}';
  int learningSamples = 0;

  bool isPremium = false;
  DateTime? premiumSince;
}
