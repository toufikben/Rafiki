import 'package:flutter/foundation.dart';

/// Values are injected at build time with --dart-define.
/// Release builds fail closed when production identifiers are not supplied.
class ReleaseConfig {
  static const adUnitId = String.fromEnvironment('RAFIQ_AD_UNIT_ID');
  static const premiumProductId =
      String.fromEnvironment('RAFIQ_PREMIUM_PRODUCT_ID');
  static const monthlyProductId =
      String.fromEnvironment('RAFIQ_MONTHLY_PRODUCT_ID');

  static bool get adsConfigured => adUnitId.trim().isNotEmpty;
  static bool get purchasesConfigured =>
      premiumProductId.trim().isNotEmpty && monthlyProductId.trim().isNotEmpty;

  static bool get allowTestAds => !kReleaseMode && !adsConfigured;
  static bool get allowTestPurchases => !kReleaseMode && !purchasesConfigured;
}
