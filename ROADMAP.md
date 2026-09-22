# Rafiq roadmap / خارطة طريق رفيق

This document records the implementation state at the time of the GitHub upload. Statuses describe the repository, not a promise of store approval or a completed visual asset pipeline.

## Completed batches

### Batch 1 — Flutter foundation and core pet loop

**Status: complete.** The Android Flutter project, Riverpod state layer, Isar persistence, onboarding, home screen, settings, evolution system, notifications, ads and purchases scaffolding were created. Test coverage was added for core needs and evolution behavior.

### Batch 2 — 3D scene foundation

**Status: complete.** `flutter_scene` was added for the Android 3D path. The GLB asset contract, dog rig manifest and `DogSceneView` were created. The 2D renderer remains the safe fallback while the final model is absent.

### Batch 3 — Secondary animal motion

**Status: complete.** `DogSecondaryMotion` adds procedural breathing, independent ear sway and spring-damped tail follow-through. It is name-driven and fail-safe for optional joints including `Chest`, `Spine`, `Ear_L`, `Ear_R`, and `Tail_01..03`.

### Batch 4 — Environment rendering

**Status: complete.** The scene environment includes warm directional PBR lighting, cascaded soft shadows, contact shadows, ambient occlusion, ground-hugging fog, a matte ground receiver and sparse dust particles with soft-depth fade. The settings are mobile-conscious and independently switchable.

### Batch 5 — Interactive animal audio

**Status: complete.** A multi-channel audio mixer was added for breathing, panting, steps, bark, whine and generic pet sounds. Body loops, steps and one-shot reactions use separate players. Cooldowns and speed-sensitive volume prevent repetitive or competing audio.

### Batch 6 — Local adaptive intelligence

**Status: complete.** A bounded, explainable contextual policy stores interaction rewards in a versioned JSON profile on `PetState`. Behavior probabilities adapt gradually to feeding, play, petting, cleaning and drinking while welfare constraints remain dominant.

### Batch 7 — Integrated vitals and local chat

**Status: complete for the current vertical slice.** Hunger, energy, hydration, cleanliness, affection, happiness, stress and sleep debt now interact. A LiteRT-LM adapter is registered through `flutter_gemma`; the chat UI uses an active local model when installed and a safe local fallback otherwise. Android `minSdk` is 26 for the native engine.

## Next implementation batches

### Batch 8 — Final model and animation production

**Priority: highest.** Supply a production-quality dog GLB based on the approved visual references. It must contain a named skeleton, materials, texture maps, and authored clips: `Idle`, `Walk`, `Run`, `Play`, `Sleep`, `Eat`, `Drink`, `Happy`, and `Sad`. Validate scale, forward axis, joint names and animation blending on Android.

**Acceptance criteria:** the GLB loads without fallback; the dog is visible on the environment ground; locomotion matches the 2D behavior state; secondary motion layers without visible joint drift; no missing material or texture warnings.

### Batch 9 — Model management and chat quality

**Priority: high.** Add a settings flow for installing/importing a small `.litertlm` model. Show storage requirement, download progress, cancellation, retry, model deletion, active-model status and a Wi-Fi recommendation. Add conversation history limits, response cancellation, language detection, prompt injection resistance, and explicit privacy messaging.

**Acceptance criteria:** chat works offline with no model, can switch to a user-installed model, never blocks the UI, handles model failure gracefully, and does not download without an explicit action.

### Batch 10 — Behavioral validation and performance

**Priority: high.** Add deterministic tests for vital coupling, learning convergence, mood transitions, audio cooldowns, model fallback and state migration. Profile CPU, memory, GPU frame time, audio latency and battery use on low-, mid- and high-tier Android devices.

**Acceptance criteria:** no critical jank in the home loop, bounded memory when a local model is loaded, predictable behavior under time jumps, and documented quality/performance budgets.

### Batch 11 — Production hardening

**Priority: high.** Replace test AdMob IDs and purchase product IDs, add release signing, privacy policy and terms screens, consent handling, crash reporting, secure configuration, localization review and accessibility labels.

**Acceptance criteria:** release build is signed outside the repository, no test identifiers remain, privacy-sensitive settings are clear, and Google Play pre-launch checks pass.

### Batch 12 — Store release and post-launch learning

**Priority: medium.** Create store assets, screenshots and listing text; run internal and closed testing; prepare staged rollout; add opt-in diagnostics that do not upload pet content; monitor crashes and performance; and tune reward curves based on anonymized product feedback only if the user explicitly consents.

**Acceptance criteria:** Play Console internal test passes, rollback path is documented, and production configuration is reproducible from a clean checkout.

## Known remaining gaps

| Gap | Why it matters | Planned batch |
|---|---|---|
| Final rigged `dog.glb` absent | 3D path cannot be visually validated end-to-end | 8 |
| No bundled LocalLLM binary | Models are large and license-specific | 9 |
| No model download/import screen | Users cannot yet select a model in-app | 9 |
| 3D visual QA on physical devices pending | Build success is not visual or performance proof | 8–10 |
| Generated APK is a debug artifact | Not suitable for store distribution | 11 |
| Test ad and purchase identifiers | Must be replaced before release | 11 |
| Release signing and Play Console metadata | Required for publication | 11–12 |
| Privacy, consent and terms review | Required for responsible distribution | 11 |
| Broader automated test coverage | Needed for migration and regression safety | 10 |

## Release gates

A production release should not be tagged until the following gates are all green:

1. Clean checkout builds with documented Flutter, Java and Android SDK versions.
2. `flutter analyze`, `flutter test`, and a release APK/AAB build pass.
3. Final GLB, textures and animations are licensed, optimized and visually verified.
4. Local chat works with and without an installed model, with a clear privacy boundary.
5. Test ad IDs, test purchase IDs and debug signing are absent from the release flavor.
6. Data deletion, consent, notification and model-storage behavior are documented and tested.
7. Play Console internal testing passes on representative Android devices.
