# Changelog

## Unreleased — Android vertical slice

### Added

- Flutter Android application foundation with Riverpod, Isar persistence, onboarding, settings, notifications, ads and purchases scaffolding.
- Local pet needs engine with hunger, energy, hydration, cleanliness, affection, happiness, stress and sleep debt coupling.
- Adaptive local preference profile with bounded rewards and behavior probability updates.
- Dog audio mixer with breathing, panting, steps, bark and whine channels plus generic pet sounds.
- `flutter_scene` 3D path with rig manifest, secondary breathing/ear/tail motion, lighting, shadows, ambient occlusion, fog and dust environment.
- `flutter_gemma` and `flutter_gemma_litertlm` integration for optional Android on-device chat.
- Local chat UI with model-backed responses when an active model exists and an offline vital-state fallback otherwise.
- Arabic and English localization foundations.
- Roadmap and asset/licensing documentation.
- Curated on-device model catalog in Settings with Qwen3 0.6B as the best-quality default, LFM2.5 230M balanced and SmolLM2 135M lightest (no binary bundled; install stays explicit via `flutter_gemma`).
- Case/whitespace-tolerant authored-clip lookup plus wider exporter joint-name aliases for the dog rig runtime.
- UI polish: chat privacy/empty-state copy, status-HUD semantics, labeled pet stat values, onboarding name-field label with species-picker semantics and a privacy/terms entry point.

### Verification

- Isar code generation completed.
- `flutter analyze` completed with non-blocking dependency/toolchain notices.
- All current Flutter tests passed.
- Debug Android APK built successfully after LiteRT-LM native libraries were resolved.

### Not yet a store release

The final rigged `dog.glb` (committed asset measured 2026-09-25: static prototype, 0 animations, 0 skins), a bundled default model binary, on-device chat-generation verification, production ad and purchase identifiers (including the manifest AdMob application ID), release signing, privacy/terms review, physical-device performance profiling and Play Console release process remain pending. See [`ROADMAP.md`](ROADMAP.md).
