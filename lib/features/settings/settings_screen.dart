import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai/local_model_manager.dart';
import '../../ai/model_install_preflight.dart';
import '../../ai/recommended_models.dart';
import '../../data/database.dart';
import '../../services/audio_service.dart';
import '../../services/floating_service.dart';
import 'legal_information_screen.dart';

/// CI build identifier shown in Settings > Version. Injected with
/// `--dart-define=RAFIQ_BUILD_TAG=<short-sha>` by the debug workflow so a
/// screenshot proves exactly which commit is installed on a device.
const _buildTag = String.fromEnvironment('RAFIQ_BUILD_TAG', defaultValue: 'dev');

String _formatBytes(int bytes) {
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

class _DownloadDetail extends StatelessWidget {
  const _DownloadDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _soundEnabled = true;
  bool _floatingEnabled = false;
  final LocalModelManager _modelManager = LocalModelManager();

  @override
  void initState() {
    super.initState();
    _loadFloatingStatus();
  }

  Future<void> _loadFloatingStatus() async {
    if (!Platform.isAndroid) return;
    final active = await FloatingService.isActive();
    if (mounted) setState(() => _floatingEnabled = active);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Play pet sounds on interaction'),
            value: _soundEnabled,
            onChanged: (v) {
              setState(() => _soundEnabled = v);
              AudioService.setEnabled(v);
            },
          ),
          if (Platform.isAndroid)
            SwitchListTile(
              title: const Text('Floating Pet'),
              subtitle: const Text('Show your pet on top of other apps'),
              value: _floatingEnabled,
              onChanged: _toggleFloating,
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('Local AI model'),
            subtitle: const Text(
              'Install a selected .litertlm model; nothing downloads automatically',
            ),
            onTap: _showModelManager,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Delete All Data'),
            subtitle: const Text('This cannot be undone'),
            onTap: () => _confirmDelete(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('All data stays on your device'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LegalInformationScreen(),
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            // Build tag identifies the exact CI commit on-device so a
            // screenshot proves which build is installed. Injected via
            // --dart-define=RAFIQ_BUILD_TAG in CI; 'dev' for local builds.
            subtitle: Text('1.0.0 ($_buildTag)'),
          ),
        ],
      ),
    );
  }

  Future<void> _showModelManager() async {
    final pathController = TextEditingController();
    final urlController = TextEditingController();
    var installed = <String>[];
    PlatformFile? selectedFile;
    StorageStats? storage;
    Future<void> Function()? retryAction;
    try {
      installed = await _modelManager.listInstalled();
    } catch (_) {}
    try {
      storage = await _modelManager.storageInfo();
    } catch (_) {}
    if (!mounted) {
      pathController.dispose();
      urlController.dispose();
      return;
    }
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          var busy = false;
          var progress = 0;
          String? error;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> refresh() async {
                try {
                  final models = await _modelManager.listInstalled();
                  final info = await _modelManager.storageInfo();
                  if (context.mounted) {
                    setDialogState(() {
                      installed = models;
                      storage = info;
                    });
                  }
                } catch (e) {
                  if (context.mounted) setDialogState(() => error = '$e');
                }
              }

              Future<void> install(Future<void> Function() action) async {
                retryAction = action;
                setDialogState(() {
                  busy = true;
                  progress = 0;
                  error = null;
                });
                try {
                  await action();
                  await refresh();
                } catch (e) {
                  if (context.mounted) setDialogState(() => error = '$e');
                } finally {
                  if (context.mounted) setDialogState(() => busy = false);
                }
              }

              /// Preflight + confirmation + install for any model URL: the
              /// custom URL field and the verified one-tap catalog buttons
              /// share this flow so the Wi-Fi/size warning and cancel path
              /// cannot drift apart.
              Future<void> runUrlInstall(
                String url, {
                ModelType modelType = ModelType.general,
              }) async {
                setDialogState(() => error = null);
                final preflight =
                    await ModelInstallPreflight.networkUrl(url);
                if (!context.mounted) return;
                if (!preflight.valid) {
                  setDialogState(
                    () => error = preflight.reason,
                  );
                  return;
                }
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (confirmationContext) {
                    final size = preflight.sizeBytes == null
                        ? 'Unknown (server did not provide Content-Length)'
                        : _formatBytes(preflight.sizeBytes!);
                    final fileName =
                        Uri.parse(url).pathSegments.last;
                    return AlertDialog(
                      title: const Text('Confirm model download'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.download_for_offline_outlined,
                              size: 42,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              fileName.isEmpty
                                  ? 'LiteRT-LM model'
                                  : fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _DownloadDetail(
                              icon: Icons.data_usage,
                              label: 'Estimated download size',
                              value: size,
                            ),
                            _DownloadDetail(
                              icon: Icons.storage_outlined,
                              label: 'Model storage currently used',
                              value: storage == null
                                  ? 'Unavailable'
                                  : '${storage!.totalSizeMB.toStringAsFixed(1)} MB in ${storage!.totalFiles} file(s)',
                            ),
                            _DownloadDetail(
                              icon: Icons.smart_toy_outlined,
                              label: 'Active model',
                              value: _modelManager.activeModelName ?? 'None',
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'This action downloads model data to this device. Wi-Fi is recommended; mobile data and additional storage may be used.',
                            ),
                            if (preflight.warning != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                preflight.warning!,
                                style: const TextStyle(
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            FocusScope.of(confirmationContext).unfocus();
                            await Future<void>.delayed(
                              const Duration(milliseconds: 300),
                            );
                            if (confirmationContext.mounted) {
                              Navigator.pop(confirmationContext, false);
                            }
                          },
                          child: const Text('Cancel'),
                        ),
                        FilledButton.icon(
                          onPressed: () async {
                            FocusScope.of(confirmationContext).unfocus();
                            await Future<void>.delayed(
                              const Duration(milliseconds: 300),
                            );
                            if (confirmationContext.mounted) {
                              Navigator.pop(confirmationContext, true);
                            }
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed == true && context.mounted) {
                  await install(
                    () => _modelManager.installFromNetwork(
                      url: url,
                      modelType: modelType,
                      onProgress: (value) => setDialogState(
                        () => progress = value,
                      ),
                    ),
                  );
                }
              }

              return AlertDialog(
                title: const Text('Local AI model'),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Models stay on this device. Choose an explicit local file or URL to install.',
                        ),
                        if (storage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Storage: ${storage!.totalSizeMB.toStringAsFixed(1)} MB in ${storage!.totalFiles} file(s)',
                          ),
                        ],
                        Text(
                          'Active model: ${_modelManager.activeModelName ?? 'none'}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Recommended default (best quality): ${defaultRecommendedModel.label} '
                          '(~${defaultRecommendedModel.approxSizeMB} MB). '
                          'No model is bundled or downloaded automatically; verify the license of any file you install.',
                        ),
                        const SizedBox(height: 4),
                        for (final model in recommendedModels)
                          Text(
                            '• ${model.label} — ~${model.approxSizeMB} MB. ${model.notes}',
                          ),
                        const SizedBox(height: 4),
                        Text(modelStorageGuidance()),
                        const SizedBox(height: 12),
                        const Text(
                          'One-tap verified downloads (same confirmation and Wi-Fi warning apply):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        for (final model in recommendedModels)
                          if (model.installUrl != null)
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                '${model.label} (~${model.approxSizeMB} MB)',
                              ),
                              subtitle: Text(model.license),
                              trailing: TextButton(
                                onPressed: busy
                                    ? null
                                    : () async {
                                        FocusScope.of(context).unfocus();
                                        await runUrlInstall(
                                          model.installUrl!,
                                          modelType: model.modelType,
                                        );
                                      },
                                child: const Text('Download'),
                              ),
                            )
                          else
                            Text(
                              '${model.label}: ${model.notes}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: busy
                              ? null
                              : () async {
                                  // Close the keyboard before opening system
                                  // UI so focus teardown cannot race the
                                  // dialog route.
                                  FocusScope.of(context).unfocus();
                                  final files = await FilePicker.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: const ['litertlm'],
                                  );
                                  final file = files.isEmpty ? null : files.single;
                                  if (file?.path != null && context.mounted) {
                                    setDialogState(() {
                                      selectedFile = file;
                                      pathController.text = file!.path!;
                                    });
                                  }
                                },
                          icon: const Icon(Icons.folder_open),
                          label: Text(
                            selectedFile == null
                                ? 'Choose local .litertlm file'
                                : selectedFile!.name,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: busy || pathController.text.trim().isEmpty
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  install(
                                    () => _modelManager.installFromFile(
                                      path: pathController.text.trim(),
                                      onProgress: (value) => setDialogState(
                                        () => progress = value,
                                      ),
                                    ),
                                  );
                                },
                          child: const Text('Install local file'),
                        ),
                        TextField(
                          controller: urlController,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Model URL',
                          ),
                          keyboardType: TextInputType.url,
                        ),
                        ElevatedButton(
                          onPressed: busy || urlController.text.trim().isEmpty
                              ? null
                              : () async {
                                  // Dismiss the keyboard before the async
                                  // preflight + nested confirmation dialog so
                                  // no focused field survives a route pop.
                                  // Custom URLs install as general type; the
                                  // verified catalog entries below pass their
                                  // own family type.
                                  FocusScope.of(context).unfocus();
                                  await runUrlInstall(
                                      urlController.text.trim());
                                },
                          child: const Text('Download and install'),
                        ),
                        if (urlController.text.trim().isNotEmpty)
                          const Text(
                            'Large models may use significant storage and mobile data. Wi-Fi is recommended.',
                          ),
                        if (busy) ...[
                          LinearProgressIndicator(value: progress / 100),
                          Text('Progress: $progress%'),
                          TextButton(
                            onPressed: _modelManager.cancelInstall,
                            child: const Text('Cancel installation'),
                          ),
                        ],
                        if (error != null)
                          ...[
                            Text(error!, style: const TextStyle(color: Colors.red)),
                            if (retryAction != null)
                              TextButton(
                                onPressed: busy ? null : () => install(retryAction!),
                                child: const Text('Retry'),
                              ),
                          ],
                        const SizedBox(height: 8),
                        const Text('Installed models'),
                        if (installed.isEmpty)
                          const Text('No local model installed.'),
                        for (final model in installed)
                          ListTile(
                            dense: true,
                            title: Text(model),
                            trailing: IconButton(
                              tooltip: 'Delete model',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: busy
                                  ? null
                                  : () async {
                                      await _modelManager.uninstall(model);
                                      await refresh();
                                    },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      // Dismiss the keyboard AND let focus/keyboard teardown
                      // settle before popping: unfocus alone is async (the
                      // platform keyboard + MediaQuery insets animate out
                      // over frames), and tearing down this route with a
                      // still-registered dependent trips
                      // InheritedElement.debugDeactivated (_dependents not
                      // empty) and red-screens the app. Verified on-device:
                      // unfocus-without-settle still crashed.
                      FocusScope.of(dialogContext).unfocus();
                      await Future<void>.delayed(
                        const Duration(milliseconds: 300),
                      );
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      pathController.dispose();
      urlController.dispose();
    }
  }

  Future<void> _toggleFloating(bool value) async {
    if (value) {
      final granted = await FloatingService.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission required to show floating pet'),
            ),
          );
        }
        return;
      }
      await FloatingService.showPet();
      setState(() => _floatingEnabled = true);
    } else {
      await FloatingService.hidePet();
      setState(() => _floatingEnabled = false);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text('This removes the local pet and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await Database.deleteAll();
  }
}
