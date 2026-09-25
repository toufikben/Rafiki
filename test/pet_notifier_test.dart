import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:rafiq/core/models/pet_state.dart';
import 'package:rafiq/data/database.dart';
import 'package:rafiq/providers/pet_provider.dart';

void main() {
  group('PetState.clone', () {
    test('copies every persisted field including the Isar id', () {
      final now = DateTime(2026, 9, 25, 12);
      final pet = PetState()
        ..id = 42
        ..name = 'Rafiq'
        ..species = 'dog'
        ..birthDate = now
        ..lastInteraction = now
        ..lastFed = now
        ..lastPlayed = now
        ..lastUpdated = now
        ..hunger = 0.11
        ..energy = 0.22
        ..happiness = 0.33
        ..cleanliness = 0.44
        ..affection = 0.55
        ..hydration = 0.66
        ..stress = 0.77
        ..sleepDebt = 0.88
        ..evolutionStage = 2
        ..experiencePoints = 137
        ..trustLevel = 0.9
        ..posX = 12
        ..posY = 34
        ..velocityX = -5
        ..velocityY = 6
        ..currentBehavior = 'play'
        ..mood = 'neutral'
        ..totalInteractions = 9
        ..learningProfileJson = '{"v":1}'
        ..learningSamples = 3
        ..isPremium = true
        ..premiumSince = now;

      final clone = pet.clone();

      expect(clone.id, pet.id);
      expect(clone.name, pet.name);
      expect(clone.species, pet.species);
      expect(clone.birthDate, pet.birthDate);
      expect(clone.lastInteraction, pet.lastInteraction);
      expect(clone.lastFed, pet.lastFed);
      expect(clone.lastPlayed, pet.lastPlayed);
      expect(clone.lastUpdated, pet.lastUpdated);
      expect(clone.hunger, pet.hunger);
      expect(clone.energy, pet.energy);
      expect(clone.happiness, pet.happiness);
      expect(clone.cleanliness, pet.cleanliness);
      expect(clone.affection, pet.affection);
      expect(clone.hydration, pet.hydration);
      expect(clone.stress, pet.stress);
      expect(clone.sleepDebt, pet.sleepDebt);
      expect(clone.evolutionStage, pet.evolutionStage);
      expect(clone.experiencePoints, pet.experiencePoints);
      expect(clone.trustLevel, pet.trustLevel);
      expect(clone.posX, pet.posX);
      expect(clone.posY, pet.posY);
      expect(clone.velocityX, pet.velocityX);
      expect(clone.velocityY, pet.velocityY);
      expect(clone.currentBehavior, pet.currentBehavior);
      expect(clone.mood, pet.mood);
      expect(clone.totalInteractions, pet.totalInteractions);
      expect(clone.learningProfileJson, pet.learningProfileJson);
      expect(clone.learningSamples, pet.learningSamples);
      expect(clone.isPremium, pet.isPremium);
      expect(clone.premiumSince, pet.premiumSince);
      expect(clone, isNot(same(pet)));
    });
  });

  group('PetNotifier lifecycle', () {
    late Directory directory;
    late String databaseName;

    setUp(() async {
      await Isar.initializeIsarCore(download: true);
      databaseName = 'pet_notifier_${DateTime.now().microsecondsSinceEpoch}';
      directory = await Directory.systemTemp.createTemp('rafiq_notifier_');
      await Database.init(directory: directory.path, name: databaseName);
    });

    tearDown(() async {
      await Database.close(deleteFromDisk: true);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    Future<ProviderContainer> bootstrappedContainer() async {
      final container = ProviderContainer();
      // Disposing the container disposes the notifier and cancels its timer.
      addTearDown(container.dispose);
      await container.read(petProvider.notifier).createPet('Nimbus', 'dog');
      return container;
    }

    test('an interaction publishes a new state instance to watchers',
        () async {
      final container = await bootstrappedContainer();
      final notifier = container.read(petProvider.notifier);
      final before = container.read(petProvider)!;

      final emitted = <PetState?>[];
      container.listen<PetState?>(
        petProvider,
        (_, next) => emitted.add(next),
      );

      await notifier.feed();

      final after = container.read(petProvider)!;
      expect(emitted, isNotEmpty);
      expect(after, isNot(same(before)));
      expect(after.id, before.id);
      expect(after.hunger, greaterThan(before.hunger));
      expect(after.totalInteractions, before.totalInteractions + 1);
    });

    test('the 1 Hz simulation tick notifies watchers without an interaction',
        () async {
      final container = await bootstrappedContainer();
      final initial = container.read(petProvider)!;

      final emitted = <PetState?>[];
      container.listen<PetState?>(
        petProvider,
        (_, next) => emitted.add(next),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1600));

      expect(emitted, isNotEmpty);
      expect(emitted.last, isNot(same(initial)));
      expect(emitted.last!.id, initial.id);
    });

    test('deleteAllData clears provider state and the pet stays deleted',
        () async {
      final container = await bootstrappedContainer();
      final notifier = container.read(petProvider.notifier);
      expect(await Database.getPet(), isNotNull);

      await notifier.deleteAllData();

      expect(container.read(petProvider), isNull);
      expect(await Database.getPet(), isNull);

      // Regression pin: the old implementation kept its in-memory pet and
      // the tick loop re-saved it within one second, undoing the deletion.
      await Future<void>.delayed(const Duration(milliseconds: 1600));
      expect(await Database.getPet(), isNull);
      expect(container.read(petProvider), isNull);
    });
  });
}
