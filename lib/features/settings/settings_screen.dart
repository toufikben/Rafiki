import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
