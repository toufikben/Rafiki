import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// Small, reversible reactions driven by touch input.
///
/// This component does not replace authored animation. It adds a local yaw,
/// a soft vertical placement offset, and a short pat/bounce impulse on top of
/// the current pose. All offsets are spring-damped and return to neutral.
class DogInteractionMotion extends Component {
  DogInteractionMotion({
    this.maxYaw = 0.42,
    this.maxLift = 0.10,
  });

  final double maxYaw;
  final double maxLift;

  vm.Vector3? _basePosition;
  vm.Quaternion? _baseRotation;
  double _targetYaw = 0;
  double _yaw = 0;
  double _targetLift = 0;
  double _lift = 0;
  double _patVelocity = 0;
  double _patOffset = 0;
  double _patCooldown = 0;

  @override
  void onAttach() {
    _basePosition = node.position;
    _baseRotation = node.rotation;
  }

  /// Friendly response to a tap or pet gesture.
  void pat() {
    if (_patCooldown > 0) return;
    _patVelocity += 1.35;
    _targetLift = 0.045;
    _patCooldown = 0.16;
  }

  /// Maps a horizontal drag to a bounded, springy turn.
  void dragHorizontal(double pixels, double viewportWidth) {
    if (viewportWidth <= 0) return;
    _targetYaw = (_targetYaw + pixels / viewportWidth * 0.85)
        .clamp(-maxYaw, maxYaw)
        .toDouble();
  }

  /// Maps a vertical drag to a subtle placement response.
  void dragVertical(double pixels, double viewportHeight) {
    if (viewportHeight <= 0) return;
    _targetLift = (_targetLift - pixels / viewportHeight * maxLift)
        .clamp(-maxLift, maxLift)
        .toDouble();
  }

  /// Lets the dog settle back to a neutral pose after a gesture.
  void release() {
    _targetYaw *= 0.35;
    _targetLift = 0;
  }

  @override
  void update(double deltaSeconds) {
    final dt = deltaSeconds.clamp(0.0, 0.05);
    _patCooldown = math.max(0, _patCooldown - dt);

    _yaw = _approach(_yaw, _targetYaw, dt, 8.0);
    _lift = _approach(_lift, _targetLift, dt, 9.0);

    _patVelocity += -_patOffset * 34.0 * dt;
    _patVelocity *= math.pow(0.055, dt).toDouble();
    _patOffset += _patVelocity * dt;
    if (_patOffset < 0 && _patVelocity < 0) {
      _patOffset = 0;
      _patVelocity = 0;
    }

    final basePosition = _basePosition;
    final baseRotation = _baseRotation;
    if (basePosition == null || baseRotation == null) return;

    node.position = basePosition + vm.Vector3(0, _lift + _patOffset, 0);
    node.rotation = baseRotation *
        vm.Quaternion.axisAngle(vm.Vector3(0, 1, 0), _yaw);
  }

  double _approach(double value, double target, double dt, double speed) {
    final amount = 1.0 - math.exp(-speed * dt);
    return value + (target - value) * amount;
  }
}
