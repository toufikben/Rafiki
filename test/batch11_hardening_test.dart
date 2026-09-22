import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafiq/config/release_config.dart';

void main() {
  test('release configuration fails closed without production defines', () {
    expect(ReleaseConfig.adsConfigured, isFalse);
    expect(ReleaseConfig.purchasesConfigured, isFalse);
    expect(ReleaseConfig.allowTestAds, equals(!kReleaseMode));
    expect(ReleaseConfig.allowTestPurchases, equals(!kReleaseMode));
  });
}
