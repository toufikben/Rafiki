# Rafiq roadmap / خارطة طريق رفيق

This document records the implementation state at the time of the GitHub upload. Statuses describe the repository, not a promise of store approval or a completed visual asset pipeline. Last verified: 2026-09-22.

## Completed batches

### Batch 1 — Flutter foundation and core pet loop

**Status: complete.** The Android Flutter project, Riverpod state layer, Isar persistence, onboarding, home screen, settings, evolution system, notifications, ads and purchases scaffolding were created. Test coverage was added for core needs and evolution behavior.

### Batch 2 — 3D scene foundation

**Status: complete for the current vertical slice.** `flutter_scene` is active on the Android 3D path. `DogSceneView` loads `assets/models/dog/dog.glb`, adds the environment and keeps the 2D renderer as a safe fallback if the asset fails to load. The current asset is an original stylized prototype, not the final production rig.

### Batch 3 — Secondary animal motion

**Status: complete for the current asset contract.** `DogSecondaryMotion` adds procedural breathing, independent ear sway and spring-damped tail follow-through. It is name-driven and fail-safe for optional joints including `Chest`, `Spine`, `Ear_L`, `Ear_R`, and `Tail_01..03`; the current original prototype exposes named `Chest`, `Ear.L`, `Ear.R`, `Tail`, and `TailTip` nodes and receives the breathing layer.

### Batch 4 — Environment rendering

**Status: complete.** The scene environment includes warm directional PBR lighting, cascaded soft shadows, contact shadows, ambient occlusion, ground-hugging fog, a matte ground receiver and sparse dust particles with soft-depth fade. The settings are mobile-conscious and independently switchable.

### Batch 5 — Interactive animal audio

**Status: complete for the current vertical slice.** A multi-channel audio mixer was added for breathing, panting, steps, bark, whine and generic pet sounds. Body loops, steps and one-shot reactions use separate players. Cooldowns and speed-sensitive volume prevent repetitive or competing audio. 3D touch interactions now trigger a quieter bark on tap and a rate-limited step cue while dragging, with silent fallback when an asset is unavailable.

### Batch 6 — Local adaptive intelligence

**Status: complete.** A bounded, explainable contextual policy stores interaction rewards in a versioned JSON profile on `PetState`. Behavior probabilities adapt gradually to feeding, play, petting, cleaning and drinking while welfare constraints remain dominant.

### Batch 7 — Integrated vitals and local chat

**Status: complete for the current vertical slice.** Hunger, energy, hydration, cleanliness, affection, happiness, stress and sleep debt now interact. A LiteRT-LM adapter is registered through `flutter_gemma`; the chat UI uses an active local model when installed and a safe local fallback otherwise. Android `minSdk` is 26 for the native engine.

## Next implementation batches

### Batch 8 — Final model and animation production

**Status: implementation gate closed; production-asset gate pending.** A self-contained original stylized dog GLB is committed and loads through `DogSceneView`. It contains 21 named nodes, materials, a ground-aligned scale, procedural breathing support, touch-driven placement, and interactive audio hooks. A testable `DogAnimationController`, manifest contract validator, and runtime `DogAnimationRuntime` clip binder with crossfade support are integrated. The runtime is safe when the current prototype has no authored clips and will bind `Idle`, `Walk`, `Run`, `Play`, `Sleep`, `Eat`, `Drink`, `Happy`, and `Sad` when the production GLB supplies them.

**Remaining work:** replace or extend the prototype with a licensed production-quality dog based on the approved visual references; add a named skeleton, optimized texture maps, and authored clips `Idle`, `Walk`, `Run`, `Play`, `Sleep`, `Eat`, `Drink`, `Happy`, and `Sad`; then validate animation blending and frame time on Android hardware.

**Current acceptance:** The Batch 8 implementation gate is closed: GLB loading, ground placement, environment rendering, fallback behavior, static material rendering, touch interaction, audio callbacks, clip-selection policy, runtime clip binding/crossfade and manifest-name validation are implemented. Flutter analysis, automated tests and debug APK builds are verified in the current environment. Android visual QA, authored locomotion, production rig validation and final visual matching remain the explicit production-asset gate. See [`BATCH_8_CLOSEOUT.md`](BATCH_8_CLOSEOUT.md).

The detailed production sequence, rig contract, animation list, validation gates and commit plan are documented in [`FINAL_3D_MODEL_ANIMATION_PLAN.md`](FINAL_3D_MODEL_ANIMATION_PLAN.md).

The Android-focused bone-weight, PBR material, texture, memory and GPU budget is documented in [`3D_RIG_MATERIALS_ANDROID_SPEC.md`](3D_RIG_MATERIALS_ANDROID_SPEC.md).

**Execution decision:** Continue with Batch 9 while the production-asset gate for Batch 8 proceeds in parallel. Batch 9 is code-complete enough to improve offline privacy, model lifecycle and fallback behavior without depending on a final GLB. Do not block the application roadmap on the art asset, but do not mark the visual release gate green until the rigged GLB, authored clips and Android visual/performance checks are complete.

### Batch 9 — Model management and chat quality

**Status: in progress; core management and quality slice implemented. Priority: high.** Added an explicit settings flow backed by `LocalModelManager` for listing installed models, selecting a local `.litertlm` file with `file_picker`, installing from a user-supplied URL, progress reporting, cancellation, retry, uninstall and orphan cleanup. The UI also shows installed storage usage, active model identity and a Wi-Fi/mobile-data warning. A preflight layer now validates extension, existence, minimum local size and remote HTTP(S) URL/size metadata before installation. The first-run path remains offline and never downloads implicitly. The deterministic fallback and privacy boundary are covered by tests. Chat now detects Arabic/English scripts, bounds native history by recreating the session after 12 turns and exposes a stop action that closes the active generation session.

