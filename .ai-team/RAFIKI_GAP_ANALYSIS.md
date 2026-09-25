# RAFIKI Gap Analysis — Phase 2 Roadmap Reconciliation

Method: every roadmap claim checked against actual code/git/CI evidence at BASE_SHA `0cfaa97`. "Complete" in ROADMAP.md means *implementation claimed*; the matrix below records *actual* state.

## Batch matrix

| Roadmap item | Claimed status | Actual state (evidence) | Classification | Missing work | Next action |
|---|---|---|---|---|---|
| Batch 1 — foundation & core loop | complete | Code exists; tests pass in CI. **BUT provider never notifies watchers on tick** (`pet_provider.dart:54` same-instance assign) → UI stat bars frozen; **Delete-All-Data re-saves pet within 1 s** (`settings_screen.dart` + `_tick`); startup awaits LLM/ads/IAP before `runApp` (`main.dart:15-29`) → ANR/white-screen surface; onboarding flash because pet loads after `_ai.init()` (`pet_provider.dart:24-27`) | **BROKEN (partial)** | Immutable state notify or forced notify; real delete-all (reset provider + navigate); resilient startup ordering | AI-fixable now — top priority |
| Batch 2 — 3D scene foundation | complete for vertical slice | `DogSceneView` loads prototype GLB, 2D fallback works; **Scene not disposed** (`dog_scene_view.dart:97-102`), `initializeStaticResources()` per instance | PARTIALLY COMPLETE | Scene lifecycle fix, visual QA on device | AI-fixable (dispose); device QA later |
| Batch 3 — secondary motion | complete for asset contract | Name-driven procedural motion present; fail-safe; untested math | CODE COMPLETE (prototype scope) | Tests for motion math optional | None blocking |
| Batch 4 — environment | complete | Implemented, switchable; mobile-conscious | COMPLETE (prototype scope) | Device GPU/frame-time QA | Batch 10 device gate |
| Batch 5 — interactive audio | complete for slice | Mixer + cooldowns exist with tests; **sound toggle not persisted** (`settings_screen.dart:52`); species-blind Play sound (`home_screen.dart:161`) | PARTIALLY COMPLETE | Persist audio setting; species-correct cues | AI-fixable now |
| Batch 6 — local adaptive intelligence | complete | LearningProfile versioned JSON, bounded, tested; `BehaviorType.eating` never selected; mood `'happy'` unreachable in NeedsSystem but branched in UI | CODE COMPLETE (minor dead paths) | Behavior/mood reachability cleanup | Low priority |
| Batch 7 — vitals & local chat | complete for slice | Coupled needs tested; LiteRT-LM adapter + fallback tested; **chat sheet lifecycle races** (`home_screen.dart:295-403` dispose vs in-flight send/stop); **http:// model URLs accepted** (`model_install_preflight.dart:139`) | PARTIALLY COMPLETE | HTTPS-only preflight; chat sheet state hardening | AI-fixable now |
| Batch 8 — final model/animation | implementation gate closed; production-asset gate pending | Prototype static GLB committed, manifest says `prototype_static_glb`, runtime clip binder is designed no-op without authored clips. Claim matches code | CODE COMPLETE / **EXTERNAL GATE** (licensed rigged GLB + authored clips + Android visual QA) | Asset sourcing/production; device QA | Reuse audit for licensed dog assets (Phase 8 of mission); USER_DEVICE_TEST_REQUIRED for visual QA |
| Batch 9 — model management & chat quality | in progress; core slice implemented | Manager, preflight, confirmation dialog, Wi-Fi warning, cancel/retry/uninstall implemented; roadmap's own "no model download/import screen" gap row is **STALE** (it exists now). Runtime failure injection on real device pending | PARTIALLY COMPLETE | HTTPS-only fix; device failure-injection test; picker permission polish | AI-fixable part now; device part gated |
| Batch 10 — behavioral validation & performance | deterministic closeout implemented; field execution assigned to user | 7 test files / 33 tests pass in CI. No CPU/GPU/battery/audio-latency measurement exists anywhere | CODE COMPLETE / **EXTERNAL GATE** (physical device) | Field smoke test; perf budgets | USER_DEVICE_TEST_REQUIRED card |
| Batch 11 — production hardening | in progress | dart-define config + fail-closed release flags + CI artifacts done (verified). **Release signed with debug key** (`build.gradle`), **test AdMob App ID in manifest**, premium entitlement **not wired end-to-end** (purchase → persist → ad suppression → UI: none connected), l10n registered but unused, accessibility partial, no consent/crash provider | PARTIALLY COMPLETE | Signing pipeline (external keystore), real IDs (external), premium wiring (AI-fixable), l10n adoption (AI-fixable), consent/crash decision (USER_BUSINESS_DECISION_REQUIRED) | Mixed; AI-fixable parts now |
| Batch 12 — store release | medium priority, not started | Nothing in repo beyond docs | NOT STARTED | Store assets, listing, internal testing, staged rollout | Gated on Batches 8/10/11 |
| Beta readiness | not yet released | Accurate: debug APK builds in CI; device smoke test outstanding | STALE-FREE / EXTERNAL GATE | Device smoke test | USER_DEVICE_TEST_REQUIRED |

## Stale documentation found

1. ROADMAP "Known remaining gaps" row *"No model download/import screen"* contradicts Batch 9 text and actual code (screen exists) — must be removed/updated.
2. README claims "Batches 1–7 are implemented and pass the current automated verification" — automated verification passes, but Batch 1/5/7 have real runtime defects (frozen UI notifications, delete-all undone, chat sheet races) that no test covers. Documentation overstates functional completeness.

## Highest-value executable-now queue (independent of external gates)

1. **P0 Provider notification bug** — UI is frozen for the core loop; single highest user-value defect.
2. **P0 Delete-all-data ineffective** — privacy-relevant (data returns after deletion).
3. **P1 HTTPS-only model preflight** — one-line security fix (MITM model substitution).
4. **P1 Startup resilience** — don't block `runApp` on ads/IAP/Gemma; load pet before LLM init.
5. **P1 Premium entitlement wiring** — purchase persist → `AdService.setPremium` → gating; otherwise monetization is fake.
6. **P2 Chat sheet lifecycle hardening; scene disposal; audio-setting persistence; species-correct sounds.**
7. **P2 l10n adoption** — ARB files exist; screens hardcode English (Arabic market is a stated product goal).

## External gates (cannot be closed by code alone)

- Licensed production rigged `dog.glb` + authored clips (Batch 8).
- Physical-device visual/perf/audio QA (Batches 8/10, beta).
- Release keystore + Play Console + production AdMob/IAP IDs (Batch 11).
- Consent/crash-reporting provider choice (business + privacy decision).
- Model binary selection/licensing (Batch 9).
