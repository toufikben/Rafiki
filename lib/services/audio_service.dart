import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../core/models/behavior_type.dart';
import 'audio_cooldown_policy.dart';

/// Central audio mixer for the virtual pet.
///
/// Looping body sounds (breathing/panting) use dedicated players so they never
/// interrupt one-shot actions. One-shot sounds are rate-limited and use a
/// separate channel, which avoids the old stop-and-replace behaviour.
class AudioService {
  static final AudioPlayer _oneshot = AudioPlayer(playerId: 'rafiq-oneshot');
  static final AudioPlayer _body = AudioPlayer(playerId: 'rafiq-body');
  static final AudioPlayer _steps = AudioPlayer(playerId: 'rafiq-steps');
  static bool _enabled = true;
  static bool _initialized = false;
  static String? _bodyLoop;
  static final AudioCooldownPolicy _cooldowns = AudioCooldownPolicy();

  static const _minStepGap = Duration(milliseconds: 360);
  static const _minBarkGap = Duration(seconds: 3);
  static const _minWhineGap = Duration(seconds: 5);
  static const _minTouchGap = Duration(milliseconds: 850);
  static const _minTouchMoveGap = Duration(milliseconds: 280);

  static void init() {
    _initialized = true;
    for (final player in [_oneshot, _body, _steps]) {
      unawaited(player.setReleaseMode(ReleaseMode.stop));
    }
  }

  static void setEnabled(bool value) {
    _enabled = value;
    if (!value) unawaited(stopAll());
  }

  static bool get isEnabled => _enabled;

  static Future<void> _playOneShot(
    String asset, {
    double volume = 0.85,
  }) async {
    if (!_enabled || !_initialized) return;
    try {
      await _oneshot.setVolume(volume.clamp(0.0, 1.0));
      await _oneshot.play(AssetSource(asset));
    } catch (_) {}
  }

  static Future<void> _startBodyLoop(
    String asset, {
    double volume = 0.42,
  }) async {
    if (!_enabled || !_initialized || _bodyLoop == asset) return;
    try {
      await _body.stop();
      await _body.setReleaseMode(ReleaseMode.loop);
      await _body.setVolume(volume.clamp(0.0, 1.0));
      _bodyLoop = asset;
      await _body.play(AssetSource(asset));
    } catch (_) {
      _bodyLoop = null;
    }
  }

  static Future<void> _stopBodyLoop() async {
    if (_bodyLoop == null) return;
    _bodyLoop = null;
    try {
      await _body.stop();
    } catch (_) {}
  }

  static Future<void> setBodyVolume(double volume) async {
    if (!_enabled || _bodyLoop == null) return;
    try {
      await _body.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  static Future<void> playPurr() => _playOneShot('sounds/purr.mp3', volume: 0.58);
  static Future<void> playMeow() => _playOneShot('sounds/meow.mp3');
  static Future<void> playHappy() => _playOneShot('sounds/happy.mp3');

  static Future<void> playDogBark() async {
    if (!_cooldowns.allow('bark', _minBarkGap)) return;
    await _playOneShot('sounds/dog_bark.mp3', volume: 0.82);
  }

  /// A quieter bark used for a direct tap on the 3D pet.
  static Future<void> playDogTouch() async {
    if (!_cooldowns.allow('touch', _minTouchGap)) return;
    await _playOneShot('sounds/dog_bark.mp3', volume: 0.42);
  }

  /// A restrained movement cue while the user drags across the 3D pet.
  static Future<void> playDogTouchMove() async {
    if (!_cooldowns.allow('touch_move', _minTouchMoveGap)) return;
    try {
      await _steps.setVolume(0.12);
      await _steps.play(AssetSource('sounds/dog_steps.mp3'));
    } catch (_) {}
  }

  static Future<void> playDogWhine() async {
    if (!_cooldowns.allow('whine', _minWhineGap)) return;
    await _playOneShot('sounds/dog_whine.mp3', volume: 0.55);
  }

  static Future<void> playDogSteps({required bool running}) async {
    final gap = running
        ? const Duration(milliseconds: 230)
        : _minStepGap;
    if (!_cooldowns.allow('steps', gap)) return;
    try {
      await _steps.setVolume(running ? 0.45 : 0.28);
      await _steps.play(AssetSource('sounds/dog_steps.mp3'));
    } catch (_) {}
  }

  static Future<void> syncDogBehavior({
    required BehaviorType behavior,
    required double speed,
  }) async {
    if (!_enabled || !_initialized) return;
    switch (behavior) {
      case BehaviorType.sleeping:
        await _startBodyLoop('sounds/dog_breathing.mp3', volume: 0.28);
        break;
      case BehaviorType.running:
      case BehaviorType.playing:
        await _startBodyLoop('sounds/dog_panting.mp3', volume: 0.36);
        await playDogSteps(running: true);
        break;
      case BehaviorType.walking:
      case BehaviorType.followingCursor:
        await _startBodyLoop('sounds/dog_breathing.mp3', volume: 0.22);
        await playDogSteps(running: false);
        break;
      case BehaviorType.begging:
      case BehaviorType.hiding:
        await _stopBodyLoop();
        await playDogWhine();
        break;
      case BehaviorType.celebrating:
        await _startBodyLoop('sounds/dog_panting.mp3', volume: 0.30);
        await playDogBark();
        break;
      case BehaviorType.idle:
      case BehaviorType.eating:
        await _startBodyLoop('sounds/dog_breathing.mp3', volume: 0.18);
        break;
    }

    // Faster movement makes breathing more present without changing pitch.
    if (speed > 0) {
      await setBodyVolume((0.16 + speed / 700.0).clamp(0.16, 0.48));
    }
  }

  static Future<void> stopAll() async {
    await Future.wait<void>([
      _oneshot.stop(),
      _body.stop(),
      _steps.stop(),
    ]);
    _bodyLoop = null;
    _cooldowns.reset();
  }

  static Future<void> dispose() async {
    await stopAll();
    await _oneshot.dispose();
    await _body.dispose();
    await _steps.dispose();
    _initialized = false;
  }
}

/// Coordinates sound with the current animation state. Kept separate from the
/// renderer so the same timing policy works for both the 2D fallback and GLB.
class DogAudioController {
  BehaviorType? _lastBehavior;
  bool _isDog = false;

  void setSpecies(String species) {
    _isDog = species.toLowerCase().contains('dog') ||
        species.toLowerCase().contains('puppy') ||
        species.contains('كلب');
  }

  void tick({required BehaviorType behavior, required double speed}) {
    if (!_isDog) return;
    if (_lastBehavior != behavior) {
      _lastBehavior = behavior;
      unawaited(AudioService.syncDogBehavior(behavior: behavior, speed: speed));
    } else if (behavior == BehaviorType.walking ||
        behavior == BehaviorType.running ||
        behavior == BehaviorType.playing ||
        behavior == BehaviorType.followingCursor) {
      unawaited(AudioService.syncDogBehavior(behavior: behavior, speed: speed));
    }
  }

  void interaction(String action) {
    if (!_isDog) return;
    switch (action) {
      case 'feed':
        unawaited(AudioService.playDogBark());
      case 'play':
        unawaited(AudioService.playDogBark());
      case 'pet':
        unawaited(AudioService.playHappy());
      case 'clean':
        unawaited(AudioService.playDogWhine());
    }
  }

  void dispose() {
    _lastBehavior = null;
    _isDog = false;
    unawaited(AudioService.stopAll());
  }
}
