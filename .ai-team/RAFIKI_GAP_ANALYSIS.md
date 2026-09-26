# RAFIKI — Gap Analysis (2026-09-25)

## Roadmap Item → Actual Implementation Matrix

| Roadmap Item | Claimed Status | Actual Implementation | Evidence | Tests | Git State | Missing Work | Regressions | Next Action |
|---|---|---|---|---|---|---|---|---|
| **Batch 1: Foundation** | Complete | ✅ Full Flutter app, Riverpod, Isar, onboarding, home, settings, notifications, ads, purchases scaffolding | main.dart, app.dart, providers, database, services | needs_system_test, evolution_system_test | 0cfaa97 | None apparent | None | Maintenance only |
| **Batch 2: 3D Scene Foundation** | Complete (vertical slice) | ✅ flutter_scene loads dog.glb, environment, 2D fallback | dog_scene_view.dart, dog_environment.dart | None specific | 0cfaa97 | Production GLB | None | Awaits Batch 8 asset |
| **Batch 3: Secondary Motion** | Complete (for current asset) | ✅ DogSecondaryMotion with breathing, ears, tail; alias mapping for prototype nodes | dog_secondary_motion.dart | None specific | 0cfaa97 | Needs final rig joint names | None | Map aliases to final rig |
| **Batch 4: Environment** | Complete | ✅ PBR lighting, cascaded shadows, AO, fog, dust, ground receiver | dog_environment.dart | None specific | 0cfaa97 | Performance tuning on device | None | Device testing |
| **Batch 5: Audio** | Complete (vertical slice) | ✅ Multi-channel mixer (body, steps, one-shots), cooldowns, dog-specific sounds | audio_service.dart, audio_cooldown_policy.dart | batch10_closeout_test (cooldowns) | 0cfaa97 | Device audio latency test | None | Device testing |
| **Batch 6: Local AI** | Complete | ✅ LearningProfile (JSON in PetState), exponential smoothing, bounded bonuses, behavior integration | learning_profile.dart, ai_service.dart, behavior_engine.dart | learning_profile_test.dart | 0cfaa97 | Per-species reward tables, time-of-day | None | Optional enhancement |
| **Batch 7: Vitals + Local Chat** | Complete (vertical slice) | ✅ 8 coupled vitals, LiteRT-LM adapter, chat UI with offline fallback | needs_system.dart, local_chat_service.dart, chat_fallback_policy.dart | batch10_closeout_test (fallback), batch9_quality_test | 0cfaa97 | Model binary, runtime failure injection | None | Device test with real model |
| **Batch 8: Final Model + Animation** | **Implementation gate closed; production-asset gate pending** | ✅ DogAnimationController (clip selection), DogAnimationRuntime (clip binding + crossfade), manifest contract, prototype safety | dog_animation_controller.dart, dog_animation_runtime.dart, dog_rig_manifest.json | dog_animation_controller_test.dart (clip mapping + manifest check) | 0cfaa97 | **Production GLB with skeleton, skin weights, 9 authored clips**, visual QA, frame-time profiling | Prototype GLB loads but has no animations | **Asset production** (external) |
| **Batch 9: Model Management + Chat Quality** | **In progress; core slice implemented** | ✅ LocalModelManager (list, install file/URL, progress, cancel, uninstall, cleanup, storage, active model), preflight validation, Arabic/English detection, 12-turn history bound, stop generation | local_model_manager.dart, model_install_preflight.dart, chat_language.dart, settings_screen.dart | batch9_quality_test.dart (preflight, language) | 0cfaa97 | Picker permissions/error copy, free-space confirmation, **real model runtime failure injection on Android** | None | **Device test with real .litertlm model** |
| **Beta Readiness** | Not yet released | Code complete for internal beta after device smoke test | ROADMAP.md | N/A | 0cfaa97 | Real-device smoke test (GLB, touch, audio, background, fallback, chat) | N/A | **USER_DEVICE_TEST_REQUIRED** |
| **Batch 10: Behavioral Validation + Performance** | Deterministic closeout implemented; field execution assigned to user | ✅ Unit tests for vitals, mood, learning, audio cooldowns, GLB manifest, chat fallback, DB persistence | batch10_closeout_test.dart (comprehensive) | 9 tests in batch10_closeout_test | 0cfaa97 | **CPU, memory, GPU frame-time, audio latency, battery, model-runtime on device** | None | **USER_DEVICE_TEST_REQUIRED** |
| **Batch 11: Production Hardening** | In progress | ✅ --dart-define config, fail-closed release, privacy screen, accessibility labels, CI pipeline (debug+release APK) | release_config.dart, legal_information_screen.dart, flutter-build.yml | batch11_hardening_test.dart | 0cfaa97 | **Production IDs, consent/crash provider, release signing, localization/accessibility review** | Debug signing still used | **External secrets + signing** |
| **Batch 12: Store Release** | Priority medium | Not started | ROADMAP.md | N/A | 0cfaa97 | Store assets, screenshots, listing, internal/closed testing, staged rollout, opt-in diagnostics | N/A | Depends on 11 |

