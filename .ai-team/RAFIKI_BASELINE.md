# RAFIKI Forensic Baseline — Phase 0

Recorded: 2026-09-25 by AI team.

## Repository identity

| Item | Value |
|---|---|
| Remote | https://github.com/toufikben/Rafiki |
| Default branch | main (protected source of truth) |
| BASE_SHA (main HEAD at clone) | `0cfaa9711106e68eb48791227b94f049e150581b` |
| HEAD commit message | `fix: use redirect history for model URL validation` |
| Working tree at clone | clean, no local modifications |
| Remote branches | `origin/main` only |
| AI working branch | `ai/rafiq-phase0-baseline` (created from BASE_SHA) |
| Rollback point | BASE_SHA above; `git checkout main` restores untouched state |
| GitHub Issues / PRs | none open or closed (totalCount 0 / 0) |
| Latest CI run | `36055010605` on main HEAD — **success** (analyze, test, debug APK); release APK job allowed to fail |
| CI history | 3 consecutive failures before HEAD (Isar codegen missing in CI) fixed by `2ac5702 ci: generate Isar sources before verification` |

## Project shape

- Flutter Android-first virtual pet (`rafiq`, version 1.0.0+1), Dart SDK >=3.5 <4.0, Flutter pinned 3.47.5 in CI.
- Stack: Riverpod 2.6.1, Isar 3.1.0+1 (with local `third_party/isar_flutter_libs` override), flutter_scene ^0.23.0 (3D), flutter_gemma ^1.8.4 + flutter_gemma_litertlm (local LLM), audioplayers 6.6.0, google_mobile_ads 5.1.0, in_app_purchase 3.3.0, flutter_local_notifications 21.0.0, file_picker ^13.1.0, flutter_overlay_window 0.5.0.
- `lib/`: 42 files across ai/, core/, data/, engine/, features/, providers/, render/, services/, config/, l10n/.
- `test/`: 7 files, 33 test declarations (per roadmap claim; matches file set).
- Assets: 8 MP3 sounds, prototype `dog.glb` + rig manifest, LLM dir has README only (no model binary — intentional).
- Generated code NOT committed: `pet_state.g.dart` (build_runner) and `flutter_scene_generated/` content — both regenerated in CI.
- Android: namespace/appId `com.rafiq.app`, minSdk 26, targetSdk/compileSdk 36, NDK 28.2.13676358, Java 17, minify+shrink on release.
- Duplicate MainActivity paths exist: `kotlin/com/rafiq/app/MainActivity.kt` and `kotlin/com/rafiq/rafiq_base/MainActivity.kt` (leftover; only namespace-matching one is used).
- CI: single workflow `flutter-build.yml` — analyze/test job, debug APK job (uploads artifact), release APK job (continue-on-error, reads `RAFIQ_AD_UNIT_ID`, `RAFIQ_PREMIUM_PRODUCT_ID`, `RAFIQ_MONTHLY_PRODUCT_ID` secrets; none configured).

## Verified configuration facts (evidence, not documentation)

| Fact | Evidence |
|---|---|
| Release build type signs with the **debug** keystore | `android/app/build.gradle` buildTypes.release `signingConfig = signingConfigs.debug` |
| AdMob App ID in manifest is Google's public **test** ID `ca-app-pub-3940256099942544~3347511713` | `android/app/src/main/AndroidManifest.xml` lines 17–19 |
| Interstitial unit falls back to test ID `.../1033173712` | `lib/services/ad_service.dart:6-7` |
| Model URL preflight accepts plain **http://** | `lib/ai/model_install_preflight.dart:139` |
| `AdService.setPremium` exists but has **no callers**; premium never persisted to `PetState.isPremium` | grep verified; `lib/services/purchase_service.dart` |
| `state = updated` assigns the **same mutated PetState instance**; StateNotifier suppresses notification (identical object) | `lib/providers/pet_provider.dart:49-54, 111, 118, 126, 134, 142, 150` |
| l10n ARB + generated localizations exist and are registered, but **no screen uses AppLocalizations** | `lib/app.dart:41`, grep across lib/features |
| Production identifiers are dart-define/secret driven, nothing committed | `lib/config/release_config.dart`, `docs/RELEASE_BUILD.md` |

## Phase 1 — Previous conversation reconciliation

- Supplied ChatGPT share link **is accessible** via browser capability (46,736 chars extracted).
- Keyword scan for `rafiq`, `rafi`, `pet`, `dog`, `flutter`, `virtual`, `رفيق`, `كلب`, `حيوان`: **0 hits**.
- The conversation concerns different projects (`toufikben/Ai_super_cleaner`, "SHIELDRA", Kotlin/Compose, AAD-binding crypto gates) — **no Rafiq/Rafiki project content**.
- Classification: `PREVIOUS_CONVERSATION = ACCESSIBLE_BUT_NOT_RELEVANT` (contains zero Rafiq requirements/decisions). Nothing was invented from it.
- Meta-observation (working style only, not requirements): the user's other project conversations enforce strict evidence-based gates ("trust actual code/CI/diff, never a report; no PASS without verifiable evidence"). This matches the current mission prompt and is already honored by this process.

## Environment constraints noted

- Development PC is weak; no local Android emulator strategy (Phase 10 of mission). Device verification is delegated to user test cards or CI.
- Flutter SDK availability on this machine: not yet verified (`flutter --version` pending before any local build claims).
