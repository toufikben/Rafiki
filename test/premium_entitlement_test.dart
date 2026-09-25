import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:rafiq/data/database.dart';
import 'package:rafiq/providers/pet_provider.dart';
import 'package:rafiq/services/ad_service.dart';

void main() {
  late Directory directory;
  late String databaseName;
  late StreamController<void> grants;

  setUp(() async {
    // AdService is process-global static state; reset between tests so
    // assertions measure this test's seeding, not a previous one's.
    AdService.setPremium(false);
    grants = StreamController<void>.broadcast();
    await Isar.initializeIsarCore(download: true);
    databaseName = 'premium_${DateTime.now().microsecondsSinceEpoch}';
    directory = await Directory.systemTemp.createTemp('rafiq_premium_');
    await Database.init(directory: directory.path, name: databaseName);
  });

  tearDown(() async {
    await Database.close(deleteFromDisk: true);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await grants.close();
  });

  ProviderContainer bootContainer() {
    final container = ProviderContainer(
      overrides: [
        premiumGrantStreamProvider.overrideWithValue(grants.stream),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('a purchase grant marks the pet premium, suppresses ads, persists',
      () async {
    final container = bootContainer();
    final notifier = container.read(petProvider.notifier);
    await notifier.createPet('Nimbus', 'dog');
    expect(container.read(petProvider)!.isPremium, isFalse);
    expect(AdService.isPremium, isFalse);

    // Simulate the billing plugin reporting a purchased/restored product.
    grants.add(null);
    await Future<void>.delayed(Duration.zero);

    final pet = container.read(petProvider)!;
    expect(pet.isPremium, isTrue);
    expect(pet.premiumSince, isNotNull);
    expect(AdService.isPremium, isTrue);

    // A duplicate grant is idempotent: the original premiumSince survives.
    final since = pet.premiumSince;
    grants.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(petProvider)!.premiumSince, since);

    // The entitlement must survive process death, so it has to be persisted.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final stored = await Database.getPet();
    expect(stored!.isPremium, isTrue);
    expect(stored.premiumSince, isNotNull);
  });

  test('premium survives restart via persisted state', () async {
    // Manually managed: the first container must be torn down before the
    // second boots, so it deliberately skips the addTearDown auto-dispose.
    final first = ProviderContainer(
      overrides: [
        premiumGrantStreamProvider.overrideWithValue(grants.stream),
      ],
    );
    await first.read(petProvider.notifier).createPet('Nimbus', 'dog');
    grants.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(first.read(petProvider)!.isPremium, isTrue);
    first.dispose();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    AdService.setPremium(false);

    // Fresh container on the same database emulates a cold start.
    final second = bootContainer();
    await second.read(petProvider.notifier).initialized;

    expect(second.read(petProvider)!.isPremium, isTrue);
    expect(second.read(petProvider)!.name, 'Nimbus');
    expect(AdService.isPremium, isTrue);
  });
}
