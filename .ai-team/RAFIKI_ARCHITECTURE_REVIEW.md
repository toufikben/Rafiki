# RAFIKI Architecture Review — Phase 7 (deep review at BASE_SHA 0cfaa97)

Scope: all 42 `lib/` files, 7 test files, Android build config, manifest. Claims marked ✅ were independently re-verified against source by the lead; others come from a full-tree read and are consistent with spot checks.

## 1. Runtime flow (actual, not documented)

**Cold start** (`main.dart`): FlutterGemma.initialize is wrapped in try/catch ✅, but `Database.init`, `MobileAds.initialize`, `PurchaseService.init` are awaited unguarded **before** `runApp` → white-screen/ANR surface if any throws. `PetNotifier._init` awaits `_ai.init()` (LLM) before loading the pet from Isar; until then `petProvider == null` and `app.dart` shows Onboarding → **onboarding flash for existing users**. ✅

**Home loop**: `HomeScreen` owns a 100 ms `Timer` driving `BehaviorEngine.decide` + `movePet`; `PetNotifier` owns a 1 Hz `_tick` running NeedsSystem/EvolutionSystem + `Database.savePet` (unawaited, no error handling). ✅

**State propagation defect (P0)**: `NeedsSystem.update` mutates and returns the *same* `PetState` instance; `state = updated` (`pet_provider.dart:54`) and `state = state` (:118/:126/:134/:142/:150) assign an identical object. `StateNotifier` compares with `==` (identity for PetState) → **watchers are never notified by the simulation tick**. Stat bars (`home_screen.dart` stat row) only refresh on incidental `setState` (scene status changes, manual controls). ✅ This is the single most impactful functional bug: the core "living pet" feedback loop is visually frozen.

**Delete-all-data defect (P0)**: `settings_screen.dart` clears Isar, but `PetNotifier` keeps the in-memory pet and `_tick` re-saves it within 1 s. No provider invalidation, no navigation to onboarding. Deletion silently un-does itself. ✅ (privacy-relevant)

## 2. Subsystem health

| Subsystem | Verdict | Notes |
|---|---|---|
| NeedsSystem / EvolutionSystem | Solid pure logic | Well tested. `BehaviorType.eating` never selected; mood `'happy'` unreachable but branched in painter/HUD (dead paths) |
| Riverpod layer | **Broken notification semantics** | See P0. Also 1 Hz unconditional DB write (flash wear); `movePet` bounds hardcoded 350×550 |
| Isar persistence | Works; codegen-dependent | `pet_state.g.dart` generated in CI only; `third_party/isar_flutter_libs` override present; learning profile stored as JSON string (deliberate schema-stability hack) |
| Behavior engine | Untested | 100 ms tick, mood rules then weighted random with learning bonus; no tests at all |
| Local chat (LocalChatService/fallback) | Good design, lifecycle races | 12-turn session recreation, stop action, deterministic bilingual fallback (tested). Chat bottom sheet (`home_screen.dart:295-403`) disposes controller while `send()` may be in flight → setState-after-dispose risk |
| Model management | Good; one security hole | Explicit install only, CancelToken, orphan cleanup, confirmation dialog. ✅ `model_install_preflight.dart:139` accepts `http://` → MITM can substitute the on-device model binary; HEAD preflight trusts server Content-Length |
| 2D renderer | Fine | `shouldRepaint` always true (acceptable with the timer architecture) |
| 3D renderer (flutter_scene) | Prototype scope; lifecycle question open | `DogSceneView.dispose` only nulls the animation runtime. **Correction after API verification** (fscene.dev docs 0.22.1): flutter_scene `Scene` exposes **no `dispose()`**; cleanup is `remove`/`removeAll` + node-level disposal, and the actual retention cost needs device profiling before any change. `initializeStaticResources()` re-runs per widget instance; animation runtime is a designed no-op until authored clips exist |
| Secondary/interaction motion | Fine | Spring/procedural, fail-safe on missing joints |
| Audio | Works; two gaps | Cooldown policy tested. Sound-effects toggle **not persisted** (`settings_screen.dart:52`); Play action uses `playMeow` even for dogs (`home_screen.dart:161`) |
| Notifications | Mostly dead | `showMissingYou` never called; nothing scheduled; evolution notification only fires while foregrounded; POST_NOTIFICATIONS requested every launch |
| Ads | Fails closed correctly in release | ✅ `ReleaseConfig.adsConfigured` gate is sound; **but** manifest App ID is Google's public test ID and interstitial falls back to test unit → real ads can never serve without a manifest change; `setPremium` has zero callers ✅ |
| IAP / premium | **Disconnected plumbing** | `PurchaseService._isPremium` never persisted, never written to `PetState.isPremium` (dead field), never passed to AdService; `buyPremium` has no UI; monthly product grants nothing. Paying users would see ads and gain no state |
| Overlay (floating pet) | Stale snapshot | `overlayMain` reads pet once; MethodChannel handler returns null; second process touches same Isar store |
| l10n | Registered, unused | ARB (en/ar) + generated classes exist, `app.dart` wires delegates, **no screen uses AppLocalizations** — all UI strings hardcoded English. Product targets Arabic market (README bilingual) |
| Accessibility | Partial | Labels added for pet controls/chat/model-delete (commit 7ab6aec); no Semantics on HUD/stat rows; manual test controls ship in production AppBar |
| Release config | Sound design, placeholder signing | dart-define fail-closed flags tested (batch11). ✅ `build.gradle` release uses `signingConfigs.debug` |
| Privacy | Good boundary | No pet/chat data leaves device. Off-device surfaces: AdMob SDK (ad IDs), user-initiated model URL downloads, Play Billing. No analytics/crash reporting present |

## 3. Test coverage reality

Covered (33 tests, CI-green): needs decay/bounds/mood, evolution thresholds, learning-profile round-trip + corrupt fallback, animation controller clip mapping + manifest contract, language detection, preflight rejections, audio cooldown windows, chat fallback content + prompt-injection refusal, real Isar save/restore/delete, ReleaseConfig fail-closed.

**Untested high-risk areas**: `PetNotifier` (would have caught the P0), BehaviorEngine decisions, LocalChatService turn cap/cancel, AdService frequency/premium gating, PurchaseService stream handling, all widgets (chat sheet, settings delete flow), DogSceneView lifecycle, notification flows, overlay entry point.

Lesson: "flutter test green" + roadmap "complete" masked a frozen core UI loop. New tests must pin provider notification semantics and the delete-all flow.

## 4. Dependency quality

- Pinned exact versions for risk-bearing deps (riverpod, isar, ads, IAP, notifications) — good reproducibility.
- `hooks` and `google_fonts` dependencies are **unused** (bloat).
- Isar 3.1.0+1 is unmaintained upstream (project already carries a `third_party` override) — acceptable for now; note as long-term migration risk (objectbox/drift or isar fork).
- flutter_scene ^0.23.0 is a fast-moving Flutter-team package; CI pins Flutter 3.47.5 — keep the pin.

## 5. CI / release reproducibility

- Single workflow: analyze+test → debug APK (artifact) → release APK (continue-on-error, secrets empty). Green at HEAD (run 36055010605). ✅
- Reproducible from clean checkout **only if** codegen steps run (documented in README; CI does run build_runner). ✅
- No AAB job yet (Play requires AAB); no artifact for release channel; no signing secrets — all external gates.
