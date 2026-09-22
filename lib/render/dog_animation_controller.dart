import '../core/models/behavior_type.dart';
import '../core/models/pet_state.dart';

/// Selects the authored base animation without touching scene nodes.
///
/// The renderer can consume [AnimationSelection] while the behavior engine
/// remains responsible for deciding intent. Short actions keep the previous
/// locomotion clip as their return target instead of always falling back to
/// Idle.
class DogAnimationController {
  DogAnimationController({this.transition = const Duration(milliseconds: 220)});

  final Duration transition;
  String _currentClip = 'Idle';
  String _resumeClip = 'Idle';

  String get currentClip => _currentClip;
  String get resumeClip => _resumeClip;

  AnimationSelection select({
    required PetState pet,
    required BehaviorType behavior,
    bool interactionActive = false,
  }) {
    final next = clipFor(
      pet: pet,
      behavior: behavior,
      interactionActive: interactionActive,
    );
    final isShortAction = const <String>{'Happy', 'Sad', 'Eat', 'Drink'}
        .contains(next);
    if (!isShortAction && next != 'Sleep') {
      _resumeClip = next;
    }
    final previous = _currentClip;
    _currentClip = next;
    return AnimationSelection(
      clip: next,
      previousClip: previous == next ? null : previous,
      transition: transitionFor(next, previous),
      loop: isLooping(next),
      resumeClip: isShortAction ? _resumeClip : null,
    );
  }

  static String clipFor({
    required PetState pet,
    required BehaviorType behavior,
    bool interactionActive = false,
  }) {
    if (pet.energy < 0.15 || behavior == BehaviorType.sleeping) return 'Sleep';
    if (pet.happiness < 0.2 || pet.stress > 0.82) return 'Sad';
    if (interactionActive && behavior == BehaviorType.playing) return 'Play';
    switch (behavior) {
      case BehaviorType.running:
        return 'Run';
      case BehaviorType.walking:
      case BehaviorType.followingCursor:
        return 'Walk';
      case BehaviorType.eating:
      case BehaviorType.begging:
        return 'Eat';
      case BehaviorType.playing:
        return 'Play';
      case BehaviorType.celebrating:
        return 'Happy';
      case BehaviorType.hiding:
        return 'Sad';
      case BehaviorType.idle:
      case BehaviorType.sleeping:
        return 'Idle';
    }
  }

  static bool isLooping(String clip) =>
      const <String>{'Idle', 'Walk', 'Run', 'Sleep', 'Eat', 'Drink'}.contains(clip);

  static Duration transitionFor(String next, String previous) {
    if (next == previous) return Duration.zero;
    if (next == 'Sleep' || previous == 'Sleep') {
      return const Duration(milliseconds: 300);
    }
    if (const <String>{'Eat', 'Drink'}.contains(next)) {
      return const Duration(milliseconds: 160);
    }
    return const Duration(milliseconds: 220);
  }
}

class AnimationSelection {
  const AnimationSelection({
    required this.clip,
    required this.previousClip,
    required this.transition,
    required this.loop,
    required this.resumeClip,
  });

  final String clip;
  final String? previousClip;
  final Duration transition;
  final bool loop;
  final String? resumeClip;
}

/// The authored contract required by Batch 8. This list is intentionally
/// separate from the prototype asset's currently available GLB animations.
const requiredDogAnimationClips = <String>[
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

const requiredDogJoints = <String>[
  'Chest',
  'Ear_L',
  'Ear_R',
  'Tail_01',
  'Tail_02',
  'Tail_03',
];

List<String> missingDogContractEntries(
  Map<String, dynamic> manifest, {
  List<String> requiredClips = requiredDogAnimationClips,
  List<String> requiredJoints = requiredDogJoints,
}) {
  final clips = (manifest['animation_clips'] as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map((clip) => clip['name'])
      .whereType<String>()
      .toSet();
  final joints = (manifest['skeleton'] as List<dynamic>? ?? const [])
      .whereType<String>()
      .toSet();
  return <String>[
    ...requiredClips.where((clip) => !clips.contains(clip)).map((x) => 'clip:$x'),
    ...requiredJoints.where((joint) => !joints.contains(joint)).map((x) => 'joint:$x'),
  ];
}
