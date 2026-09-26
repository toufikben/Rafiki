import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ai/local_model_manager.dart';
import '../../core/utils/diag_log.dart';
import '../../core/utils/error_log.dart';

/// CI build identifier, same source as Settings > Version.
const _buildTag = String.fromEnvironment('RAFIQ_BUILD_TAG', defaultValue: 'dev');

/// On-device diagnostics: shows the recorded framework error (if any),
/// a breadcrumb timeline of suspicious spots, and model/storage state,
/// with one-tap copy so the report can be pasted straight to the developer.
///
/// Reach it from Settings > Diagnostics. The error file survives red
/// screens (only uninstall wipes it), so reproduce a crash, relaunch,
/// open this screen, copy, paste.
class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final LocalModelManager _modelManager = LocalModelManager();
  String? _errorReport;
  String _modelSummary = 'Loading…';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final error = await readLastFrameworkError();
    var modelSummary = 'Active model: ${_modelManager.activeModelName ?? 'none'}';
    try {
      final installed = await _modelManager.listInstalled();
      final storage = await _modelManager.storageInfo();
      modelSummary =
          'Active model: ${_modelManager.activeModelName ?? 'none'}\n'
          'Installed: ${installed.isEmpty ? 'none' : installed.join(', ')}\n'
          'Storage: ${storage.totalSizeMB.toStringAsFixed(1)} MB in ${storage.totalFiles} file(s)';
    } catch (_) {
      modelSummary += '\nInstalled/storage: unavailable';
    }
    if (!mounted) return;
    setState(() {
      _errorReport = error;
      _modelSummary = modelSummary;
      _loading = false;
    });
  }

  String _buildReport() {
    final buffer = StringBuffer()
      ..writeln('Rafiq diagnostics — 1.0.0 ($_buildTag)')
      ..writeln('Captured: ${DateTime.now().toIso8601String()}')
      ..writeln()
      ..writeln('--- model ---')
      ..writeln(_modelSummary)
      ..writeln()
      ..writeln('--- events (oldest first) ---');
    final events = DiagLog.snapshot();
    if (events.isEmpty) {
      buffer.writeln('(no events recorded this session)');
    } else {
      for (final event in events) {
        buffer.writeln('[${event.time.toIso8601String()}] ${event.message}');
      }
    }
    buffer
      ..writeln()
      ..writeln('--- last framework error ---')
      ..writeln(_errorReport ?? '(none recorded)');
    return buffer.toString();
  }

  Future<void> _copyReport() async {
    final report = _buildReport();
    await Clipboard.setData(ClipboardData(text: report));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diagnostics report copied — paste it to the developer.'),
      ),
    );
  }

  Future<void> _clearAll() async {
    await clearLastFrameworkError();
    DiagLog.clear();
    if (!mounted) return;
    setState(() {
      _errorReport = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics cleared.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = DiagLog.snapshot();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Copy report',
            icon: const Icon(Icons.copy),
            onPressed: _loading ? null : _copyReport,
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: _loading ? null : _clearAll,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Copy this report after reproducing a bug and paste it to the developer.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('Build',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText('Version 1.0.0 ($_buildTag)'),
                const SizedBox(height: 12),
                const Text('Model',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(_modelSummary),
                const SizedBox(height: 12),
                Text('Events (${events.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (events.isEmpty)
                  const SelectableText('(no events recorded this session)')
                else
                  SelectableText(
                    events
                        .map((e) =>
                            '[${e.time.toIso8601String()}] ${e.message}')
                        .join('\n'),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                const SizedBox(height: 12),
                const Text('Last framework error',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SelectableText(
                  _errorReport ?? '(none recorded)',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _copyReport,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy full report'),
                ),
              ],
            ),
    );
  }
}
