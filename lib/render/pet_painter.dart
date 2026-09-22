import 'dart:math';
import 'package:flutter/material.dart';
import '../core/models/pet_state.dart';
import '../core/models/behavior_type.dart';
import '../core/constants/pet_species.dart';

class PetPainter extends CustomPainter {
  final PetState pet;
  final BehaviorType behavior;
  final double animationTime;
  final double scale;

  PetPainter({
    required this.pet,
    required this.behavior,
    required this.animationTime,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawX = pet.posX.clamp(0.0, max(0.0, size.width - 100)).toDouble() + 50;
    final drawY = pet.posY.clamp(0.0, max(0.0, size.height - 100)).toDouble() + 50;

    _drawShadow(canvas, Offset(drawX, drawY + 35), scale);

    canvas.save();
    canvas.translate(drawX, drawY);
    final facing = pet.velocityX < -1 ? -1.0 : 1.0;
    canvas.scale(scale * facing, scale);

    switch (pet.species) {
      case PetSpecies.dog:
        _drawDog(canvas);
        break;
      case PetSpecies.bunny:
        _drawBunny(canvas);
        break;
      case PetSpecies.cat:
      default:
        _drawCat(canvas);
    }

    canvas.restore();
  }

  void _drawShadow(Canvas canvas, Offset center, double s) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 55 * s, height: 12 * s),
      paint,
    );
  }

  // ─── القط ───
  void _drawCat(Canvas canvas) {
    final bodyColor = _bodyColorForMood(pet.mood);
    final bodyPaint = Paint()..color = bodyColor;
    final darkColor = _darken(bodyColor, 0.15);

    _applyIdleOffset(canvas, 2.0);

    // ذيل
    canvas.save();
    canvas.translate(20, 10);
    canvas.rotate(_tailAngle());
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(15, -5, 25, -25)
        ..quadraticBezierTo(28, -32, 22, -35),
      Paint()
        ..color = bodyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 60, height: 45),
      bodyPaint,
    );

    _drawLeg(canvas, const Offset(-18, 18), bodyColor, 10, 14);
    _drawLeg(canvas, const Offset(-8, 20), bodyColor, 10, 14);
    _drawLeg(canvas, const Offset(10, 20), bodyColor, 10, 14);
    _drawLeg(canvas, const Offset(20, 18), bodyColor, 10, 14);

    canvas.save();
    canvas.translate(0, -22);
    canvas.rotate(_headTilt());

    _drawTriangleEar(canvas, const Offset(-12, -14), -0.3, bodyColor, darkColor);
    _drawTriangleEar(canvas, const Offset(12, -14), 0.3, bodyColor, darkColor);

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 40, height: 36),
      bodyPaint,
    );

    _drawEyes(canvas);
    _drawCatNose(canvas);
    _drawMouth(canvas);
    canvas.restore();

    _drawWhiskers(canvas);
  }

  // ─── الكلب ───
  void _drawDog(Canvas canvas) {
    final bodyColor = _bodyColorForMood(pet.mood);
    final bodyPaint = Paint()..color = bodyColor;
    final darkColor = _darken(bodyColor, 0.20);

    _applyIdleOffset(canvas, 2.2);

    canvas.save();
    canvas.translate(22, 5);
    canvas.rotate(_tailAngle() * 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, -4, 18, 8),
        const Radius.circular(4),
      ),
      bodyPaint,
    );
    canvas.restore();

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 65, height: 42),
      bodyPaint,
    );

    _drawLeg(canvas, const Offset(-20, 17), bodyColor, 12, 13);
    _drawLeg(canvas, const Offset(-9, 19), bodyColor, 12, 13);
    _drawLeg(canvas, const Offset(10, 19), bodyColor, 12, 13);
    _drawLeg(canvas, const Offset(21, 17), bodyColor, 12, 13);

    canvas.save();
    canvas.translate(0, -22);
    canvas.rotate(_headTilt() * 0.7);

    _drawFloppyEar(canvas, const Offset(-16, -6), bodyColor, darkColor);
    _drawFloppyEar(canvas, const Offset(16, -6), bodyColor, darkColor);

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 42, height: 38),
      bodyPaint,
    );

    _drawEyes(canvas);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 7), width: 9, height: 6),
      Paint()..color = Colors.black87,
    );
    _drawMouth(canvas);

    if (pet.mood == 'happy' || pet.mood == 'excited') {
      canvas.drawOval(
        Rect.fromCenter(center: const Offset(0, 13), width: 5, height: 4),
        Paint()..color = const Color(0xFFFF7B9B),
      );
    }
    canvas.restore();
  }

  // ─── الأرنب ───
  void _drawBunny(Canvas canvas) {
    final bodyColor = _bodyColorForMood(pet.mood);
    final bodyPaint = Paint()..color = bodyColor;
    final darkColor = _darken(bodyColor, 0.12);

    _applyIdleOffset(canvas, 2.5);

    canvas.drawCircle(const Offset(25, 8), 8, Paint()..color = Colors.white);

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 55, height: 48),
      bodyPaint,
    );

    _drawLeg(canvas, const Offset(-15, 18), bodyColor, 11, 12);
    _drawLeg(canvas, const Offset(-6, 20), bodyColor, 11, 12);
    _drawLeg(canvas, const Offset(7, 20), bodyColor, 11, 12);
    _drawLeg(canvas, const Offset(16, 18), bodyColor, 11, 12);

    canvas.save();
    canvas.translate(0, -22);
    canvas.rotate(_headTilt() * 0.5);

    _drawLongEar(canvas, const Offset(-8, -20), -0.15, bodyColor, darkColor);
    _drawLongEar(canvas, const Offset(8, -20), 0.15, bodyColor, darkColor);

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 40, height: 36),
      bodyPaint,
    );

    _drawEyes(canvas);

    final nose = Path()
      ..moveTo(-3, 6)
      ..lineTo(3, 6)
      ..lineTo(0, 10)
      ..close();
    canvas.drawPath(nose, Paint()..color = const Color(0xFFFF7B9B));
    _drawMouth(canvas);
    canvas.restore();
  }

  // ─── أدوات مساعدة ───

  void _applyIdleOffset(Canvas canvas, double intensity) {
    final breathingSpeed = behavior == BehaviorType.sleeping ? 2.0 : 3.2;
    final breathe = sin(animationTime * breathingSpeed) *
        (behavior == BehaviorType.sleeping ? 1.5 : 0.7);
    final walkBob = (behavior == BehaviorType.walking ||
            behavior == BehaviorType.running)
        ? sin(animationTime * 8) * intensity
        : 0.0;
    final crouch = behavior == BehaviorType.running ? 1.5 : 0.0;
    canvas.translate(0, walkBob + breathe + crouch);
    if (behavior == BehaviorType.sleeping) {
      canvas.scale(1.0 + sin(animationTime * 2) * 0.015, 1.0);
    }
  }

  double _tailAngle() {
    switch (behavior) {
      case BehaviorType.playing:
        return sin(animationTime * 6) * 0.5;
      case BehaviorType.celebrating:
        return sin(animationTime * 8) * 0.6 - 0.3;
      case BehaviorType.sleeping:
        return 0.8;
      default:
        return sin(animationTime * 1.5) * 0.15;
    }
  }

  double _headTilt() {
    if (behavior == BehaviorType.sleeping) return 0.3;
    if (pet.mood == 'sad') return -0.1;
    return sin(animationTime * 0.8) * 0.05;
  }

  void _drawLeg(Canvas canvas, Offset pos, Color color, double w, double h) {
    final moving = behavior == BehaviorType.walking ||
        behavior == BehaviorType.running;
    final stride = moving
        ? sin(animationTime * 8 + pos.dx * 0.18) *
            (behavior == BehaviorType.running ? 4.5 : 2.5)
        : 0.0;
    final pawPos = Offset(pos.dx, pos.dy + stride);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pawPos, width: w, height: h),
        const Radius.circular(5),
      ),
      Paint()..color = color,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pawPos.dx, pawPos.dy + h * 0.42),
        width: w * 0.82,
        height: h * 0.25,
      ),
      Paint()..color = _darken(color, 0.08),
    );
  }

  void _drawTriangleEar(
      Canvas canvas, Offset pos, double angle, Color body, Color dark) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    canvas.drawPath(
      Path()
        ..moveTo(-7, 0)
        ..lineTo(0, -16)
        ..lineTo(7, 0)
        ..close(),
      Paint()..color = body,
    );
    canvas.drawPath(
      Path()
        ..moveTo(-4, 0)
        ..lineTo(0, -10)
        ..lineTo(4, 0)
        ..close(),
      Paint()..color = dark,
    );
    canvas.restore();
  }

  void _drawFloppyEar(Canvas canvas, Offset pos, Color body, Color dark) {
    canvas.drawOval(
      Rect.fromCenter(center: pos, width: 14, height: 22),
      Paint()..color = body,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(pos.dx, pos.dy + 2), width: 8, height: 14),
      Paint()..color = dark,
    );
  }

  void _drawLongEar(
      Canvas canvas, Offset pos, double angle, Color body, Color dark) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-5, -30, 10, 32),
        const Radius.circular(5),
      ),
      Paint()..color = body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-3, -26, 6, 26),
        const Radius.circular(3),
      ),
      Paint()..color = dark,
    );
    canvas.restore();
  }

  void _drawEyes(Canvas canvas) {
    if (behavior == BehaviorType.sleeping) {
      final paint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(
            center: const Offset(-8, 2), width: 8, height: 4),
        pi, pi, false, paint,
      );
      canvas.drawArc(
        Rect.fromCenter(
            center: const Offset(8, 2), width: 8, height: 4),
        pi, pi, false, paint,
      );
      return;
    }

    final eyeSize = pet.mood == 'excited' ? 5.0 : 4.0;
    for (final dx in [-8.0, 8.0]) {
      canvas.drawCircle(
          Offset(dx, 0), eyeSize, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset(dx, 0),
        eyeSize * 0.55,
        Paint()..color = Colors.black87,
      );
      canvas.drawCircle(
        Offset(dx - 1, -1),
        eyeSize * 0.2,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawCatNose(Canvas canvas) {
    canvas.drawCircle(
      const Offset(0, 6),
      3,
      Paint()..color = const Color(0xFFE89B9B),
    );
  }

  void _drawMouth(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (pet.mood == 'happy' || pet.mood == 'excited') {
      canvas.drawArc(
        Rect.fromCenter(
            center: const Offset(0, 9), width: 10, height: 6),
        0, pi, false, paint,
      );
    } else {
      canvas.drawLine(
          const Offset(-3, 10), const Offset(3, 10), paint);
    }
  }

  void _drawWhiskers(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (final dy in [-2.0, 2.0, 6.0]) {
      canvas.drawLine(
          Offset(-10, -18 + dy), Offset(-25, -22 + dy), paint);
      canvas.drawLine(
          Offset(10, -18 + dy), Offset(25, -22 + dy), paint);
    }
  }

  Color _bodyColorForMood(String mood) {
    switch (mood) {
      case 'happy':
      case 'excited':
        return const Color(0xFFFFB870);
      case 'sad':
        return const Color(0xFF9B9B9B);
      case 'sleepy':
        return const Color(0xFFB8A8D8);
      default:
        return const Color(0xFFF5A868);
    }
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(covariant PetPainter old) => true;
}
