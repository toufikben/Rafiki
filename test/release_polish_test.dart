import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/ai/recommended_models.dart';
import 'package:rafiq/render/dog_animation_controller.dart';

void main() {
  group('Recommended local models', () {
    test('catalog offers named options with a best-quality default', () {
      expect(recommendedModels, isNotEmpty);
      final ids = recommendedModels.map((model) => model.id).toSet();
      expect(ids.length, recommendedModels.length);
      for (final model in recommendedModels) {
        expect(model.label.trim(), isNotEmpty);
        expect(model.license.trim(), isNotEmpty);
        expect(model.source.trim(), isNotEmpty);
        expect(model.approxSizeMB, greaterThan(0));
      }
      // The default must resolve to a catalog entry ...
      expect(ids, contains(defaultRecommendedModelId));
      expect(defaultRecommendedModel.id, defaultRecommendedModelId);
      // ... and the default must be the best-quality (largest) option,
      // not the smallest: chat quality is the deciding factor.
      for (final model in recommendedModels) {
        expect(
          defaultRecommendedModel.approxSizeMB,
          greaterThanOrEqualTo(model.approxSizeMB),
        );
      }
      expect(modelStorageGuidance(), contains('Wi-Fi'));
    });
  });

  group('Dog clip name tolerance', () {
    test('normalizes exporter case differences to contract names', () {
      expect(normalizeDogClipName('idle'), 'Idle');
      expect(normalizeDogClipName('  WALK '), 'Walk');
      expect(normalizeDogClipName('Sleep'), 'Sleep');
      expect(normalizeDogClipName('unknownClip'), 'unknownClip');
    });

    test('resolves against available GLB clips case-insensitively', () {
      const available = <String>['idle', 'walk', 'Run'];
      expect(resolveDogClipName(available, 'Idle'), 'idle');
      expect(resolveDogClipName(available, 'WALK'), 'walk');
      expect(resolveDogClipName(available, 'run'), 'Run');
      expect(resolveDogClipName(available, 'Play'), isNull);
      expect(resolveDogClipName(available, '  '), isNull);
    });

    test('prefers exact matches when several casings exist', () {
      const available = <String>['idle', 'Idle'];
      expect(resolveDogClipName(available, 'Idle'), 'Idle');
    });
  });
}
