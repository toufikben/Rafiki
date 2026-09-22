import 'dart:io';

class ModelPreflightResult {
  const ModelPreflightResult({
    required this.valid,
    required this.source,
    this.sizeBytes,
    this.warning,
    this.reason,
  });

  final bool valid;
  final String source;
  final int? sizeBytes;
  final String? warning;
  final String? reason;

  void throwIfInvalid() {
    if (!valid) {
      throw FormatException(reason ?? 'Model preflight failed', source);
    }
  }
}

/// Validates model sources before any bytes are handed to flutter_gemma.
/// Network preflight uses HEAD only; it never downloads model content.
class ModelInstallPreflight {
  static const int minimumModelBytes = 1024 * 1024;

  static Future<ModelPreflightResult> localFile(
    String path, {
    int minimumBytes = minimumModelBytes,
  }) async {
    final file = File(path);
    if (!path.toLowerCase().endsWith('.litertlm')) {
      return ModelPreflightResult(
        valid: false,
        source: path,
        reason: 'The selected file must use the .litertlm extension.',
      );
    }
    if (!await file.exists()) {
      return ModelPreflightResult(
        valid: false,
        source: path,
        reason: 'The selected model file does not exist.',
      );
    }
    final size = await file.length();
    if (size < minimumBytes) {
      return ModelPreflightResult(
        valid: false,
        source: path,
        sizeBytes: size,
        reason: 'The model file is too small to be a valid LiteRT-LM model.',
      );
    }
    return ModelPreflightResult(valid: true, source: path, sizeBytes: size);
  }

  static Future<ModelPreflightResult> networkUrl(
    String value, {
    int minimumBytes = minimumModelBytes,
  }) async {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        !uri.path.toLowerCase().endsWith('.litertlm')) {
      return ModelPreflightResult(
        valid: false,
        source: value,
        reason: 'Use an HTTP(S) URL that points to a .litertlm file.',
      );
    }

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.headUrl(uri).timeout(const Duration(seconds: 10));
      request.followRedirects = true;
      request.maxRedirects = 5;
      final response = await request.close().timeout(const Duration(seconds: 10));
      final size = response.contentLength > 0 ? response.contentLength : null;
      if (response.statusCode >= 400 && response.statusCode != 405) {
        return ModelPreflightResult(
          valid: false,
          source: value,
          sizeBytes: size,
          reason: 'The model URL returned HTTP ${response.statusCode}.',
        );
      }
      if (size != null && size < minimumBytes) {
        return ModelPreflightResult(
          valid: false,
          source: value,
          sizeBytes: size,
          reason: 'The remote model is smaller than the minimum safe size.',
        );
      }
      return ModelPreflightResult(
        valid: true,
        source: value,
        sizeBytes: size,
        warning: size == null
            ? 'The server did not expose Content-Length; storage cannot be estimated before download.'
            : null,
      );
    } on SocketException catch (error) {
      return ModelPreflightResult(
        valid: false,
        source: value,
        reason: 'Could not reach the model URL: $error',
      );
    } finally {
      client.close(force: true);
    }
  }
}
