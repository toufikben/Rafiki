# Rafiq local interactive intelligence

## Design

The sixth batch uses an explainable on-device contextual policy rather than a remote API or a large language model. The pet stores a compact JSON profile inside `PetState.learningProfileJson`. Each interaction updates an exponentially smoothed reward and a sample counter. The profile is restored on launch and therefore survives app restarts.

The current reward policy is intentionally conservative: play receives the strongest positive reward, petting and feeding receive positive rewards, and cleaning receives a smaller positive reward because it is useful but less intrinsically rewarding. The update rate decays as the sample count grows, so one accidental tap cannot permanently change the pet's personality.

## Behavior adaptation

`BehaviorEngine` still enforces safety priorities first. Exhaustion leads to sleep, severe hunger leads to begging, and mood constraints remain stronger than learned preferences. When the pet is safe and emotionally stable, learned behavior bonuses adjust the probability of idle, walking, following, playing, and celebrating. This creates gradual personality adaptation without allowing the learner to override welfare logic.

## Interaction language

`AIService` remains fully local and offline. It chooses contextual reaction text from a curated set and can mention a learned preference after enough samples. No pet name, interaction history, or profile is uploaded. The implementation is a small reinforcement-style preference learner, not a claim that a full neural language model is running inside the APK.

## Future extension

A later batch can add time-of-day context, novelty decay, explicit user feedback, and per-species reward tables. These should remain bounded and versioned so the profile can migrate safely without corrupting existing pets.
