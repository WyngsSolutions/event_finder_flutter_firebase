import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController {

  //Singleton pattern
  static final AdsController _singleton = AdsController._internal();

  factory AdsController() {
    return _singleton;
  }

  AdsController._internal();

  Future<void> init() async {
    createInterstitialAd();
  }

  //ADS
  String testDevice = '37CAB2590F5CCF7D0D0C7C822404A8EE';
  int maxFailedLoadAttempts = 3;
  static final AdRequest request = AdRequest(
    //keywords: <String>['foo', 'bar'],
    //contentUrl: 'http://foo.com/bar.html',
    //nonPersonalizedAds: true,
  );

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;


  void createInterstitialAd() {
    // InterstitialAd.load(
    // adUnitId: Platform.isAndroid
    //     ? 'ca-app-pub-3940256099942544/1033173712'
    //     : 'ca-app-pub-3940256099942544/4411468910',
    // request: request,
    // adLoadCallback: InterstitialAdLoadCallback(
    //   onAdLoaded: (InterstitialAd ad) {
    //     print('$ad loaded');
    //     _interstitialAd = ad;
    //     _numInterstitialLoadAttempts = 0;
    //     _interstitialAd!.setImmersiveMode(true);
    //   },
    //   onAdFailedToLoad: (LoadAdError error) {
    //     print('InterstitialAd failed to load: $error.');
    //     _numInterstitialLoadAttempts += 1;
    //     _interstitialAd = null;
    //     if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
    //       createInterstitialAd();
    //     }
    //   },
    // ));
  }

  void showInterstitialAd() {
    // if (_interstitialAd == null) {
    //   print('Warning: attempt to show interstitial before loaded.');
    //   return;
    // }
    // _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
    //   onAdShowedFullScreenContent: (InterstitialAd ad) =>
    //       print('ad onAdShowedFullScreenContent.'),
    //   onAdDismissedFullScreenContent: (InterstitialAd ad) {
    //     print('$ad onAdDismissedFullScreenContent.');
    //     ad.dispose();
    //     createInterstitialAd();
    //   },
    //   onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
    //     print('$ad onAdFailedToShowFullScreenContent: $error');
    //     ad.dispose();
    //     createInterstitialAd();
    //   },
    // );
    // _interstitialAd!.show();
    // _interstitialAd = null;
  }
}