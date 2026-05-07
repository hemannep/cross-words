import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_unit_ids.dart';

class RewardedAdHelper {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  static Future<void> loadRewardedAd() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;
    try {
      await RewardedAd.load(
        adUnitId: AdUnitIds.rewardedAdId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (err) {
            debugPrint('Failed to load rewarded ad: ${err.message}');
            _isLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      _isLoading = false;
    }
  }

  static Future<bool> showRewardedAd({required Function onRewardEarned}) async {
    if (_rewardedAd != null) {
      try {
        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _rewardedAd = null;
            loadRewardedAd();
          },
          onAdFailedToShowFullScreenContent: (ad, err) {
            ad.dispose();
            _rewardedAd = null;
            loadRewardedAd();
          },
        );
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            onRewardEarned();
          },
        );
        return true;
      } catch (e) {
        _rewardedAd?.dispose();
        _rewardedAd = null;
        return false;
      }
    } else {
      return false;
    }
  }

  static bool isRewardedAdReady() => _rewardedAd != null;

  static void disposeAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
