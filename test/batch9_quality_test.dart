import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/ai/chat_language.dart';
import 'package:rafiq/ai/model_install_preflight.dart';

void main() {
  group('ChatLanguageDetector', () {
    test('detects Arabic and English scripts', () {
      expect(ChatLanguageDetector.detect('مرحبا كيف حالك'), ChatLanguage.arabic);
      expect(ChatLanguageDetector.detect('hello how are you'), ChatLanguage.english);
    });

    test('uses unknown for empty or balanced input', () {
      expect(ChatLanguageDetector.detect(''), ChatLanguage.unknown);
      expect(ChatLanguageDetector.detect('123 !!!'), ChatLanguage.unknown);
    });
  });

  group('ModelInstallPreflight', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('rafiq_preflight_');
    });

    tearDown(() async {
      if (await directory.exists()) await directory.delete(recursive: true);
    });

    test('rejects missing, wrong-extension, and undersized files', () async {
      final missing = await ModelInstallPreflight.localFile(
        '${directory.path}/missing.litertlm',
      );
      expect(missing.valid, isFalse);

      final wrong = File('${directory.path}/model.bin')
        ..writeAsBytesSync(List<int>.filled(32, 1));
      expect(
        (await ModelInstallPreflight.localFile(wrong.path)).valid,
        isFalse,
      );

      final small = File('${directory.path}/small.litertlm')
        ..writeAsBytesSync(List<int>.filled(32, 1));
      expect(
        (await ModelInstallPreflight.localFile(small.path)).valid,
        isFalse,
      );
    });

    test('accepts a sufficiently sized litertlm file', () async {
      final model = File('${directory.path}/pet.litertlm')
        ..writeAsBytesSync(List<int>.filled(1024, 1));
      final result = await ModelInstallPreflight.localFile(
        model.path,
        minimumBytes: 1024,
      );
      expect(result.valid, isTrue);
      expect(result.sizeBytes, 1024);
    });

    test('rejects invalid network URLs before any request', () async {
      final result = await ModelInstallPreflight.networkUrl(
        'file:///tmp/model.bin',
      );
      expect(result.valid, isFalse);
      expect(result.reason, contains('.litertlm'));
    });

    test('accepts HTTP(S) model URLs with query parameters', () async {
      expect(
        ModelInstallPreflight.isAllowedNetworkUrl(
          'https://models.example.test/pet.litertlm?download=1',
        ),
        isTrue,
      );
    });

    test('rejects non-HTTP(S) and non-litertlm URI shapes', () async {
      expect(
        ModelInstallPreflight.isAllowedNetworkUrl(
          'https://models.example.test/pet.bin',
        ),
        isFalse,
      );
      expect(
        ModelInstallPreflight.isAllowedNetworkUrl(
          'ftp://models.example.test/pet.litertlm',
        ),
        isFalse,
      );
    });

    test('rejects plain-HTTP model URLs before any request', () async {
      expect(
        ModelInstallPreflight.isAllowedNetworkUrl(
          'http://models.example.test/pet.litertlm',
        ),
        isFalse,
      );
      final result = await ModelInstallPreflight.networkUrl(
        'http://models.example.test/pet.litertlm',
      );
      expect(result.valid, isFalse);
      expect(result.reason, contains('HTTPS'));
    });
  });
}
