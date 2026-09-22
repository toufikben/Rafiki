import 'package:flutter_scene/scene.dart';

/// Binds authored GLB animations when they exist and remains a no-op for the
/// current static prototype asset. The scene can therefore adopt a rigged GLB
/// without replacing the fallback path or changing the secondary-motion layer.
class DogAnimationRuntime extends Component {
  DogAnimationRuntime({this.crossfade = const Duration(milliseconds: 220)});

  final Duration crossfade;
  final Map<String, AnimationClip> _clips = <String, AnimationClip>{};
  AnimationClip? _active;
  AnimationClip? _incoming;
  double _blendElapsed = 0;

  String? get activeClip => _active == null ? null : _clipName(_active!);
  bool get hasAuthoredClips => _clips.isNotEmpty;

  @override
  void onAttach() {
    for (final animation in node.parsedAnimations) {
      final clip = node.createAnimationClip(animation)
        ..loop = _isLooping(animation.name);
        
      _clips[animation.name] = clip;
    }
    if (_clips.containsKey('Idle')) select('Idle');
  }

  /// Selects an authored clip by name. Missing clips are ignored so the
  /// prototype GLB continues to render while the final rig is in production.
  void select(String name, {bool? loop}) {
    final next = _clips[name];
    if (next == null || identical(next, _active)) return;
    next.loop = loop ?? _isLooping(name);
    next.replay();
    next.weight = 0;
    _incoming = next;
    _blendElapsed = 0;
    if (_active == null || crossfade == Duration.zero) {
      _active?.stop();
      next.weight = 1;
      _active = next;
      _incoming = null;
    }
  }

  @override
  void update(double deltaSeconds) {
    final incoming = _incoming;
    final active = _active;
    if (incoming == null) return;
    if (active == null) {
      incoming.weight = 1;
      _active = incoming;
      _incoming = null;
      return;
    }
    _blendElapsed += deltaSeconds.clamp(0.0, 0.1);
    final duration = crossfade.inMicroseconds / Duration.microsecondsPerSecond;
    final progress = duration <= 0 ? 1.0 : (_blendElapsed / duration).clamp(0.0, 1.0);
    active.weight = 1.0 - progress;
    incoming.weight = progress;
    if (progress >= 1.0) {
      active.stop();
      active.weight = 0;
      incoming.weight = 1;
      _active = incoming;
      _incoming = null;
    }
  }

  @override
  void onDetach() {
    for (final clip in _clips.values) {
      clip.stop();
    }
    _clips.clear();
    _active = null;
    _incoming = null;
  }

  String _clipName(AnimationClip clip) {
    for (final entry in _clips.entries) {
      if (identical(entry.value, clip)) return entry.key;
    }
    return '';
  }

  static bool _isLooping(String name) =>
      const <String>{'Idle', 'Walk', 'Run', 'Sleep', 'Eat', 'Drink'}
          .contains(name);
}
