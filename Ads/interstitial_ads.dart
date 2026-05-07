import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

class InterstitialAdHelper {
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  static Future<void> loadInterstitialAd() async {
    if (_isLoading || _interstitialAd != null) return;
    _isLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: AdUnitIds.interstitialAdId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isLoading = false;
            debugPrint('Interstitial ad loaded');
          },
          onAdFailedToLoad: (err) {
            debugPrint('Failed to load interstitial ad: ${err.message}');
            _isLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      _isLoading = false;
    }
  }

  static Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      try {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _interstitialAd = null;
            loadInterstitialAd();
          },
          onAdFailedToShowFullScreenContent: (ad, err) {
            ad.dispose();
            _interstitialAd = null;
            loadInterstitialAd();
          },
        );
        await _interstitialAd!.show();
      } catch (e) {
        debugPrint('Error showing interstitial: $e');
        _interstitialAd?.dispose();
        _interstitialAd = null;
      }
    } else {
      loadInterstitialAd();
    }
  }

  static void disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
