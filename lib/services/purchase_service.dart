import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static const String premiumId = 'rafiq_premium_lifetime';
  static const String monthlyId = 'rafiq_monthly';

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _sub;
  static List<ProductDetails> _products = [];
  static bool _isPremium = false;

  static bool get isPremium => _isPremium;
  static List<ProductDetails> get products => _products;

  static Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    const ids = <String>{premiumId, monthlyId};
    final response = await _iap.queryProductDetails(ids);
    _products = response.productDetails;

    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate);
    await _iap.restorePurchases();
  }

  static void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        if (p.productID == premiumId) _isPremium = true;
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
  }
}
