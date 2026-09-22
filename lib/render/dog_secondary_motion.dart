import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// Procedural secondary motion layered on top of authored GLB animation.
///
/// The component is deliberately name-driven and fail-safe: if an optional
/// joint is absent from a model, the remaining joints keep animating. It never
/// replaces the primary walk/run/sleep clips; it adds breathing and springy
/// follow-through to authored poses.
class DogSecondaryMotion extends Component {
  DogSecondaryMotion({
    this.breathing = true,
    this.ears = true,
    this.tail = true,
    this.intensity = 1.0,
  });

  final bool breathing;
  final bool ears;
  final bool tail;
  final double intensity;

  final Map<String, Node> _joints = <String, Node>{};
  final Map<String, vm.Vector3> _basePositions = <String, vm.Vector3>{};
  final Map<String, vm.Quaternion> _baseRotations = <String, vm.Quaternion>{};
  vm.Vector3? _baseRootScale;
  double _time = 0;
  double _tailVelocity = 0;
  double _tailOffset = 0;

  static const _jointNames = <String>[
    'Chest',
    'Spine',
    'Ear_L',
    'Ear_R',
    'Tail_01',
    'Tail_02',
    'Tail_03',
  ];

  @override
  void onAttach() {
    _baseRootScale = node.scale;
    for (final name in _jointNames) {
      final joint = node.name == name ? node : node.getChildByName(name);
      if (joint == null) continue;
      _joints[name] = joint;
      _basePositions[name] = joint.position;
      _baseRotations[name] = joint.rotation;
    }
  }

  @override
  void update(double deltaSeconds) {
    // Clamp unusually large frame gaps so a paused/resumed app does not snap.
    final dt = deltaSeconds.clamp(0.0, 0.05);
    _time += dt;

    if (breathing) _updateBreathing();
    if (ears) _updateEars();
    if (tail) _updateTail(dt);
  }

  void _updateBreathing() {
    final chest = _joints['Chest'];
    final spine = _joints['Spine'];
    final breath = math.sin(_time * 2.15) * 0.012 * intensity;
    final lift = math.sin(_time * 2.15 + 0.35) * 0.006 * intensity;

    if (chest != null) {
      final base = _basePositions['Chest']!;
      chest.position = base + vm.Vector3(0, lift, 0);
      chest.rotation = _baseRotations['Chest']! *
          vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), breath);
    }
    if (spine != null) {
      spine.rotation = _baseRotations['Spine']! *
          vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), breath * 0.45);
    }
    if (chest == null && spine == null && _baseRootScale != null) {
      final scale = _baseRootScale!.clone();
      scale.scale(1.0 + math.sin(_time * 2.15) * 0.006 * intensity);
      node.scale = scale;
    }
  }

  void _updateEars() {
    final sway = math.sin(_time * 2.7 + 0.4) * 0.055 * intensity;
    final left = _joints['Ear_L'];
    final right = _joints['Ear_R'];
    if (left != null) {
      left.rotation = _baseRotations['Ear_L']! *
          vm.Quaternion.axisAngle(vm.Vector3(0, 0, 1), sway);
    }
    if (right != null) {
      right.rotation = _baseRotations['Ear_R']! *
          vm.Quaternion.axisAngle(vm.Vector3(0, 0, 1), -sway * 0.92);
    }
  }

  void _updateTail(double dt) {
    // A lightly damped spring gives the tail delayed follow-through instead
    // of a perfectly synchronous sine wave.
    final target = math.sin(_time * 1.9) * 0.32 * intensity;
    final force = (target - _tailOffset) * 18.0;
    _tailVelocity += force * dt;
    _tailVelocity *= math.pow(0.18, dt).toDouble();
    _tailOffset += _tailVelocity * dt;

    for (var i = 1; i <= 3; i++) {
      final joint = _joints['Tail_0$i'];
      if (joint == null) continue;
      final base = _baseRotations['Tail_0$i']!;
      final phase = i * 0.08;
      joint.rotation = base * vm.Quaternion.axisAngle(
        vm.Vector3(0, 1, 0),
        (_tailOffset + phase) * (1.0 - i * 0.12),
      );
    }
  }
}
