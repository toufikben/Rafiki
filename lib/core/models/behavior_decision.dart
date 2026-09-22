import 'behavior_type.dart';

class BehaviorDecision {
  final BehaviorType type;
  final double? targetX;
  final double? targetY;
  final double speed;
  final Duration duration;

  const BehaviorDecision({
    required this.type,
    this.targetX,
    this.targetY,
    required this.speed,
    required this.duration,
  });
}
