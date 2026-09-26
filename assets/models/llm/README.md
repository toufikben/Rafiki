# Optional local language model

The app is wired to `flutter_gemma` with the `flutter_gemma_litertlm` engine. The engine runs a small `.litertlm` model locally on Android and exposes a chat session through `LocalChatService`.

The recommended default is the best-quality option in `lib/ai/recommended_models.dart`: **Qwen3 0.6B** (~586 MB verified install size, multilingual, Apache-2.0), ahead of the balanced multilingual **LFM2.5 230M int4** (~168 MB verified). Quality, not size, was the deciding factor; the settings install flow always shows the estimated size with Wi-Fi guidance before downloading. Both ship as one-tap verified downloads in the Settings "Local AI model" dialog (same preflight + confirmation as a custom URL) and install with their correct flutter_gemma family type (`ModelType.qwen3` for Qwen3, `general` otherwise). **SmolLM 135M is listed as unavailable**: no `.litertlm` build is published (only `.task`/`.tflite`) and it is English-only. A custom licensed `.litertlm` file or URL can still be installed through `LocalModelManager` before calling `getActiveModel()`.

Until an active model is installed, the same chat UI remains functional through the bounded local fallback. The fallback uses the pet's current hunger, energy, hydration, happiness, stress, mood, and user text; it never calls a cloud service.

## Android requirements

The LiteRT-LM engine requires Android API 26 or newer. The project therefore uses `minSdk = 26`. Model installation should be an explicit user-facing action with progress, cancellation, storage-space checks, and a Wi-Fi preference rather than an invisible first-launch download.
