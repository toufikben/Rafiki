import 'package:flutter_gemma/flutter_gemma.dart';

import 'model_install_preflight.dart';

/// App-facing model management boundary for Batch 9.
///
/// No method downloads anything implicitly. Installation only happens after an
/// explicit call from the settings UI, and every install can be cancelled.
class LocalModelManager {
  CancelToken? _cancelToken;

  Future<List<String>> listInstalled() => FlutterGemma.listInstalledModels();

  Future<StorageStats> storageInfo() => FlutterGemma.getStorageInfo();

  String? get activeModelName => FlutterGemma.activeModelSpec?.name;

  String? get activeModelFileName {
    final files = FlutterGemma.activeModelSpec?.files;
    return files == null || files.isEmpty ? null : files.first.filename;
  }

  Future<void> installFromFile({
    required String path,
    void Function(int progress)? onProgress,
  }) async {
    final preflight = await ModelInstallPreflight.localFile(path);
    preflight.throwIfInvalid();
    await _install(
      FlutterGemma.installModel(
        modelType: ModelType.general,
        fileType: ModelFileType.litertlm,
      ).fromFile(path),
      onProgress: onProgress,
    );
  }

  Future<void> installFromNetwork({
    required String url,
    String? token,
    void Function(int progress)? onProgress,
  }) async {
    final preflight = await ModelInstallPreflight.networkUrl(url);
    preflight.throwIfInvalid();
    await _install(
      FlutterGemma.installModel(
        modelType: ModelType.general,
        fileType: ModelFileType.litertlm,
      ).fromNetwork(url, token: token),
      onProgress: onProgress,
    );
  }

  void cancelInstall([String reason = 'Cancelled by user']) {
    _cancelToken?.cancel(reason);
  }

  Future<void> uninstall(String modelId) => FlutterGemma.uninstallModel(modelId);

  Future<void> cleanupOrphans() => FlutterGemma.cleanupStorage();

  Future<void> _install(
    InferenceInstallationBuilder builder, {
    void Function(int progress)? onProgress,
  }) async {
    final token = CancelToken();
    _cancelToken = token;
    try {
      await builder
          .withCancelToken(token)
          .withProgress(onProgress ?? (_) {})
          .install();
    } finally {
      if (identical(_cancelToken, token)) _cancelToken = null;
    }
  }
}
