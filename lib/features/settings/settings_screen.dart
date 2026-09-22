import 'dart:io' show Platform;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai/local_model_manager.dart';
import '../../data/database.dart';
import '../../providers/pet_provider.dart';
import '../../services/audio_service.dart';
import '../../services/floating_service.dart';

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
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            subtitle: Text('All data stays on your device'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
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
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: busy
                              ? null
                              : () async {
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
                              : () => install(
                                    () => _modelManager.installFromFile(
                                      path: pathController.text.trim(),
                                      onProgress: (value) => setDialogState(
                                        () => progress = value,
                                      ),
                                    ),
                            ),
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
                              : () => install(
                                    () => _modelManager.installFromNetwork(
                                      url: urlController.text.trim(),
                                      onProgress: (value) => setDialogState(
                                        () => progress = value,
                                      ),
                                    ),
                                  ),
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
                    onPressed: () => Navigator.pop(dialogContext),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'Your pet and all memories will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await Database.deleteAll();
      if (!context.mounted) return;
      Navigator.pop(context);
      ref.invalidate(petProvider);
    }
  }
}
