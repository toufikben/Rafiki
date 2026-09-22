import 'package:flutter/material.dart';

import '../../core/models/pet_state.dart';
import '../../render/dog_scene_view.dart';

class PetStatusHud extends StatelessWidget {
  const PetStatusHud({
    super.key,
    required this.pet,
    required this.animationClip,
    required this.sceneStatus,
  });

  final PetState pet;
  final String animationClip;
  final DogSceneStatus sceneStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.black.withValues(alpha: 0.68),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _StatusChip(
              icon: _moodIcon(pet.mood),
              label: 'Mood: ${_titleCase(pet.mood)}',
              color: _moodColor(pet.mood),
            ),
            _StatusChip(
              icon: Icons.directions_run,
              label: 'Motion: ${_titleCase(animationClip)}',
              color: Colors.lightBlueAccent,
            ),
            _StatusChip(
              icon: _sceneIcon(sceneStatus),
              label: '3D: ${_sceneLabel(sceneStatus)}',
              color: _sceneColor(sceneStatus),
            ),
          ],
        ),
      ),
    );
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return 'Unknown';
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  static IconData _moodIcon(String mood) => switch (mood.toLowerCase()) {
        'happy' || 'joyful' || 'excited' => Icons.sentiment_very_satisfied,
        'sad' || 'stressed' => Icons.sentiment_dissatisfied,
        'sleepy' || 'tired' => Icons.bedtime,
        _ => Icons.sentiment_neutral,
      };

  static Color _moodColor(String mood) => switch (mood.toLowerCase()) {
        'happy' || 'joyful' || 'excited' => Colors.amberAccent,
        'sad' || 'stressed' => Colors.blueAccent,
        'sleepy' || 'tired' => Colors.deepPurpleAccent,
        _ => Colors.white70,
      };

  static IconData _sceneIcon(DogSceneStatus status) => switch (status) {
        DogSceneStatus.loading => Icons.hourglass_top,
        DogSceneStatus.ready => Icons.view_in_ar,
        DogSceneStatus.error => Icons.warning_amber,
        DogSceneStatus.notApplicable => Icons.auto_awesome,
      };

  static Color _sceneColor(DogSceneStatus status) => switch (status) {
        DogSceneStatus.loading => Colors.orangeAccent,
        DogSceneStatus.ready => Colors.greenAccent,
        DogSceneStatus.error => Colors.redAccent,
        DogSceneStatus.notApplicable => Colors.white70,
      };

  static String _sceneLabel(DogSceneStatus status) => switch (status) {
        DogSceneStatus.loading => 'Loading',
        DogSceneStatus.ready => 'Prototype ready',
        DogSceneStatus.error => 'Fallback active',
        DogSceneStatus.notApplicable => '2D renderer',
      };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.48)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}
