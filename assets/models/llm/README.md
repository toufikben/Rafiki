# Optional local language model

The app is wired to `flutter_gemma` with the `flutter_gemma_litertlm` engine. The engine runs a small `.litertlm` model locally on Android and exposes a chat session through `LocalChatService`.

No model binary is committed to this repository because even a small on-device model is a large immutable asset. The first recommended profile for this pet chat is a public sub-1B instruction model supported by `flutter_gemma`, such as **LFM2.5 230M**, **SmolLM 135M**, or **Qwen3 0.6B**. Select the exact model file from the model's official distribution and install it through the `FlutterGemma.installModel(...).fromNetwork(...)` or `.fromFile(...)` API before calling `getActiveModel()`.

Until an active model is installed, the same chat UI remains functional through the bounded local fallback. The fallback uses the pet's current hunger, energy, hydration, happiness, stress, mood, and user text; it never calls a cloud service.

## Android requirements

The LiteRT-LM engine requires Android API 26 or newer. The project therefore uses `minSdk = 26`. Model installation should be an explicit user-facing action with progress, cancellation, storage-space checks, and a Wi-Fi preference rather than an invisible first-launch download.
