import 'package:flutter_gemma/flutter_gemma.dart';

/// Curated on-device model catalog for Batch 9.
///
/// No model binary is bundled or downloaded by this file. Model files are
/// large, immutable, license-specific assets, so installation stays explicit
/// through LocalModelManager (backed by `flutter_gemma` /
/// `flutter_gemma_litertlm`) after the user picks a verified one-tap build or
/// supplies their own licensed `.litertlm` file or URL.
///
/// The default recommendation is the BEST quality option in this catalog
/// ([defaultRecommendedModelId]), not the smallest: pet-chat reply quality
/// was the deciding factor. The install flow always shows the estimated size
/// and Wi-Fi guidance before anything downloads, so the heavier default does
/// not surprise users on mobile data or low storage.
///
/// [modelType] must match the flutter_gemma family type (Qwen3 needs
/// [ModelType.qwen3]; the rest use [ModelType.general]) so the runtime
/// applies the right chat template. [installUrl] is a verified direct
/// `.litertlm` link when one exists; null means no compatible build is
/// published and the entry is shown as unavailable instead of a dead button.
class ModelRecommendation {
  const ModelRecommendation({
    required this.id,
    required this.label,
    required this.params,
    required this.approxSizeMB,
    required this.license,
    required this.source,
    required this.notes,
    required this.modelType,
    this.installUrl,
  });

  final String id;
  final String label;
  final String params;
  final int approxSizeMB;
  final String license;

  /// Human-readable pointer to the official distribution (not a URL).
  final String source;
  final String notes;
  final ModelType modelType;
  final String? installUrl;
}

/// Best-quality default: the model the settings UI recommends first.
const defaultRecommendedModelId = 'qwen3-0.6b';

/// Named small-model options, best quality first. Sizes and links were
/// verified against the official `litert-community` Hugging Face
/// distributions (HEAD check: Qwen3 614,236,160 B; LFM2.5 int4 176,756,720 B).
const recommendedModels = <ModelRecommendation>[
  ModelRecommendation(
    id: 'qwen3-0.6b',
    label: 'Qwen3 0.6B (recommended default)',
    params: '~0.6B',
    approxSizeMB: 586,
    license: 'Apache-2.0 — no token needed',
    source: 'litert-community/Qwen3-0.6B on Hugging Face',
    notes:
        'Best reply quality in this catalog; multilingual; needs Wi-Fi and free-space check.',
    modelType: ModelType.qwen3,
    installUrl:
        'https://huggingface.co/litert-community/Qwen3-0.6B/resolve/main/Qwen3-0.6B.litertlm',
  ),
  ModelRecommendation(
    id: 'lfm2.5-230m',
    label: 'LFM2.5 230M (balanced)',
    params: '~0.23B',
    approxSizeMB: 168,
    license: 'LiquidAI lfm1.0 vendor license — verify before install',
    source: 'litert-community/LFM2.5-230M on Hugging Face',
    notes:
        'Multilingual quality with lower storage and RAM needs; smallest download here.',
    modelType: ModelType.general,
    installUrl:
        'https://huggingface.co/litert-community/LFM2.5-230M/resolve/main/LFM2.5-230M_int4.litertlm',
  ),
  ModelRecommendation(
    id: 'smollm-135m',
    label: 'SmolLM 135M (unavailable)',
    params: '~0.135B',
    approxSizeMB: 135,
    license: 'Apache-2.0 base model',
    source: 'litert-community/SmolLM-135M-Instruct on Hugging Face',
    notes:
        'No .litertlm build is published (only .task/.tflite) and it is English-only, so one-tap install is disabled.',
    modelType: ModelType.general,
  ),
];

/// The catalog entry treated as the default recommendation.
ModelRecommendation get defaultRecommendedModel => recommendedModels.firstWhere(
      (model) => model.id == defaultRecommendedModelId,
      orElse: () => recommendedModels.first,
    );

/// Short storage guidance shown next to the model manager.
String modelStorageGuidance() =>
    'Model files are large (often 100+ MB). Wi-Fi is recommended, and the '
    'download confirmation always shows the estimated size before installing.';
