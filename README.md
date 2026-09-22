# Rafiq / رفيق

Rafiq is an Android-first virtual pet companion built with Flutter. The project combines a needs simulation, adaptive local behavior, interactive audio, a prepared 3D rendering path, and an optional on-device language model chat experience.

رفيق هو تطبيق حيوان أليف افتراضي موجه إلى Android، مبني باستخدام Flutter. يجمع بين نظام احتياجات حيوي مترابط، سلوك متكيف محلياً، أصوات تفاعلية، مسار رسوميات ثلاثية الأبعاد جاهز، ومحادثة نصية محلية اختيارية باستخدام نموذج على الجهاز.

## Current status

**Batches 1–7 are implemented and pass the current automated verification.** The current debug APK builds successfully. The project is production-oriented but is not yet a store release: the final rigged GLB assets, model binary, production signing, live ad identifiers, and store configuration remain outstanding.

| Area | Status |
|---|---|
| Flutter Android application | Implemented |
| Local database and persistence | Implemented with Isar |
| Interconnected hunger, energy, mood, hydration, stress and sleep debt | Implemented |
| Local adaptive preference learning | Implemented |
| Interactive dog audio mixer | Implemented |
| 3D scene, secondary motion and environment path | Implemented and fail-safe |
| LocalLLM engine integration | Implemented with LiteRT-LM adapter |
| Local text chat UI | Implemented with offline fallback |
| Final dog GLB model and authored animation clips | Pending |
| Bundled small `.litertlm` model | Pending explicit model selection/licensing |
| Production AdMob/IAP identifiers | Pending external `--dart-define` configuration |
| Release signing and Play Console setup | Pending |
| Privacy and terms screens | Implemented; legal review pending |

## Features

### Biological systems

The `NeedsSystem` models hunger, energy, hydration, cleanliness, affection, happiness, stress, and sleep debt as coupled values rather than isolated progress bars. Hunger and hydration affect stress; stress affects happiness; play increases affection and happiness while consuming energy; rest reduces sleep debt; mood transitions are derived from the combined state. The behavior engine gives welfare constraints priority over learned preferences.

### Adaptive local intelligence

The app stores a compact JSON learning profile in `PetState`. Interaction rewards are smoothed locally over time. The behavior policy uses those learned preferences to adjust the probability of idle, walking, following, playing, and celebrating without allowing one accidental tap to permanently change personality. No pet history is uploaded.

### Local text chat

`flutter_gemma` and `flutter_gemma_litertlm` are registered at startup. `LocalChatService` uses an active LiteRT-LM model when one is installed. If no model is present, the same chat UI responds through a deterministic, offline fallback that uses the pet's current vital state. This keeps first launch functional and avoids silently downloading a large model.

The recommended future model profile is a small public instruction model such as LFM2.5 230M, SmolLM 135M, or Qwen3 0.6B, subject to the model's current license and distribution terms. See [`assets/models/llm/README.md`](assets/models/llm/README.md).

### Audio

The audio mixer separates body loops, steps, and one-shot reactions. Dog breathing and panting are synchronized with behavior, steps are cadence-throttled, and bark/whine reactions use cooldowns to prevent repetition. Generic purr, meow, and happy sounds remain available for non-dog pets. See [`assets/sounds/DOG_SOUNDS.md`](assets/sounds/DOG_SOUNDS.md).

### 3D rendering path

`flutter_scene` is configured for an Android GLB vertical slice. The path includes secondary breathing, ear and spring-damped tail motion, warm directional lighting, cascaded/contact shadows, screen-space ambient occlusion, ground fog, and sparse soft-depth dust particles. It fails safely to the existing 2D renderer until a validated rigged `dog.glb` is supplied.

## Project structure

```text
lib/
  ai/                 Local reactions, learning profile and LocalLLM chat adapter
  core/models/        Isar pet state and behavior value objects
  data/               Isar database access
  engine/             Needs, behavior and evolution systems
  features/           Onboarding, home and settings screens
  providers/          Riverpod state and interaction orchestration
  render/             2D painter, 3D scene, environment and secondary motion
  services/           Audio, notifications, ads, purchases and overlay services
assets/
  sounds/             Generic and dog-specific local audio
  models/             GLB/LocalLLM asset contracts and installation notes
reference_images/     Visual references and derived art-direction notes
 test/                Unit tests for core needs and evolution behavior
```

## Requirements

- Flutter 3.47.5 or a compatible stable Flutter SDK.
- Dart 3.5 or newer.
- Java 17 for the Android build.
- Android SDK with compile SDK 36.
- Android API 26 or newer for the LiteRT-LM engine.

## Setup and verification

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --debug
```

GitHub Actions runs the same analysis, tests, debug APK build, and a release APK build on pushes, pull requests, and manual dispatch. See [`docs/RELEASE_BUILD.md`](docs/RELEASE_BUILD.md) for the required `--dart-define` values and signing boundary. The release job may remain unsuccessful until production identifiers and release signing are configured; debug APK artifacts are uploaded independently.

Run on a connected Android device or emulator:

```bash
flutter run
```

The model binary is intentionally not committed. Install one explicitly through a future model-management screen or the `FlutterGemma.installModel(...).fromFile(...)` / `.fromNetwork(...)` APIs. Until then, LocalChatService uses its offline fallback.

## Production checklist

Before publishing, the project still needs a final rigged `dog.glb` with named joints and authored clips; visual and frame-time profiling on representative Android devices; production AdMob and Google Play product identifiers supplied through the release environment; consent and crash-reporting configuration; release signing; legal review; store listing assets; and a release build tested through Play Console internal testing. The user-facing model download/import flow, storage confirmation, cancellation, and Wi-Fi controls are implemented.

## Documentation

- [`ROADMAP.md`](ROADMAP.md) — completed batches, remaining work, acceptance criteria and release gates.
- [`AI_LEARNING.md`](AI_LEARNING.md) — local adaptive intelligence design.
- [`assets/models/dog/README.md`](assets/models/dog/README.md) — GLB rig contract.
- [`assets/models/llm/README.md`](assets/models/llm/README.md) — LocalLLM model policy.
- [`assets/sounds/DOG_SOUNDS.md`](assets/sounds/DOG_SOUNDS.md) — dog audio roles and playback policy.

## License and asset note

This repository contains application code and generated application sound effects. Before commercial release, confirm the licenses and attribution requirements of every third-party package and any final model or visual asset selected for distribution.
