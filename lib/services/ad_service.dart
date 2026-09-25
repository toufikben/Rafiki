import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/release_config.dart';

class AdService {
  static const String _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static InterstitialAd? _interstitial;
  static bool _isPremium = false;
  static int _feedCount = 0;

  static bool get isPremium => _isPremium;

  static void setPremium(bool value) {
    _isPremium = value;
    if (value) {
      _interstitial?.dispose();
      _interstitial = null;
    }
  }

  static void loadInterstitial() {
    if (_isPremium || (!ReleaseConfig.adsConfigured && !ReleaseConfig.allowTestAds)) {
      return;
    }
    final adUnitId = ReleaseConfig.adsConfigured
        ? ReleaseConfig.adUnitId
        : _testAndroidInterstitial;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  static void showIfReady({VoidCallback? onComplete}) {
    _feedCount++;
    if (_isPremium || _feedCount % 5 != 0) {
      onComplete?.call();
      return;
    }
    if (_interstitial == null) {
      loadInterstitial();
      onComplete?.call();
      return;
    }
    _interstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        loadInterstitial();
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        onComplete?.call();
      },
    );
    _interstitial!.show();
  }
}
