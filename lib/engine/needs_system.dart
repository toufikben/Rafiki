import '../core/models/pet_state.dart';

/// Coupled vital-sign simulation for the companion.
///
/// Values are normalized to 0..1. Hunger, hydration, energy, stress,
/// cleanliness and affection influence one another instead of behaving as
/// independent progress bars. The model is deliberately deterministic and
/// cheap enough to update every second on Android.
class NeedsSystem {
  static const double hungerDecayPerHour = 0.10;
  static const double energyDecayPerHour = 0.06;
  static const double hydrationDecayPerHour = 0.09;
  static const double cleanlinessDecayPerHour = 0.04;
  static const double sleepDebtGainPerHour = 0.08;

  static PetState update(PetState pet, Duration elapsed) {
    final hours = elapsed.inMinutes / 60.0;
    if (hours <= 0) return pet;

    pet.hunger = _clamp(pet.hunger - hungerDecayPerHour * hours);
    pet.hydration = _clamp(pet.hydration - hydrationDecayPerHour * hours);
    pet.cleanliness = _clamp(
      pet.cleanliness - cleanlinessDecayPerHour * hours,
    );

    final biologicalLoad = ((1.0 - pet.hunger) * 0.38) +
        ((1.0 - pet.hydration) * 0.30) +
        ((1.0 - pet.energy) * 0.22) +
        (pet.sleepDebt * 0.10);
    pet.energy = _clamp(
      pet.energy - energyDecayPerHour * hours - biologicalLoad * 0.012 * hours,
    );
    pet.sleepDebt = _clamp(pet.sleepDebt + sleepDebtGainPerHour * hours);

    final discomfort = ((1.0 - pet.hunger) * 0.30) +
        ((1.0 - pet.hydration) * 0.24) +
        ((1.0 - pet.cleanliness) * 0.10) +
        (pet.sleepDebt * 0.22) +
        (pet.stress * 0.14);
    final socialBuffer = pet.affection * 0.16;
    pet.stress = _clamp(pet.stress + (discomfort - socialBuffer) * hours * 0.18);

    final wellbeing = (pet.hunger * 0.22) +
        (pet.hydration * 0.18) +
        (pet.energy * 0.18) +
        (pet.cleanliness * 0.10) +
        (pet.affection * 0.16) +
        ((1.0 - pet.stress) * 0.16);
    pet.happiness = _clamp(pet.happiness + (wellbeing - pet.happiness) * 0.32);
    pet.mood = _calculateMood(pet);
    pet.lastUpdated = DateTime.now();
    return pet;
  }

  static String _calculateMood(PetState pet) {
    if (pet.energy < 0.18 || pet.sleepDebt > 0.78) return 'sleepy';
    if (pet.hydration < 0.18 || pet.hunger < 0.20) return 'hungry';
    if (pet.stress > 0.78 || pet.happiness < 0.25) return 'sad';
    if (pet.affection < 0.25) return 'lonely';
    if (pet.happiness > 0.80 && pet.stress < 0.25 && pet.affection > 0.70) {
      return 'excited';
    }
    return 'neutral';
  }

  static void feed(PetState pet, {double amount = 0.35}) {
    pet.hunger = _clamp(pet.hunger + amount);
    pet.hydration = _clamp(pet.hydration + amount * 0.16);
    pet.happiness = _clamp(pet.happiness + 0.05);
    pet.stress = _clamp(pet.stress - 0.06);
    pet.lastFed = DateTime.now();
    _addXP(pet, 5);
  }

  static void play(PetState pet) {
    pet.happiness = _clamp(pet.happiness + 0.15);
    pet.energy = _clamp(pet.energy - 0.10);
    pet.affection = _clamp(pet.affection + 0.10);
    pet.stress = _clamp(pet.stress - 0.12);
    pet.sleepDebt = _clamp(pet.sleepDebt + 0.025);
    pet.lastPlayed = DateTime.now();
    _addXP(pet, 10);
  }

  static void pet(PetState pet) {
    pet.affection = _clamp(pet.affection + 0.08);
    pet.happiness = _clamp(pet.happiness + 0.03);
    pet.stress = _clamp(pet.stress - 0.10);
    pet.totalInteractions++;
    _addXP(pet, 2);
  }

  static void clean(PetState pet) {
    pet.cleanliness = 1.0;
    pet.happiness = _clamp(pet.happiness + 0.05);
    pet.stress = _clamp(pet.stress - 0.04);
    _addXP(pet, 5);
  }

  static void drink(PetState pet, {double amount = 0.30}) {
    pet.hydration = _clamp(pet.hydration + amount);
    pet.stress = _clamp(pet.stress - 0.03);
    pet.happiness = _clamp(pet.happiness + 0.02);
  }

  static void rest(PetState pet, {double hours = 0.25}) {
    pet.energy = _clamp(pet.energy + hours * 0.42);
    pet.sleepDebt = _clamp(pet.sleepDebt - hours * 0.55);
    pet.stress = _clamp(pet.stress - hours * 0.20);
    pet.mood = _calculateMood(pet);
  }

  static double _clamp(double value) => value.clamp(0.0, 1.0).toDouble();

  static void _addXP(PetState pet, int xp) {
    pet.experiencePoints += xp;
  }
}
