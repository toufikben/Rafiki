import 'dart:math' as math;

import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// Procedural secondary motion layered on top of authored GLB animation.
///
/// The authored clip remains responsible for the primary pose (idle, walk,
/// run, eat, and so on). This component adds small local offsets for breathing,
/// ear response, and delayed tail follow-through. Missing optional nodes are
/// ignored so a partially rigged asset can still load safely.
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

  static const Map<String, List<String>> _aliases = <String, List<String>>{
    'Chest': <String>['Chest', 'Spine_02', 'chest'],
    'Spine': <String>['Spine', 'Spine_01', 'spine'],
    'Ear_L': <String>['Ear_L', 'Ear.L', 'ear_l', 'LeftEar'],
    'Ear_R': <String>['Ear_R', 'Ear.R', 'ear_r', 'RightEar'],
    'Tail_01': <String>['Tail_01', 'Tail', 'tail'],
    'Tail_02': <String>['Tail_02', 'Tail.Mid', 'TailTip'],
    'Tail_03': <String>['Tail_03', 'Tail.End', 'TailTipEnd'],
  };

  final Map<String, Node> _joints = <String, Node>{};
  final Map<String, vm.Vector3> _basePositions = <String, vm.Vector3>{};
  final Map<String, vm.Quaternion> _baseRotations = <String, vm.Quaternion>{};
  vm.Vector3? _baseRootScale;
  double _time = 0;
  double _tailVelocity = 0;
  double _tailOffset = 0;

  /// Optional runtime multiplier for behavior states such as sleep or happy.
  /// The value is clamped so a behavior decision cannot produce extreme poses.
  double activityMultiplier = 1.0;

  @override
  void onAttach() {
    _baseRootScale = node.scale;

    for (final entry in _aliases.entries) {
      final joint = _findByAnyName(entry.value);
      if (joint == null) continue;
      _joints[entry.key] = joint;
      _basePositions[entry.key] = joint.position;
      _baseRotations[entry.key] = joint.rotation;
    }
  }

  @override
  void update(double deltaSeconds) {
    // Prevent a paused/resumed app from jumping several seconds in one frame.
    final dt = deltaSeconds.clamp(0.0, 0.05);
    _time += dt;
    final strength = activityMultiplier.clamp(0.0, 1.5) * intensity;

    if (breathing) _updateBreathing(strength);
    if (ears) _updateEars(strength);
    if (tail) _updateTail(dt, strength);
  }

  void _updateBreathing(double strength) {
    final chest = _joints['Chest'];
    final spine = _joints['Spine'];
    final phase = _time * 2.15;
    final breath = math.sin(phase) * 0.012 * strength;
    final lift = math.sin(phase + 0.35) * 0.006 * strength;

    if (chest != null) {
      final base = _basePositions['Chest']!;
      chest.position = base + vm.Vector3(0, lift, 0);
      chest.rotation = _baseRotations['Chest']! *
          vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), breath);
    } else if (spine != null) {
      spine.rotation = _baseRotations['Spine']! *
          vm.Quaternion.axisAngle(vm.Vector3(1, 0, 0), breath * 0.45);
    } else if (_baseRootScale != null) {
      // Fallback for an unrigged prototype: a barely visible whole-body pulse.
      final scale = _baseRootScale!.clone();
      scale.scale(1.0 + math.sin(phase) * 0.006 * strength);
      node.scale = scale;
    }
  }

  void _updateEars(double strength) {
    final sway = math.sin(_time * 2.7 + 0.4) * 0.055 * strength;
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

  void _updateTail(double dt, double strength) {
    // A damped spring gives the tail delayed follow-through rather than a
    // perfectly synchronous sine wave.
    final target = math.sin(_time * 1.9) * 0.32 * strength;
    final force = (target - _tailOffset) * 18.0;
    _tailVelocity += force * dt;
    _tailVelocity *= math.pow(0.18, dt).toDouble();
    _tailOffset += _tailVelocity * dt;

    for (var i = 1; i <= 3; i++) {
      final key = 'Tail_0$i';
      final joint = _joints[key];
      final base = _baseRotations[key];
      if (joint == null || base == null) continue;

      final phase = i * 0.08;
      joint.rotation = base * vm.Quaternion.axisAngle(
        vm.Vector3(0, 1, 0),
        (_tailOffset + phase) * (1.0 - i * 0.12),
      );
    }
  }

  Node? _findByAnyName(List<String> names) {
    final wanted = names.toSet();
    Node? visit(Node current) {
      if (wanted.contains(current.name)) return current;
      for (final child in current.children) {
        final match = visit(child);
        if (match != null) return match;
      }
      return null;
    }

    return visit(node);
  }
}
