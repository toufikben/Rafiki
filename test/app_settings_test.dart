import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:rafiq/core/constants/pet_species.dart';
import 'package:rafiq/core/models/app_settings.dart';
import 'package:rafiq/core/models/pet_state.dart';
import 'package:rafiq/data/database.dart';
import 'package:rafiq/services/interaction_sounds.dart';

void main() {
  group('AppSettings persistence', () {
    late Directory directory;
    late String databaseName;

    setUp(() async {
      await Isar.initializeIsarCore(download: true);
      databaseName = 'app_settings_${DateTime.now().microsecondsSinceEpoch}';
      directory = await Directory.systemTemp.createTemp('rafiq_settings_');
      await Database.init(directory: directory.path, name: databaseName);
    });

    tearDown(() async {
      await Database.close(deleteFromDisk: true);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    test('defaults to sound enabled when no settings row exists', () async {
      final settings = await Database.getSettings();

      expect(settings.soundEnabled, isTrue);
      expect(settings.id, 0);
    });

    test('roundtrips a disabled sound setting across reads', () async {
      await Database.saveSettings(
        AppSettings()..soundEnabled = false,
      );

      final loaded = await Database.getSettings();

      expect(loaded.soundEnabled, isFalse);
      expect(loaded.id, 0);
    });

    test('settings survive delete-all pet data', () async {
      final now = DateTime.now();
      await Database.savePet(
        PetState()
          ..name = 'Seed'
          ..species = 'cat'
          ..birthDate = now
          ..lastInteraction = now
          ..lastFed = now
          ..lastPlayed = now
          ..lastUpdated = now,
      );
      await Database.saveSettings(
        AppSettings()..soundEnabled = false,
      );

      await Database.deleteAll();

      expect(await Database.getPet(), isNull);
      // The sound toggle is an app preference, not pet data.
      final settings = await Database.getSettings();
      expect(settings.soundEnabled, isFalse);
    });
  });

  group('interaction one-shot sound mapping', () {
    test('dog is owned by DogAudioController and never maps a sound', () {
      for (final action in ['feed', 'play', 'pet', 'clean', 'drink']) {
        expect(
          interactionSound(PetSpecies.dog, action),
          isNull,
          reason: 'dog $action must route through DogAudioController',
        );
      }
    });

    test('cat maps feed/play/pet and stays silent for clean/drink', () {
      expect(interactionSound(PetSpecies.cat, 'feed'), InteractionSound.happy);
      expect(interactionSound(PetSpecies.cat, 'play'), InteractionSound.meow);
      expect(interactionSound(PetSpecies.cat, 'pet'), InteractionSound.purr);
      expect(interactionSound(PetSpecies.cat, 'clean'), isNull);
      expect(interactionSound(PetSpecies.cat, 'drink'), isNull);
    });

    test('bunny has no dedicated sounds and only gets the generic feed cue',
        () {
      expect(interactionSound(PetSpecies.bunny, 'feed'), InteractionSound.happy);
      for (final action in ['play', 'pet', 'clean', 'drink']) {
        expect(interactionSound(PetSpecies.bunny, action), isNull);
      }
    });
  });
}
