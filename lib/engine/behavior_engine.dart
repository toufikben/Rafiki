import 'dart:math';
import 'dart:ui';
import '../core/models/pet_state.dart';
import '../core/models/behavior_type.dart';
import '../core/models/behavior_decision.dart';
import '../ai/learning_profile.dart';

class BehaviorEngine {
  final Random _rng = Random();
  BehaviorType _current = BehaviorType.idle;
  Duration _stateElapsed = Duration.zero;
  Duration _stateDuration = const Duration(seconds: 3);
  Offset? _wanderTarget;

  BehaviorType get currentBehavior => _current;

  BehaviorDecision tick(
    PetState pet,
    Duration delta,
    Offset cursor, {
    LearningProfile? learningProfile,
  }) {
    _stateElapsed += delta;

    if (_stateElapsed >= _stateDuration) {
      _current = _decideNextBehavior(pet, learningProfile);
      _stateElapsed = Duration.zero;
      _stateDuration = _randomDuration(_current);
      _wanderTarget = _newWanderTarget(pet, _current);
    }

    return BehaviorDecision(
      type: _current,
      targetX: _computeTargetX(cursor, pet),
      targetY: _computeTargetY(cursor, pet),
      speed: _speedFor(_current),
      duration: _stateDuration,
    );
  }

  BehaviorType _decideNextBehavior(PetState pet, LearningProfile? profile) {
    if (pet.energy < 0.15) return BehaviorType.sleeping;
    if (pet.hunger < 0.20 || pet.hydration < 0.20) {
      return BehaviorType.begging;
    }
    if (pet.stress > 0.82) return BehaviorType.hiding;

    switch (pet.mood) {
      case 'excited':
        return _rng.nextDouble() < 0.6
            ? BehaviorType.playing
            : BehaviorType.running;
      case 'sleepy':
        return BehaviorType.sleeping;
      case 'sad':
        return _rng.nextDouble() < 0.4
            ? BehaviorType.hiding
            : BehaviorType.idle;
      case 'lonely':
        return BehaviorType.followingCursor;
      case 'hungry':
        return BehaviorType.begging;
    }

    final choices = <BehaviorType>[
      BehaviorType.idle,
      BehaviorType.walking,
      BehaviorType.followingCursor,
      BehaviorType.playing,
      BehaviorType.celebrating,
    ];
    final baseWeights = <double>[0.28, 0.30, 0.14, 0.14, 0.14];
    var total = 0.0;
    for (var i = 0; i < choices.length; i++) {
      final learned = profile?.behaviorBonus(choices[i]) ?? 0.0;
      baseWeights[i] = max(0.02, baseWeights[i] + learned);
      total += baseWeights[i];
    }
    var roll = _rng.nextDouble() * total;
    for (var i = 0; i < choices.length; i++) {
      roll -= baseWeights[i];
      if (roll <= 0) return choices[i];
    }
    return choices.last;
  }

  Duration _randomDuration(BehaviorType type) {
    switch (type) {
      case BehaviorType.sleeping:
        return Duration(seconds: 15 + _rng.nextInt(30));
      case BehaviorType.playing:
        return Duration(seconds: 4 + _rng.nextInt(5));
      case BehaviorType.idle:
        return Duration(seconds: 2 + _rng.nextInt(4));
      default:
        return Duration(seconds: 3 + _rng.nextInt(5));
    }
  }

  double _speedFor(BehaviorType type) {
    switch (type) {
      case BehaviorType.running:
        return 180.0;
      case BehaviorType.walking:
        return 60.0;
      case BehaviorType.followingCursor:
        return 120.0;
      case BehaviorType.playing:
        return 100.0;
      default:
        return 0.0;
    }
  }

  Offset _newWanderTarget(PetState pet, BehaviorType type) {
    if (type == BehaviorType.hiding) return const Offset(24, 24);
    if (type == BehaviorType.idle || type == BehaviorType.sleeping) {
      return Offset(pet.posX, pet.posY);
    }
    final radius = type == BehaviorType.running ? 180.0 : 110.0;
    final angle = _rng.nextDouble() * 2 * pi;
    final distance = 50 + _rng.nextDouble() * radius;
    return Offset(
      (pet.posX + cos(angle) * distance).clamp(20.0, 310.0),
      (pet.posY + sin(angle) * distance).clamp(20.0, 510.0),
    );
  }

  double? _computeTargetX(Offset cursor, PetState pet) {
    if (_current == BehaviorType.followingCursor) return cursor.dx - 40;
    if (_current == BehaviorType.walking ||
        _current == BehaviorType.running ||
        _current == BehaviorType.playing ||
        _current == BehaviorType.celebrating ||
        _current == BehaviorType.hiding) {
      return (_wanderTarget ?? _newWanderTarget(pet, _current)).dx;
    }
    return null;
  }

  double? _computeTargetY(Offset cursor, PetState pet) {
    if (_current == BehaviorType.followingCursor) return cursor.dy - 40;
    if (_current == BehaviorType.walking ||
        _current == BehaviorType.running ||
        _current == BehaviorType.playing ||
        _current == BehaviorType.celebrating ||
        _current == BehaviorType.hiding) {
      return (_wanderTarget ?? _newWanderTarget(pet, _current)).dy;
    }
    return null;
  }
}
