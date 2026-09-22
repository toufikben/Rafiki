# Debug APK inspection

**Artifact:** `build/app/outputs/flutter-apk/app-debug.apk`  
**Build command:** `flutter build apk --debug`

## Result

The debug APK was produced successfully and recognized as a valid Android package. The archive passed `unzip -t` integrity verification.

| Check | Result |
|---|---:|
| File type | Android package (APK) |
| Size | 326,175,029 bytes |
| Approximate size | 311.1 MiB |
| SHA-256 | `d70474603c781d571e78d6d9450eebea50da10a9fa0ded8d7105ab46c8f7b144` |
| DEX files | 21 |
| Native libraries | 32 |
| ZIP integrity | Passed |

This is a debug artifact for device inspection, not a store-ready release artifact. The release build remains dependent on production identifiers, a release keystore, signing configuration, consent/crash-reporting decisions, and Play Console verification.
