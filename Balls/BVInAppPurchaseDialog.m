//
//  BVInAppPurchaseDialog.m
//  BallSpectrum
//
//  Created by Bhawan Virk on 1/16/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import "BVInAppPurchaseDialog.h"
#import "KLCPopup.h"
#import "BVDialogBox.h"
#import "BVLabelNode.h"
#import "BVButton.h"
#import "BVSize.h"
#import "StoreObserver.h"
#import "StoreManager.h"
#import "BVGameData.h"
#import "BVUtility.h"
#import "BVColor.h"

@implementation BVInAppPurchaseDialog
{
    CGSize _screenSize;
    BVButton *_restorePurchasesButton;
    BVDialogBox *_dialogBox;
    BVInAppPurchaseType _purchaseType;
    UILabel *_connectingLabel;
    UITableView *_productsTableView;
    UITableViewCell *_productsTableViewCell;
}

@synthesize popup = _popup;

- (instancetype)initWithPurchaseType:(BVInAppPurchaseType)purchaseType
{
    self = [super init];
    
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleProductRequestNotification:)
                                                     name:IAPProductRequestNotification
                                                   object:[StoreManager sharedInstance]];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handlePurchasesNotification:)
                                                     name:IAPPurchaseNotification
                                                   object:[StoreObserver sharedInstance]];

        
        _screenSize = [BVSize originalScreenSize];
        NSArray *coinProductIds = @[@"xxxxxxxxxxxxxxxxxx", @"xxxxxxxxxxxxxxxxxx", @"xxxxxxxxxxxxxxxxxx"];
        NSArray *adsProductIds = @[@"xxxxxxxxxxxxxxxxxx"];
        _purchaseType = purchaseType;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5.0;
        
        switch (purchaseType) {
            case BVInAppPurchaseTypeAds:
                [self showRemoveAdsPopup];
                break;
                
            case BVInAppPurchaseTypeCoins:
                [self showCoinsStorePopup];
                break;
                
            default:
                break;
        }
        
        // setup products tabelview
        float labelBarHeight = CGRectGetHeight(_dialogBox.labelBarView.frame) + 10;
        float dialogBorderWidth = _dialogBox.layer.borderWidth;
        _productsTableView = [[UITableView alloc] initWithFrame:CGRectMake(dialogBorderWidth, labelBarHeight, self.frame.size.width - (dialogBorderWidth * 2), _dialogBox.frame.size.height - labelBarHeight)];
        _productsTableView.delegate = self;
        _productsTableView.dataSource = self;
        _productsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // this removes empty cells
        [self addSubview:_productsTableView];
        
        // hide the product table view by default and only display it when there are products to show
        _productsTableView.alpha = 0.0;
        
        if (_purchaseType == BVInAppPurchaseTypeCoins) {
            if ([[StoreManager sharedInstance] availableCoinsProducts].count > 0) {
                // display them products
                [self presentCoinPackages];
            }
            else {
                [self displayLoadingLabelIfNotPresented];
                // no products in array? go fetch them.
                [[StoreManager sharedInstance] fetchProductInformationForIds:coinProductIds productType:StoreManagerFetchProductTypeCoins];
            }
        }
        else if (_purchaseType == BVInAppPurchaseTypeAds) {
            if ([[StoreManager sharedInstance] availableNoAdsProducts].count > 0) {
                // display them products
                [self presentRemoveAdsPackage];
            }
            else {
                [self displayLoadingLabelIfNotPresented];
                // no products in array? go fetch them.
                [[StoreManager sharedInstance] fetchProductInformationForIds:adsProductIds productType:StoreManagerFetchProductTypeRemoveAds];
            }
        }
        
        // add restore purchases button
        float labelSize = [BVSize valueOniPhone4s:16 iPhone5To6sPlus:18 iPad:28];
        float buttonWidth = [BVSize originalScreenSize].width * 0.6;
        CGSize buttonSize = [BVSize sizeOniPhones:CGSizeMake(buttonWidth, 40) andiPads:CGSizeMake(buttonWidth, 70)];
        _restorePurchasesButton = [BVButton GreenButtonWithText:@"Restore Purchases" fontSize:labelSize size:buttonSize];
        _restorePurchasesButton.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - buttonSize.height);
        [_restorePurchasesButton addTarget:self action:@selector(restoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_restorePurchasesButton];
    }
    
    return self;
}

