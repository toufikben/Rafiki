# Optional local language model

The app is wired to `flutter_gemma` with the `flutter_gemma_litertlm` engine. The engine runs a small `.litertlm` model locally on Android and exposes a chat session through `LocalChatService`.

The recommended default is the best-quality option in `lib/ai/recommended_models.dart`: **Qwen3 0.6B** (~500 MB approximate install size), ahead of the balanced **LFM2.5 230M** and the lightest **SmolLM2 135M**. Quality, not size, was the deciding factor; the settings install flow always shows the estimated size with Wi-Fi guidance before downloading. Select the exact model file from the model's official distribution (see the `source` field of each catalog entry, never a copied link) and install it through the `FlutterGemma.installModel(...).fromNetwork(...)` or `.fromFile(...)` API — exposed in-app via `LocalModelManager` and the Settings "Local AI model" dialog — before calling `getActiveModel()`.

Until an active model is installed, the same chat UI remains functional through the bounded local fallback. The fallback uses the pet's current hunger, energy, hydration, happiness, stress, mood, and user text; it never calls a cloud service.

## Android requirements

The LiteRT-LM engine requires Android API 26 or newer. The project therefore uses `minSdk = 26`. Model installation should be an explicit user-facing action with progress, cancellation, storage-space checks, and a Wi-Fi preference rather than an invisible first-launch download.
