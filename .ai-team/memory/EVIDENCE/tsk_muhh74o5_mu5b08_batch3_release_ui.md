# Evidence — batch 3: release gaps + UI polish

Task: tsk_muhh74o5_mu5b08 | Date (UTC): 2026-09-25 | Branch: ai/tsk-muhh74o5-mu5b08

## Release gaps closed in code/docs
- `android/app/src/main/AndroidManifest.xml`: comment marks the AdMob
  `APPLICATION_ID` as Google's sample ID for debug; production app ID must
  replace it at release time and must never be committed.
- `docs/RELEASE_BUILD.md`: documents the manifest app-ID swap alongside the
  existing `--dart-define` flow (`RAFIQ_AD_UNIT_ID`,
  `RAFIQ_PREMIUM_PRODUCT_ID`, `RAFIQ_MONTHLY_PRODUCT_ID`).
- `lib/config/release_config.dart` (existing, reused): release builds fail
  closed when production identifiers are absent; test ads/purchases only in
  debug. `AdService`/`PurchaseService` reuse it — no custom payment/ads code.
- Consent/privacy: `LegalInformationScreen` (existing) stays linked from
  Settings AND is now also reachable from onboarding; onboarding states the
  on-device privacy boundary before first use. No consent SDK was added:
  consent/crash-reporting provider selection is an explicit external owner
  decision (see ROADMAP Batch 11).
- `ROADMAP.md` / `CHANGELOG.md`: updated to the true state (named default
  model, measured prototype facts, manifest app-ID gate, onboarding polish).

## Lightweight Play-policy pass (NOT a full orchestrator audit)
The full `play-policy-insights` orchestrator run was not possible here (needs
its Python scripts + Android CLI + subagents, none present). Manual static
pass over `AndroidManifest.xml` + Dart:
- Permissions: SYSTEM_ALERT_WINDOW + FOREGROUND_SERVICE_SPECIAL_USE (overlay
  pet feature, service declares `specialUse` subtype), POST_NOTIFICATIONS,
  INTERNET, VIBRATE, BILLING. No location/contacts/SMS/camera/microphone.
- No precise-data collection in code; chat/models stay on-device; privacy
  screen + Delete All Data exist.
- Test AdMob IDs only; release fails closed. Full audit + Data Safety form
  remain pre-release gates for the owner.

## UI polish
- Home + settings polish from the working tree kept (chat privacy/empty-state
  copy, HUD semantics, labeled stat percentages, model-dialog copy now led by
  the best-quality default).
- Onboarding (this batch): `labelText` on the name field (was hint-only),
  `Semantics(button, selected)` on species options, privacy/terms entry
  button. No design-system changes; existing warm theme kept.

## Verification available here
- Static review only (no Flutter SDK local). CI `flutter-build.yml`
  (analyze + test + debug APK) is the interim check; release job stays
  allow-to-fail until signing/secrets exist.
- No secrets printed or committed (dart-defines stay in CI secrets).
