import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../config/release_config.dart';

class PurchaseService {
  static String get premiumId => ReleaseConfig.purchasesConfigured
      ? ReleaseConfig.premiumProductId
      : 'rafiq_premium_lifetime';
  static String get monthlyId => ReleaseConfig.purchasesConfigured
      ? ReleaseConfig.monthlyProductId
      : 'rafiq_monthly';

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _sub;
  static List<ProductDetails> _products = [];
  static bool _isPremium = false;

  static final StreamController<void> _premiumGrantController =
      StreamController<void>.broadcast();

  /// Emits whenever a purchase or restore grants premium entitlement.
  ///
  /// Broadcast on purpose: the entitlement owner (PetNotifier) may not exist
  /// yet when a restore lands during [init]; those consumers catch up via
  /// [isPremium] after subscribing.
  static Stream<void> get premiumGrants => _premiumGrantController.stream;

  static bool get isPremium => _isPremium;
  static List<ProductDetails> get products => _products;

  static Future<void> init() async {
    if (!ReleaseConfig.purchasesConfigured && !ReleaseConfig.allowTestPurchases) {
      return;
    }
    final available = await _iap.isAvailable();
    if (!available) return;

    final ids = <String>{premiumId, monthlyId};
    final response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;

    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate);
    await _iap.restorePurchases();
  }

  static void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        // Both SKUs grant the same local entitlement flag; subscription
        // expiry/renewal validation requires server-side receipt checking
        // and is deliberately out of scope for the offline wiring.
        if (p.productID == premiumId || p.productID == monthlyId) {
          _isPremium = true;
          _premiumGrantController.add(null);
        }
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  static Future<void> buyPremium() async {
    if (_products.isEmpty) return;
    final product = _products.firstWhere(
      (p) => p.id == premiumId,
      orElse: () => _products.first,
    );
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  static Future<void> restore() => _iap.restorePurchases();

  static void dispose() {
    _sub?.cancel();
    _premiumGrantController.close();
  }
}