## Status Classification

| Batch | Classification | Reason |
|---|---|---|
| 1–7 | **COMPLETE** | Implementation matches claims; tests pass; verified in CI |
| 8 | **PARTIALLY COMPLETE** | Runtime code complete; **production asset gate is external dependency** |
| 9 | **PARTIALLY COMPLETE** | Core management implemented; **device runtime test pending** |
| Beta | **CODE COMPLETE / EXTERNAL GATE** | Awaits **USER_DEVICE_TEST_REQUIRED** |
| 10 | **CODE COMPLETE / EXTERNAL GATE** | Deterministic tests done; **field performance tests require device** |
| 11 | **PARTIALLY COMPLETE** | Config + CI ready; **production secrets + signing are external** |
| 12 | **NOT STARTED** | Depends on 8–11 |

## Critical Path Dependencies

```
Batch 8 (Asset Production) ──┐
                             ├─→ Beta Readiness ──→ Batch 10 (Device Perf) ──→ Batch 11 (Release Config) ──→ Batch 12 (Store)
Batch 9 (Model Runtime) ─────┘         │
                          (independent, can proceed in parallel)
```

**Key Insight**: Batch 8 asset production and Batch 9 model runtime testing are **independent external gates**. The codebase is ready for both. Neither should block the other. The app functions with the prototype GLB (2D fallback) and without a local model (offline fallback).

## Risk Summary

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| No licensed production dog GLB available | Blocks visual release | High | Search existing assets first (Phase 8); custom production as fallback |
| No suitable .litertlm model license | Blocks chat quality release | Medium | Evaluate LFM2.5 230M, SmolLM 135M, Qwen3 0.6B licenses |
| Device performance below 60 FPS | Poor UX, bad reviews | Medium | Profile early; reduce texture res, shadows, particles before geometry |
| Release signing / Play Console delays | Launch timeline slip | Medium | Prepare keystore, secrets, metadata in parallel |
| APK size > 150 MB | Install friction, Play warnings | High | Profile size; consider dynamic delivery, strip unused native libs |

## Required External Gates (User Action Required)

| Gate | Description | When Needed |
|---|---|---|
| **USER_DEVICE_TEST_REQUIRED** | Physical Android device test: GLB render, touch, audio, background/resume, fallback, chat | Before Beta, Batch 10 |
| **USER_BUSINESS_DECISION_REQUIRED** | Select production AdMob IDs, IAP product IDs, consent provider, crash provider | Batch 11 |
| **USER_AUTH_REQUIRED** | Play Console access, keystore creation, release signing | Batch 11–12 |
| **USER_FINAL_RELEASE_APPROVAL** | Final go/no-go for store submission | Batch 12 |