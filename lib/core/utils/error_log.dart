import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// File backing for the on-device diagnostics screen.
///
/// Some teardown races only reproduce on real devices, where logcat rotates
/// before any trace can be pulled. The latest framework error (with its
/// widget descriptions and stack) is kept at `last_framework_error.txt` in
/// the app documents directory. The Diagnostics screen reads it, shows it,
/// and offers one-tap copy; it can also be read over adb from a debug
/// build: `adb shell "run-as com.rafiq.app cat
/// app_flutter/last_framework_error.txt"`.
Future<File> _errorFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/last_framework_error.txt');
}

/// Best-effort framework-error recorder for `FlutterError.onError`.
/// Recording must never break the error path itself.
Future<void> recordFrameworkError(FlutterErrorDetails details) async {
  try {
    final buffer = StringBuffer()
      ..writeln(DateTime.now().toIso8601String())
      ..writeln(details.exceptionAsString());
    // Widget descriptions turn a bare framework assert into an
    // actionable fix; the stack alone rarely names the culprit.
    final info = details.informationCollector?.call();
    if (info != null) {
      for (final line in info) {
        buffer.writeln(line);
      }
    }
    buffer.writeln(details.stack ?? '');
    final file = await _errorFile();
    await file.writeAsString(buffer.toString());
  } catch (_) {
    // Recording must never break the error path itself.
  }
}

/// Returns the recorded error report, or null when none was recorded yet.
Future<String?> readLastFrameworkError() async {
  try {
    final file = await _errorFile();
    if (!await file.exists()) return null;
    return await file.readAsString();
  } catch (_) {
    return null;
  }
}

/// Deletes the recorded error report, if any.
Future<void> clearLastFrameworkError() async {
  try {
    final file = await _errorFile();
    if (await file.exists()) await file.delete();
  } catch (_) {}
}
