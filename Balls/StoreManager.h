/*
 
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See StoreObserver.m for this sample’s licensing information
 
 Abstract:
 Retrieves product information from the App Store using SKRequestDelegate,
         SKProductsRequestDelegate,SKProductsResponse, and SKProductsRequest.
         Notifies its observer with a list of products available for sale along with
         a list of invalid product identifiers. Logs an error message if the product 
         request failed.
 
*/

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

// Provide notification about the product request
extern NSString * const IAPProductRequestNotification;

typedef NS_ENUM(NSUInteger, StoreManagerFetchProductType) {
    StoreManagerFetchProductTypeCoins,
    StoreManagerFetchProductTypeRemoveAds
};

@interface StoreManager : NSObject

typedef NS_ENUM(NSInteger, IAPProductRequestStatus)
{
    IAPProductsFound,// Indicates that there are some valid products
    IAPIdentifiersNotFound, // indicates that are some invalid product identifiers
    IAPProductRequestResponse, // Returns valid products and invalid product identifiers
    IAPRequestFailed // Indicates that the product request failed
};

// Provide the status of the product request
@property (nonatomic) IAPProductRequestStatus status;

// Keep track of all valid products. These products are available for sale in the App Store
@property (nonatomic, strong) NSMutableArray *availableCoinsProducts;
@property (nonatomic, strong) NSMutableArray *availableNoAdsProducts;

// Keep track of all invalid product identifiers
@property (nonatomic, strong) NSMutableArray *invalidProductIds;

// Indicates the cause of the product request failure
@property (nonatomic, copy) NSString *errorMessage;

+ (StoreManager *)sharedInstance;

// Query the App Store about the given product identifiers
-(void)fetchProductInformationForIds:(NSArray *)productIds productType:(StoreManagerFetchProductType)productType;

// Return the product's title matching a given product identifier
-(NSString *)titleMatchingProductIdentifier:(NSString *)identifier productType:(StoreManagerFetchProductType)productType;

@end