**Remaining work:** improve platform-specific picker permissions and error copy, add a richer free-space confirmation when the platform exposes it, and perform model-runtime failure injection on Android with a real installed model. The URL download flow now performs preflight and requires an explicit confirmation dialog showing model name, estimated size, current model storage, active model, data-use warning and cancel/download actions.

**Acceptance criteria:** chat works offline with no model, can switch to a user-installed model, never blocks the UI, handles model failure gracefully, and does not download without an explicit action.

### Beta readiness — Internal technical beta

**Status: not yet released.** The current codebase is suitable for an internal technical beta after a real-device smoke test. The beta gate requires testing the GLB, touch response, interactive audio, background/resume behavior, fallback paths and local chat on representative Android hardware. A public visual beta remains blocked by the production rigged model, authored clips, release signing, privacy review and performance QA.

### Batch 10 — Behavioral validation and performance

**Priority: high; deterministic closeout implemented; field execution assigned to the user.** Deterministic tests now cover vital coupling, normalized bounds, mood priority, learning serialization, corrupt-profile fallback, bounded convergence, animation transitions, the GLB contract manifest, audio cooldown windows, offline chat fallback behavior, and Isar save/reopen/delete persistence. The remaining CPU, memory, GPU frame-time, audio-latency, battery and model-runtime checks require a representative Android device and are intentionally left as the user's field smoke-test gate.

**Acceptance criteria:** no critical jank in the home loop, bounded memory when a local model is loaded, predictable behavior under time jumps, and documented quality/performance budgets.

### Batch 11 — Production hardening

**Status: in progress. Priority: high.** Added build-time `--dart-define` configuration for AdMob and purchase identifiers, release fail-closed behavior when production identifiers are absent, a user-facing privacy and terms screen, automated coverage for the release configuration boundary, and a GitHub Actions pipeline that analyzes/tests then builds and uploads debug and release APK artifacts. The local debug APK was rebuilt and passed archive integrity inspection; details are in [`docs/DEBUG_APK_INSPECTION.md`](docs/DEBUG_APK_INSPECTION.md). Production identifiers, consent provider choice, crash-reporting provider, and release signing remain intentionally external inputs and are not invented or committed to the repository.

**Remaining work:** provide real production identifiers through the release environment, select and configure a consent/crash-reporting provider, complete localization and accessibility review, and create a release-signed build outside the repository. The debug build path is ready for APK inspection; the CI release job is allowed to fail until signing and secrets are configured. The build commands and secret boundary are documented in [`docs/RELEASE_BUILD.md`](docs/RELEASE_BUILD.md).

**Acceptance criteria:** release build is signed outside the repository, no test identifiers are used in release mode, privacy-sensitive settings are clear, and Google Play pre-launch checks pass.

### Batch 12 — Store release and post-launch learning

**Priority: medium.** Create store assets, screenshots and listing text; run internal and closed testing; prepare staged rollout; add opt-in diagnostics that do not upload pet content; monitor crashes and performance; and tune reward curves based on anonymized product feedback only if the user explicitly consents.

**Acceptance criteria:** Play Console internal test passes, rollback path is documented, and production configuration is reproducible from a clean checkout.

## Known remaining gaps

| Gap | Why it matters | Planned batch |
|---|---|---|
| Production rigged `dog.glb` and authored clips absent | Current original GLB is a functional stylized prototype; final reference-quality animation is still needed | 8 |
| No bundled LocalLLM binary | Models are large and license-specific; the deterministic offline fallback remains available | 9 |
| No model download/import screen | Users cannot yet select a model in-app | 9 |
| 3D visual QA on physical devices pending | Build success is not visual or performance proof | 8–10 |
| Generated APK is a debug artifact | Suitable for development smoke tests only, not store distribution | 11 |
| Real-device smoke test for touch/audio/3D pending | Build success does not prove visual, audio or GPU behavior on Android hardware | Beta / 8–10 |
| APK size optimization pending | Current debug artifact is large because native and model-related dependencies are included | Beta / 9–11 |
| Test ad and purchase identifiers | Must be replaced before release | 11 |
| Release signing and Play Console metadata | Required for publication | 11–12 |
| Privacy, consent and terms review | Required for responsible distribution | 11 |
| Broader automated test coverage | Needed for migration and regression safety | 10 |

## Latest verification

The repository passed `flutter analyze` with no issues, all 32 automated tests passed sequentially, and `flutter build apk --debug` produced `build/app/outputs/flutter-apk/app-debug.apk` (312 MB in the Batch 9 build). The verification environment uses Flutter 3.47.5, Dart 3.13.4, Android SDK 36, NDK 28.2.13676358 and JDK 21. The APK is still a development artifact only; physical-device visual and performance verification is still required.

## Release gates

A production release should not be tagged until the following gates are all green:

1. Clean checkout builds with documented Flutter, Java and Android SDK versions.
2. `flutter analyze`, `flutter test`, and a release APK/AAB build pass.
3. Final GLB, textures and animations are licensed, optimized and visually verified.
4. Local chat works with and without an installed model, with a clear privacy boundary.
5. Test ad IDs, test purchase IDs and debug signing are absent from the release flavor.
6. Data deletion, consent, notification and model-storage behavior are documented and tested.
7. Play Console internal testing passes on representative Android devices.
