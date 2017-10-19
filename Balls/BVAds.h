//
//  BVAds.h
//  BallSpectrum
//
//  Created by Bhawan Virk on 1/29/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BVLevel.h"
#import "BVPlayground.h"

@import GoogleMobileAds;

@interface BVAds : NSObject <GADBannerViewDelegate, GADInterstitialDelegate>

// ads
@property (nonatomic, strong) GADBannerView *bannerViewAd;
@property (nonatomic, strong) GADInterstitial *interstitialAd;

/**
 Present interstitial ad and then don't present it this many times
 */
@property (nonatomic, assign) int noInterstitialAdForThisManyTimes;

// game scenes
@property (nonatomic, weak) BVLevel *levelNode; // only assigned by BVLevel
@property (nonatomic, weak) BVPlayground *playgroundScene; // only assigned by BVPlayground

#pragma mark - Initializer Method
- (instancetype)initWithReachability:(BOOL)reachabilityOn;

#pragma mark - Prepare Banner Ad
/**
 This method must be called before accessing bannerViewAd
 */
- (void)prepareBannerAdWithRootVC:(UIViewController *)bannerRootViewController;

#pragma mark - Present Interstitial Ad
- (void)presentInterstitialAdFromRootVC:(UIViewController *)rVC;
@end
