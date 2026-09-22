import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/pet_state.dart';
import '../core/models/behavior_decision.dart';
import '../engine/needs_system.dart';
import '../engine/evolution_system.dart';
import '../ai/ai_service.dart';
import '../data/database.dart';
import '../services/notification_service.dart';

final petProvider =
    StateNotifierProvider<PetNotifier, PetState?>((ref) => PetNotifier());

class PetNotifier extends StateNotifier<PetState?> {
  final AIService _ai = AIService();
  Timer? _tickTimer;
  DateTime _lastUpdate = DateTime.now();

  PetNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    await _ai.init();
    if (!Database.isReady) await Database.init();
    state = await Database.getPet();
    if (state != null) {
      _lastUpdate = state!.lastUpdated;
      _startLoop();
    }
  }

  void _startLoop() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void _tick() {
    if (state == null) return;
    final now = DateTime.now();
    final elapsed = now.difference(_lastUpdate);
    if (elapsed.inSeconds < 1) return;
    _lastUpdate = now;

    final updated = NeedsSystem.update(state!, elapsed);
    final evolved = EvolutionSystem.checkEvolution(updated);
    if (evolved) {
      _onEvolution();
    }
    state = updated;
    Database.savePet(updated);
  }

  Future<void> _onEvolution() async {
    if (state == null) return;
    await NotificationService.showEvolution(state!.name);
  }

  void movePet(BehaviorDecision decision, Duration delta) {
    if (state == null) return;
    final pet = state!;
    final dt = delta.inMilliseconds / 1000.0;
    if (dt <= 0) return;

    const maxX = 350.0;
    const maxY = 550.0;

    if (decision.targetX != null && decision.targetY != null) {
      final dx = decision.targetX! - pet.posX;
      final dy = decision.targetY! - pet.posY;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist > 5) {
        final angle = math.atan2(dy, dx);
        final approachSpeed = decision.speed *
            (dist < 45 ? (dist / 45).clamp(0.35, 1.0) : 1.0);
        final step = math.min(approachSpeed * dt, dist);
        pet.velocityX = math.cos(angle) * approachSpeed;
        pet.velocityY = math.sin(angle) * approachSpeed;
        pet.posX += math.cos(angle) * step;
        pet.posY += math.sin(angle) * step;
      } else {
        pet.velocityX = 0;
        pet.velocityY = 0;
      }
    } else if (decision.speed > 0) {
      if (pet.velocityX == 0 && pet.velocityY == 0) {
        final angle = math.Random().nextDouble() * 2 * math.pi;
        pet.velocityX = math.cos(angle) * decision.speed;
        pet.velocityY = math.sin(angle) * decision.speed;
      }
      pet.posX += pet.velocityX * dt;
      pet.posY += pet.velocityY * dt;

      if (pet.posX < 0 || pet.posX > maxX) {
        pet.velocityX = -pet.velocityX;
        pet.posX = pet.posX.clamp(0.0, maxX);
      }
      if (pet.posY < 0 || pet.posY > maxY) {
        pet.velocityY = -pet.velocityY;
        pet.posY = pet.posY.clamp(0.0, maxY);
      }
    } else {
      pet.velocityX = 0;
      pet.velocityY = 0;
    }

    state = pet;
  }

  Future<void> feed() async {
    if (state == null) return;
    NeedsSystem.feed(state!);
    await _learn('feed', 0.72);
    state = state;
    await Database.savePet(state!);
  }

  Future<void> play() async {
    if (state == null) return;
    NeedsSystem.play(state!);
    await _learn('play', 0.92);
    state = state;
    await Database.savePet(state!);
  }

  Future<void> petPet() async {
    if (state == null) return;
    NeedsSystem.pet(state!);
    await _learn('pet', 0.84);
    state = state;
    await Database.savePet(state!);
  }

  Future<void> clean() async {
    if (state == null) return;
    NeedsSystem.clean(state!);
    await _learn('clean', 0.46);
    state = state;
    await Database.savePet(state!);
  }

  Future<void> drink() async {
    if (state == null) return;
    NeedsSystem.drink(state!);
    await _learn('drink', 0.58);
    state = state;
    await Database.savePet(state!);
  }

  Future<String?> react(String context) async {
    final pet = state;
    if (pet == null) return null;
    return _ai.generateReaction(pet: pet, context: context);
  }

  Future<String?> chat(String text) async {
    final pet = state;
    if (pet == null || text.trim().isEmpty) return null;
    return _ai.chat(pet: pet, text: text.trim());
  }

  Future<void> _learn(String action, double reward) async {
    final pet = state;
    if (pet == null) return;
    await _ai.recordInteraction(pet: pet, action: action, reward: reward);
  }

  Future<void> createPet(String name, String species) async {
    final now = DateTime.now();
    final pet = PetState()
      ..name = name
      ..species = species
      ..birthDate = now
      ..lastInteraction = now
      ..lastFed = now
      ..lastPlayed = now
      ..lastUpdated = now
      ..posX = 100
      ..posY = 200;

    await Database.savePet(pet);
    state = pet;
    _lastUpdate = now;
    _startLoop();
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _ai.dispose();
    super.dispose();
  }
}
