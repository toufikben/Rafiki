# Evidence — batch 1: best-quality default local model catalog

Task: tsk_muhh74o5_mu5b08 | Date (UTC): 2026-09-25 | Branch: ai/tsk-muhh74o5-mu5b08

## Decision
Default recommendation = **Qwen3 0.6B** (`qwen3-0.6b`), ahead of balanced
LFM2.5 230M and lightest SmolLM2 135M. Quality, not size, was the deciding
factor, per the task brief ("not the smallest").

## What changed
- `lib/ai/recommended_models.dart`: generic size classes replaced with named
  engine-supported models; added `defaultRecommendedModelId`,
  `defaultRecommendedModel`, and per-model `source` pointers (official
  distributions, deliberately NOT download URLs — URLs were not invented).
- `lib/features/settings/settings_screen.dart`: model dialog now leads with
  the best-quality default and its approximate size; install flow unchanged.
- `test/release_polish_test.dart`: asserts the default resolves to a catalog
  entry and is the largest (best-quality) option; checks unique ids and
  non-empty license/source fields.
- `assets/models/llm/README.md`: documents the default and the explicit
  install path (`LocalModelManager` file/URL flow).

## Reused (no custom reimplementation)
- `flutter_gemma` ^1.8.4 + `flutter_gemma_litertlm` ^1.0.1 (inference engine)
- `file_picker` ^13.1.0 (local `.litertlm` selection)
- Existing `LocalModelManager`, `ModelInstallPreflight`, `LocalChatService`
  fallback boundary (offline first-run preserved).

## NOT done (honest gaps)
- No `.litertlm` binary is bundled or committed (large immutable asset +
  license must be user-supplied; matches repo policy).
- No on-device chat-generation run: no Flutter/Android toolchain or device
  exists in this automation environment (see `environment_limits.md`).
  Field gate: install a real Qwen3 0.6B build via Settings, verify a reply
  over adb, then record the log here.

## Verification available here
- Static review of the three edited Dart files (no Flutter SDK to run
  `flutter analyze` / `flutter test`; CI workflow `flutter-build.yml` is the
  interim verification path).
