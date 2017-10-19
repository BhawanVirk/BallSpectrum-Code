//
//  BVAds.m
//  BallSpectrum
//
//  Created by Bhawan Virk on 1/29/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import "BVAds.h"
#import "SDiPhoneVersion.h"
#import "Reachability.h"

static BOOL interstitialAdPresented;
static int interstitialAdNotPresentedCount;

@implementation BVAds
{
    Reachability *_internetReachability;
    Reachability *_wifiReachability;
    BOOL _reachabilityOn;
}

@synthesize bannerViewAd = _bannerViewAd;
@synthesize interstitialAd = _interstitialAd;

- (instancetype)initWithReachability:(BOOL)reachabilityOn
{
    self = [super init];
    
    if (self) {
        _reachabilityOn = reachabilityOn;
        
        // load interstitial ad
        [self createAndLoadInterstitialAd];
        
        if (reachabilityOn) {
            [self setupReachability];
        }
    }
    
    return self;
}

- (void)dealloc
{
    if (_reachabilityOn) {
        [_internetReachability stopNotifier];
        [_wifiReachability stopNotifier];
    }
}

#pragma mark - Reachability

- (void)setupReachability
{
    NSLog(@"setting up reachability");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    _internetReachability = [Reachability reachabilityForInternetConnection];
    _wifiReachability = [Reachability reachabilityForLocalWiFi];
    
    [_internetReachability startNotifier];
    [_wifiReachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = [notification object];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    if ((reachability == _internetReachability && networkStatus == ReachableViaWWAN) ||
        (reachability == _wifiReachability && networkStatus == ReachableViaWiFi)) {
        // load banner ad
        [self loadBannerAd];
        // load interestitial ad
        [self createAndLoadInterstitialAd];
        NSLog(@"Reachability Changed");
    }
}

#pragma mark - Create or Load Ads

- (void)createBannerAdForRootViewController:(UIViewController *)bannerRootViewController
{
    DeviceSize deviceSize = [SDiPhoneVersion deviceSize];
    GADAdSize adSize = (deviceSize == UnknowniPad) ? kGADAdSizeLeaderboard : kGADAdSizeBanner;
    
    self.bannerViewAd = [[GADBannerView alloc] initWithAdSize:adSize];
    self.bannerViewAd.rootViewController = bannerRootViewController;
    self.bannerViewAd.adUnitID = @"xxxxxxxxxxxxxxxxxx";
    self.bannerViewAd.delegate = self;
    self.bannerViewAd.alpha = 0.0;
}

- (void)loadBannerAd
{
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"xxxxxxxxxxxxxxxxxx", @"xxxxxxxxxxxxxxxxxx", @"xxxxxxxxxxxxxxxxxx", kGADSimulatorID ];
    [self.bannerViewAd loadRequest:request];
}

- (void)createAndLoadInterstitialAd
{
    _interstitialAd = [[GADInterstitial alloc] initWithAdUnitID:@"xxxxxxxxxxxxxxxxxx"];
    _interstitialAd.delegate = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ @"xxxxxxxxxxxxxxxxxx", @"xxxxxxxxxxxxxxxxxx", @"xxxxxxxxxxxxxxxxxx", kGADSimulatorID ];
    [_interstitialAd loadRequest:request];
}

#pragma mark - Prepare Banner Ad

- (void)prepareBannerAdWithRootVC:(UIViewController *)bannerRootViewController
{
    if (!self.bannerViewAd) {
        [self createBannerAdForRootViewController:bannerRootViewController];
    }
    
    [self loadBannerAd];
}

#pragma mark - Present Interstitial Ad

- (void)presentInterstitialAdFromRootVC:(UIViewController *)rVC
{
    if (interstitialAdNotPresentedCount < _noInterstitialAdForThisManyTimes) {
        // now we'll present no ad until this number _noInterstitialAdForThisManyTimes is achieved
        interstitialAdNotPresentedCount++;
    }
    else if (interstitialAdNotPresentedCount >= _noInterstitialAdForThisManyTimes) {
        // reset the counter
        interstitialAdNotPresentedCount = 0;
        
        // present the ad
        if (self.interstitialAd.isReady) {
            [self.interstitialAd presentFromRootViewController:rVC];
            
            if (_levelNode) {
                // notify _levelNode that we're presenting interstitial ad
                _levelNode.interstitialAdPresented = YES;
            }
        }
    }
}

#pragma mark - GADBannerViewDelegate Methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"received ad");
    
    [UIView animateWithDuration:0.5 animations:^{
        self.bannerViewAd.alpha = 1.0;
    }];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    NSLog(@"now present pause menu");
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    NSLog(@"ad screen got dismissed");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    NSLog(@"now present pause menu (because user leaving the app)");
}

#pragma mark - GADInterstitialDelegate Methods

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    NSLog(@"interstitial received");
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"interstitial ad error");
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    NSLog(@"interstitial dismissed");
    [self createAndLoadInterstitialAd];
    
    if (_levelNode.interstitialAdPresented) {
        _levelNode.interstitialAdPresented = NO;
        [_levelNode restartLevel];
    }
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    NSLog(@"now present pause menu");
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    NSLog(@"now present pause menu (because user leaving the app cause of interstitial ad)");
}

@end
