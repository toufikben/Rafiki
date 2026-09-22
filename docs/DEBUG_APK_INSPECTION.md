# Debug APK inspection

**Artifact:** `build/app/outputs/flutter-apk/app-debug.apk`  
**Build command:** `flutter build apk --debug`

## Result

The debug APK was produced successfully and recognized as a valid Android package. The archive passed `unzip -t` integrity verification.

| Check | Result |
|---|---:|
| File type | Android package (APK) |
| Size | 326,150,881 bytes |
| Approximate size | 311.1 MiB |
| SHA-256 | `180bba3e4aa3c87948d1440cee96411bbb5962e9a777613bee17e83fa68f07f4` |
| DEX files | 21 |
| Native libraries | 32 |
| ZIP integrity | Passed |

This is a debug artifact for device inspection, not a store-ready release artifact. The release build remains dependent on production identifiers, a release keystore, signing configuration, consent/crash-reporting decisions, and Play Console verification.