- (void)showCoinsStorePopup
{
    self.frame = CGRectMake(0, 0, _screenSize.width * 0.9, _screenSize.height * 0.7);
    _dialogBox = [[BVDialogBox alloc] initWithUi:BVDialogBoxUiRedish label:@"Buy Coins" size:self.frame.size withCloseButton:YES];
    _dialogBox.contentBackgroundColor = [UIColor whiteColor];
    [self addSubview:_dialogBox];
}

- (void)showRemoveAdsPopup
{
    self.frame = CGRectMake(0, 0, _screenSize.width * 0.9, _screenSize.height * 0.5);
    _dialogBox = [[BVDialogBox alloc] initWithUi:BVDialogBoxUiRedish label:@"Want to remove ads?" size:self.frame.size withCloseButton:YES];
    _dialogBox.contentBackgroundColor = [UIColor whiteColor];
    [self addSubview:_dialogBox];
}

#pragma mark - Notification Handlers

- (void)handleProductRequestNotification:(NSNotification *)notification
{
    StoreManager *storeManager = (StoreManager *)notification.object;

    if (storeManager.status == IAPRequestFailed) {
        // update loading label text with connection error
        _connectingLabel.text = @"Can't connect to store. Please check your internet connection.";
        _connectingLabel.frame =  CGRectMake(0, 0, self.frame.size.width * 0.9, 0);
        [_connectingLabel sizeToFit];
        _connectingLabel.center = self.center;
    }
    else {
        // remove connecting label
        [_connectingLabel removeFromSuperview];
        
        if (_purchaseType == BVInAppPurchaseTypeCoins) {
            [self presentCoinPackages];
        }
        else if (_purchaseType == BVInAppPurchaseTypeAds) {
            [self presentRemoveAdsPackage];
        }
    }
}

- (void)handlePurchasesNotification:(NSNotification *)notification
{
    StoreObserver *purchasesNotification = (StoreObserver *)notification.object;
    IAPPurchaseNotificationStatus status = (IAPPurchaseNotificationStatus)purchasesNotification.status;
    
    switch (status)
    {
        case IAPPurchaseFailed:
//            [self alertWithTitle:@"Purchase Status" message:purchasesNotification.message];
            [BVUtility alertWithTitle:@"Purchase Status" message:@"Purchase failed! please try again." size:CGSizeZero];
            break;
            
        case IAPPurchaseSucceeded:
            if (_purchaseType == BVInAppPurchaseTypeCoins) {
//                [self alertWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"You have successfully purchased %@", purchasesNotification.purchasedID]];
                // now is the time to give user what they have payed for
//                [self deliveryProductWithIdentifier:purchasesNotification.purchasedID];
                // purchase successfull with delivery. now close the store dialog
                [_dialogBox.popup dismiss:YES];
            }
            break;
            
            // Switch to the iOSPurchasesList view controller when receiving a successful restore notification
        case IAPRestoredSucceeded:
        {
            [BVUtility alertWithTitle:@"Restore Succeeded" message:@"Successfully restored your purchase :)" size:CGSizeZero];
        }
            break;
        case IAPRestoredFailed:
            [BVUtility alertWithTitle:@"Restore Failed" message:purchasesNotification.message size:CGSizeZero];
            break;
//            // Notify the user that downloading is about to start when receiving a download started notification
//        case IAPDownloadStarted:
//        {
//            self.hasDownloadContent = YES;
//            [self.view addSubview:self.statusMessage];
//        }
//            break;
//            // Display a status message showing the download progress
//        case IAPDownloadInProgress:
//        {
//            self.hasDownloadContent = YES;
//            NSString *title = [[StoreManager sharedInstance] titleMatchingProductIdentifier:purchasesNotification.purchasedID];
//            NSString *displayedTitle = (title.length > 0) ? title : purchasesNotification.purchasedID;
//            self.statusMessage.text = [NSString stringWithFormat:@" Downloading %@   %.2f%%",displayedTitle, purchasesNotification.downloadProgress];
//        }
//            break;
//            // Downloading is done, remove the status message
//        case IAPDownloadSucceeded:
//        {
//            self.hasDownloadContent = NO;
//            self.statusMessage.text = @"Download complete: 100%";
//            
//            // Remove the message after 2 seconds
//            [self performSelector:@selector(hideStatusMessage) withObject:nil afterDelay:2];
//        }
//            break;
        default:
            break;
    }
}
                 
