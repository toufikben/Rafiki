# RAFIKI — Forensic Baseline (2026-09-25)

## Repository State

| Item | Value |
|---|---|
| **Repository** | https://github.com/toufikben/Rafiki |
| **Current Branch** | main |
| **HEAD SHA** | 0cfaa9711106e68eb48791227b94f049e150581b |
| **Remote** | origin → https://github.com/toufikben/Rafiki.git (fetch/push) |
| **Working Tree** | Clean (no uncommitted changes) |
| **Upstream Sync** | Up to date with origin/main |

## Git History (Recent 10 Commits)

| SHA | Date | Message |
|---|---|---|
| 0cfaa97 | 2026-09-24 | fix: use redirect history for model URL validation |
| d31a8b0 | 2026-09-24 | feat: harden model URL preflight |
| d930d91 | 2026-09-24 | docs: record accessibility batch verification |
| 7ab6aec | 2026-09-24 | feat: improve accessibility labels for pet controls |
| 2ac5702 | 2026-09-24 | ci: generate Isar sources before verification |
| 32cf9e7 | 2026-09-24 | docs: synchronize roadmap with current verification state |
| c3da7c1 | 2026-09-24 | feat: add manual pet test controls |
| 1864033 | 2026-09-24 | feat: add live pet status hud |
| df55768 | 2026-09-24 | ci: automate debug and release apk builds |
| d3831a6 | 2026-09-24 | feat: begin production hardening |

## Project Structure

```
rafiki/
├── .github/workflows/flutter-build.yml
├── android/                     # Android Gradle project (minSdk 26, compileSdk 36)
├── assets/
│   ├── models/
│   │   ├── dog/                 # dog.glb (113KB prototype), dog_rig_manifest.json, README.md
│   │   └── llm/                 # README.md (model policy)
│   └── sounds/                  # dog_*.mp3 + generic pet sounds, DOG_SOUNDS.md
├── docs/
│   ├── RELEASE_BUILD.md
│   └── DEBUG_APK_INSPECTION.md
├── flutter_scene_generated/     # Build output dir (empty except .gitignore)
├── lib/
│   ├── ai/                      # Local chat, model manager, learning profile
│   ├── config/release_config.dart
│   ├── core/constants/          # app_colors, pet_species
│   ├── core/models/             # pet_state, behavior_type, behavior_decision
│   ├── data/database.dart       # Isar persistence
│   ├── engine/                  # needs_system, behavior_engine, evolution_system
│   ├── features/
│   │   ├── home/                # home_screen, manual_test_controls, pet_status_hud
│   │   ├── onboarding/onboarding_screen.dart
│   │   └── settings/            # settings_screen, legal_information_screen
│   ├── l10n/                    # AR/EN localization
│   ├── main.dart                # App entry + floating overlay entry
│   ├── providers/pet_provider.dart
│   ├── render/                  # 2D painter, 3D scene, animation, secondary motion
│   └── services/                # audio, ads, purchases, notifications, floating
├── reference_images/            # 4 visual references + requirements docs
├── test/                        # 7 test files (33 test declarations)
├── third_party/isar_flutter_libs/ # Local Isar override
├── analysis_options.yaml
├── pubspec.yaml / pubspec.lock
├── README.md
├── ROADMAP.md
├── CHANGELOG.md
├── AI_LEARNING.md
├── BATCH_8_CLOSEOUT.md
├── BATCH_8_9_PROGRESS.md
├── FINAL_3D_MODEL_ANIMATION_PLAN.md
├── 3D_RIG_MATERIALS_ANDROID_SPEC.md
└── l10n.yaml
```

## Key Technical Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.47.5 (stable) / Dart 3.5+ |
| State | flutter_riverpod 2.6.1 |
| Persistence | Isar 3.1.0+1 (local NoSQL) |
| 3D Rendering | flutter_scene ^0.23.0 (Impeller/GPU) |
| Audio | audioplayers 6.6.0 (multi-channel mixer) |
| Local LLM | flutter_gemma ^1.8.4 + flutter_gemma_litertlm ^1.0.1 |
| Notifications | flutter_local_notifications 21.0.0 |
| Ads | google_mobile_ads 5.1.0 (test IDs in debug) |
| IAP | in_app_purchase 3.3.0 (test IDs in debug) |
| Overlay | flutter_overlay_window 0.5.0 |
| File Picker | file_picker ^13.1.0 |
| Build | build_runner 2.4.13 + isar_generator |

## Android Configuration

| Setting | Value |
|---|---|
| Namespace | com.rafiq.app |
| compileSdk | 36 |
| minSdk | 26 (required for LiteRT-LM) |
| targetSdk | 36 |
| Java/Kotlin | 17 |
| NDK | 28.2.13676358 |
| Signing | Debug config only (release uses debug placeholder) |
| Permissions | SYSTEM_ALERT_WINDOW, FOREGROUND_SERVICE, POST_NOTIFICATIONS, INTERNET, VIBRATE, BILLING |

## CI/CD (GitHub Actions)

**Workflow**: `.github/workflows/flutter-build.yml`

Jobs:
1. **analyze-and-test** → flutter analyze + flutter test -j 1 (Isar generation first)
2. **build-debug** → flutter build apk --debug → upload artifact (14-day retention)
3. **build-release** → flutter build apk --release with --dart-define for production IDs (continue-on-error: true)

Secrets required for release:
- RAFIQ_AD_UNIT_ID
- RAFIQ_PREMIUM_PRODUCT_ID
- RAFIQ_MONTHLY_PRODUCT_ID

## Verification Status (Last Successful Run: 2026-09-22)

| Check | Status |
|---|---|
| Isar source generation | ✅ Pass |
| flutter analyze | ✅ Pass |
| flutter test (33 declarations, 7 files) | ✅ Pass |
| flutter build apk --debug | ✅ Pass (311 MB) |
| flutter build apk --release | ⚠️ Allowed to fail (no production secrets) |

## Critical Assets

| Asset | Path | Status |
|---|---|---|
| Dog GLB (prototype) | assets/models/dog/dog.glb | 113 KB static prototype, no animations |
| Dog Rig Manifest | assets/models/dog/dog_rig_manifest.json | Contract for 9 clips + 18 skeleton nodes |
| Visual References | reference_images/ | 4 images (monkey, puppy, fox, penguin) |
| Dog Sounds | assets/sounds/ | 6 files (breathing, panting, bark, whine, steps, happy) |

## Known Gaps (from ROADMAP.md)

| Gap | Batch |
|---|---|
| Production rigged dog.glb + authored clips | 8 |
| Bundled LocalLLM binary (.litertlm) | 9 |
| Model download/import screen (file picker + URL) | 9 (partially done) |
| 3D visual QA on physical devices | 8–10 |
| Real-device smoke test (touch/audio/3D) | Beta/8–10 |
| APK size optimization | Beta/9–11 |
| Production AdMob/IAP identifiers | 11 |
| Release signing + Play Console metadata | 11–12 |
| Privacy/consent/terms legal review | 11 |
| Broader automated test coverage | 10 |

## Previous Conversation

**PREVIOUS_CONVERSATION = BLOCKED_EXTERNAL_DEPENDENCY** — The shared ChatGPT conversation (https://chatgpt.com/share/6ab5111c-fec4-83e9-bf68-643784a4c66b) cannot be accessed via configured browser capability. No contents invented.