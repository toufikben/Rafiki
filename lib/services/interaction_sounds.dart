import '../core/constants/pet_species.dart';
import 'audio_service.dart';

/// One-shot interaction sounds for non-dog species.
///
/// Dogs return null because their one-shots are owned by
/// [DogAudioController] (bark/whine with cooldowns); layering these generic
/// assets over them would play two species' sounds at once.
///
/// Bunnies have no dedicated assets, so only the generic happy feed cue
/// applies. 'clean' and 'drink' have no asset for any species and stay
/// silent.
enum InteractionSound { happy, meow, purr }

InteractionSound? interactionSound(String species, String action) {
  if (species == PetSpecies.dog) return null;
  switch (action) {
    case 'feed':
      return InteractionSound.happy;
    case 'play':
      return species == PetSpecies.cat ? InteractionSound.meow : null;
    case 'pet':
      return species == PetSpecies.cat ? InteractionSound.purr : null;
    default:
      return null;
  }
}

/// Plays the mapped one-shot; a no-op for unmapped combinations.
void playInteractionSound(String species, String action) {
  final sound = interactionSound(species, action);
  switch (sound) {
    case InteractionSound.happy:
      AudioService.playHappy();
    case InteractionSound.meow:
      AudioService.playMeow();
    case InteractionSound.purr:
      AudioService.playPurr();
    case null:
      break;
  }
}