#pragma mark - Content Setup Helper

- (void)presentCoinPackages
{
//    [self alertWithTitle:@"Packages Loaded" message:@"All of the coins packages have been successfully retrieved from the store. Now display them here."];
    // reload products table data
    [_productsTableView reloadData];
    // make it visible
    [UIView animateWithDuration:0.5 animations:^{
       _productsTableView.alpha = 1.0;
    }];
}

- (void)presentRemoveAdsPackage
{
//    [self alertWithTitle:@"Packages Loaded" message:@"Now show remove ads package"];
    // reload products table data
    [_productsTableView reloadData];
    // make it visible
    [UIView animateWithDuration:0.5 animations:^{
        _productsTableView.alpha = 1.0;
    }];
}

#pragma mark - Tabel View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    
    if (_purchaseType == BVInAppPurchaseTypeCoins) {
        rowCount = [[StoreManager sharedInstance] availableCoinsProducts].count;
    }
    else if (_purchaseType == BVInAppPurchaseTypeAds) {
        rowCount = [[StoreManager sharedInstance] availableNoAdsProducts].count;
    }
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *product = nil;
    
    if (_purchaseType == BVInAppPurchaseTypeCoins) {
        product = [[StoreManager sharedInstance] availableCoinsProducts][indexPath.row];
    }
    else if (_purchaseType == BVInAppPurchaseTypeAds) {
        product = [[StoreManager sharedInstance] availableNoAdsProducts][indexPath.row];
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    NSLog(@"product title: %@", product.localizedTitle);
    
    cell.textLabel.font = [UIFont fontWithName:BVdefaultFontName() size:[BVSize valueOniPhones:16 andiPads:22]];
    cell.textLabel.text = product.localizedTitle;
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"buy_%@", product.productIdentifier]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:[BVSize valueOniPhones:14 andiPads:18]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Price: %@", formattedPrice];
    cell.detailTextLabel.textColor = [BVColor grayColor];
    
    return cell;
}

#pragma mark - Tabel View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BVSize valueOniPhones:80 andiPads:100];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // buy this product
    SKProduct *product = nil;
    
    if (_purchaseType == BVInAppPurchaseTypeCoins) {
        product = [[StoreManager sharedInstance] availableCoinsProducts][indexPath.row];
    }
    else if (_purchaseType == BVInAppPurchaseTypeAds) {
        product = [[StoreManager sharedInstance] availableNoAdsProducts][indexPath.row];
    }
    
    [[StoreObserver sharedInstance] buy:product];
}

#pragma mark - Button Handlers

- (void)restoreButtonPressed:(UIButton *)button
{
    [[StoreObserver sharedInstance] restore];
}

#pragma mark - Utility Method

- (void)displayLoadingLabelIfNotPresented
{
    if (!_connectingLabel) {
        _connectingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _connectingLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:[BVSize valueOniPhones:18 andiPads:22]];
        _connectingLabel.text = @"Fetching data...";
        _connectingLabel.textColor = [UIColor blackColor];
        _connectingLabel.numberOfLines = 2;
        _connectingLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_connectingLabel sizeToFit];
        _connectingLabel.center = self.center;
        _connectingLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_connectingLabel];
    }
}

#pragma mark - Getter & Setter
- (void)setPopup:(KLCPopup *)popup
{
    _popup = popup;
    _dialogBox.popup = popup;
}
@end
