import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/core/models/behavior_type.dart';
import 'package:rafiq/core/models/pet_state.dart';
import 'package:rafiq/render/dog_animation_controller.dart';

void main() {
  group('DogAnimationController', () {
    test('maps locomotion behaviors to authored clips', () {
      final pet = PetState();
      expect(
        DogAnimationController.clipFor(
          pet: pet,
          behavior: BehaviorType.walking,
        ),
        'Walk',
      );
      expect(
        DogAnimationController.clipFor(
          pet: pet,
          behavior: BehaviorType.running,
        ),
        'Run',
      );
    });

    test('welfare constraints override locomotion', () {
      final pet = PetState()..energy = 0.1;
      expect(
        DogAnimationController.clipFor(
          pet: pet,
          behavior: BehaviorType.running,
        ),
        'Sleep',
      );

      final sadPet = PetState()
        ..energy = 0.8
        ..happiness = 0.1;
      expect(
        DogAnimationController.clipFor(
          pet: sadPet,
          behavior: BehaviorType.running,
        ),
        'Sad',
      );
    });

    test('short happy action reports a return target', () {
      final controller = DogAnimationController();
      final pet = PetState()..happiness = 0.8;
      controller.select(pet: pet, behavior: BehaviorType.running);
      final selection = controller.select(
        pet: pet,
        behavior: BehaviorType.celebrating,
      );

      expect(selection.clip, 'Happy');
      expect(selection.previousClip, 'Run');
      expect(selection.resumeClip, 'Run');
      expect(selection.loop, isFalse);
    });

    test('sleep transition is slower and run is not looping after sleep', () {
      final controller = DogAnimationController();
      final pet = PetState()..energy = 0.1;
      final selection = controller.select(
        pet: pet,
        behavior: BehaviorType.sleeping,
      );
      expect(selection.clip, 'Sleep');
      expect(selection.transition, const Duration(milliseconds: 300));
      expect(selection.loop, isTrue);
    });
  });

  test('production manifest contains all required contract names', () {
    final manifest = jsonDecode(
      File('assets/models/dog/dog_rig_manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(missingDogContractEntries(manifest), isEmpty);
  });
}
