/// Curated on-device model catalog for Batch 9.
///
/// No model binary is bundled or downloaded by this file. Model files are
/// large, immutable, license-specific assets, so installation stays explicit
/// through LocalModelManager (backed by `flutter_gemma` /
/// `flutter_gemma_litertlm`) after the user supplies a licensed `.litertlm`
/// file or URL.
///
/// The default recommendation is the BEST quality option in this catalog
/// ([defaultRecommendedModelId]), not the smallest: pet-chat reply quality
/// was the deciding factor. The install flow always shows the estimated size
/// and Wi-Fi guidance before anything downloads, so the heavier default does
/// not surprise users on mobile data or low storage.
///
/// Entries name real model families supported by the LiteRT-LM engine. The
/// [source] field names the official distribution to look for; it is
/// deliberately not a download URL, because URLs rot and the user must verify
/// the license and the `.litertlm` conversion of whichever build they
/// install.
class ModelRecommendation {
  const ModelRecommendation({
    required this.id,
    required this.label,
    required this.params,
    required this.approxSizeMB,
    required this.license,
    required this.source,
    required this.notes,
  });

  final String id;
  final String label;
  final String params;
  final int approxSizeMB;
  final String license;

  /// Human-readable pointer to the official distribution (not a URL).
  final String source;
  final String notes;
}

/// Best-quality default: the model the settings UI recommends first.
const defaultRecommendedModelId = 'qwen3-0.6b';

/// Named small-model options, best quality first.
const recommendedModels = <ModelRecommendation>[
  ModelRecommendation(
    id: 'qwen3-0.6b',
    label: 'Qwen3 0.6B (recommended default)',
    params: '~0.6B',
    approxSizeMB: 500,
    license: 'Verify against the official Qwen3 distribution before install',
    source: 'Official Qwen3 0.6B LiteRT-LM / .litertlm release artifacts',
    notes:
        'Best reply quality in this catalog; needs Wi-Fi and free-space check.',
  ),
  ModelRecommendation(
    id: 'lfm2.5-230m',
    label: 'LFM2.5 230M (balanced)',
    params: '~0.23B',
    approxSizeMB: 250,
    license: 'Vendor license — verify before install (not Apache-2.0)',
    source: 'Official LiquidAI LFM2.5 230M .litertlm release artifacts',
    notes: 'Good quality with lower storage and RAM needs.',
  ),
  ModelRecommendation(
    id: 'smollm2-135m',
    label: 'SmolLM2 135M (lightest)',
    params: '~0.135B',
    approxSizeMB: 150,
    license: 'Verify against the official SmolLM2 distribution before install',
    source: 'Official SmolLM2 135M .litertlm release artifacts',
    notes: 'Fastest on low-end phones; best for short pet replies.',
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
