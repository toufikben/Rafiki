import 'package:flutter/material.dart';

class ManualTestControls extends StatelessWidget {
  const ManualTestControls({
    super.key,
    required this.enabled,
    required this.selectedMood,
    required this.selectedClip,
    required this.onToggle,
    required this.onMoodSelected,
    required this.onClipSelected,
    required this.onReset,
  });

  final bool enabled;
  final String selectedMood;
  final String selectedClip;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onMoodSelected;
  final ValueChanged<String> onClipSelected;
  final VoidCallback onReset;

  static const moods = <String>['neutral', 'happy', 'sad', 'sleepy', 'stressed'];
  static const clips = <String>[
    'Idle',
    'Walk',
    'Run',
    'Play',
    'Sleep',
    'Eat',
    'Drink',
    'Happy',
    'Sad',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Manual test controls',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Semantics(
                  label: 'Enable manual test controls',
                  toggled: enabled,
                  child: Switch(value: enabled, onChanged: onToggle),
                ),
              ],
            ),
            const Text(
              'Override the automatic behavior loop for quick visual and animation checks. Reset to return to normal behavior.',
            ),
            const SizedBox(height: 18),
            const Text(
              'Mood',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moods
                  .map(
                    (mood) => ChoiceChip(
                      label: Text(_titleCase(mood)),
                      selected: selectedMood == mood,
                      onSelected: enabled ? (_) => onMoodSelected(mood) : null,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            const Text(
              'Movement / clip',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: clips
                  .map(
                    (clip) => ChoiceChip(
                      label: Text(clip),
                      selected: selectedClip == clip,
                      onSelected: enabled ? (_) => onClipSelected(clip) : null,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset automatic behavior'),
            ),
          ],
        ),
      ),
    );
  }

  static String _titleCase(String value) =>
      value[0].toUpperCase() + value.substring(1).toLowerCase();
}
