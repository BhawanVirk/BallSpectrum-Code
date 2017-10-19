//
//  BVInAppPurchaseDialog.h
//  BallSpectrum
//
//  Created by Bhawan Virk on 1/16/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "KLCPopup.h"

typedef NS_ENUM(NSUInteger, BVInAppPurchaseType) {
    BVInAppPurchaseTypeCoins,
    BVInAppPurchaseTypeAds
};

@interface BVInAppPurchaseDialog : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) KLCPopup *popup; // only provided by external class. it works with close button in content view

- (instancetype)initWithPurchaseType:(BVInAppPurchaseType)purchaseType;

@end
