# Android build pipeline

## Local debug build

```bash
flutter analyze
flutter test -j 1
flutter build apk --debug
```

The debug artifact is written to `build/app/outputs/flutter-apk/app-debug.apk`. Debug builds may use the official Google test AdMob identifier when no identifier is supplied.

## Local release build

The release configuration reads production identifiers from `--dart-define` values:

```bash
flutter build apk --release \
  --dart-define=RAFIQ_AD_UNIT_ID="ca-app-pub-..." \
  --dart-define=RAFIQ_PREMIUM_PRODUCT_ID="rafiq_premium_lifetime" \
  --dart-define=RAFIQ_MONTHLY_PRODUCT_ID="rafiq_monthly"
```

A release build without production identifiers fails closed for ads and purchases. The current Android Gradle configuration still uses the debug signing configuration as a development placeholder; a store release must use a keystore and signing secrets outside the repository.

`android/app/src/main/AndroidManifest.xml` currently declares Google's sample AdMob application ID (`ca-app-pub-3940256099942544~3347511713`) for debug builds. Replace that `APPLICATION_ID` meta-data value with the production AdMob app ID at release time; do not commit the production value. The in-code ad unit and purchase product IDs continue to arrive via the `--dart-define` values above.

## GitHub Actions

`.github/workflows/flutter-build.yml` runs analysis and tests, then builds and uploads both debug and release APK artifacts. The release job is intentionally allowed to fail while signing and production secrets are not configured. Configure these repository or environment secrets before a real release build:

- `RAFIQ_AD_UNIT_ID`
- `RAFIQ_PREMIUM_PRODUCT_ID`
- `RAFIQ_MONTHLY_PRODUCT_ID`

Keystore material must not be committed. Add it through the repository's protected secret or environment configuration only when release signing is ready.
