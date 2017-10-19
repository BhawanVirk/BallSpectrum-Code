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


#import "StoreManager.h"

NSString * const IAPProductRequestNotification = @"IAPProductRequestNotification";

@interface StoreManager()<SKRequestDelegate, SKProductsRequestDelegate>
@end


@implementation StoreManager
{
    StoreManagerFetchProductType _fetchingProductType;
}

+ (StoreManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static StoreManager * storeManagerSharedInstance;
    
    dispatch_once(&onceToken, ^{
        storeManagerSharedInstance = [[StoreManager alloc] init];
    });
    return storeManagerSharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _availableCoinsProducts = [[NSMutableArray alloc] initWithCapacity:0];
        _availableNoAdsProducts = [[NSMutableArray alloc] initWithCapacity:0];
        _invalidProductIds = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}


#pragma mark Request information

// Fetch information about your products from the App Store
-(void)fetchProductInformationForIds:(NSArray *)productIds productType:(StoreManagerFetchProductType)productType
{
    _fetchingProductType = productType;
    // Create a product request object and initialize it with our product identifiers
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    request.delegate = self;
    
    // Send the request to the App Store
    [request start];
}


#pragma mark - SKProductsRequestDelegate

// Used to get the App Store's response to your request and notifies your observer
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // The products array contains products whose identifiers have been recognized by the App Store.
    // As such, they can be purchased. Create an "AVAILABLE PRODUCTS" model object.
    if ((response.products).count > 0)
    {
        // sort products from lower to higher price
        NSArray *products = [response.products sortedArrayUsingComparator:^(id a, id b) {
            NSDecimalNumber *first = [(SKProduct*)a price];
            NSDecimalNumber *second = [(SKProduct*)b price];
            return [first compare:second];
        }];
        if (_fetchingProductType == StoreManagerFetchProductTypeCoins) {
            self.availableCoinsProducts = [NSMutableArray arrayWithArray:products];
        }
        else if (_fetchingProductType == StoreManagerFetchProductTypeRemoveAds) {
            self.availableNoAdsProducts = [NSMutableArray arrayWithArray:products];
        }
    }
    
//    // The invalidProductIdentifiers array contains all product identifiers not recognized by the App Store.
//    if ((response.invalidProductIdentifiers).count > 0)
//    {
//        // invalid products
//    }
    
    self.status = IAPProductRequestResponse;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPProductRequestNotification object:self];
}


#pragma mark SKRequestDelegate method

// Called when the product request failed.
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self.status = IAPRequestFailed;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPProductRequestNotification object:self];
    // Prints the cause of the product request failure
    NSLog(@"Product Request Status: %@",error.localizedDescription);
}


#pragma mark Helper method

// Return the product's title matching a given product identifier
-(NSString *)titleMatchingProductIdentifier:(NSString *)identifier productType:(StoreManagerFetchProductType)productType
{
    NSMutableArray *availableProducts = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (productType == StoreManagerFetchProductTypeCoins) {
        availableProducts = self.availableCoinsProducts;
    }
    else if (productType == StoreManagerFetchProductTypeRemoveAds) {
        availableProducts = self.availableNoAdsProducts;
    }
    
    NSString *productTitle = nil;
    // Iterate through availableProducts to find the product whose productIdentifier
    // property matches identifier, return its localized title when found
    for (SKProduct *product in availableProducts)
    {
        if ([product.productIdentifier isEqualToString:identifier])
        {
            productTitle = product.localizedTitle;
        }
    }
    return productTitle;
}

@end
