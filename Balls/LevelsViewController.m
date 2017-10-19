//
//  LevelsViewController.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/18/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "LevelsViewController.h"
#import "BVLevelsData.h"
#import "BVSize.h"
#import "BVLabelNode.h"
#import "PlayLevelViewController.h"
#import "PlaygroundViewController.h"
#import "BVColor.h"
#import "BVGameData.h"
#import "KLCPopup.h"
#import "BVButton.h"
#import "UIImage+Scaling.h"
#import "BVUtility.h"
#import "BVInAppPurchaseDialog.h"
#import "BVDialogBox.h"
#import <Google/Analytics.h>

@implementation LevelsViewController
{
//    UIView *_moreIndicatorView;
    CGSize _collectionViewSectionFooterSize;
    CGSize _cellSize;
    UIImage *_starAchievedIcon;
    UIImage *_starNotAchievedIcon;
    KLCPopup *_levelUnlockDialog;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize viewSize = self.view.frame.size;
    _collectionViewSectionFooterSize = [BVSize sizeOniPhones:CGSizeMake(viewSize.width, 40) andiPads:CGSizeMake(viewSize.width, 80)];
    _cellSize = [BVSize sizeOniPhones:CGSizeMake(75, 75) andiPads:CGSizeMake(120, 120)];
    _starAchievedIcon = [UIImage imageNamed:@"level-star-achieved-icon"];
    _starNotAchievedIcon = [UIImage imageNamed:@"level-star-empty-icon"];
    
    self.view.backgroundColor = [BVColor r:137 g:226 b:255];
//    _collectionView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    flowLayout.minimumInteritemSpacing = [BVSize valueOniPhones:25 andiPads:100];
    flowLayout.minimumLineSpacing = [BVSize valueOniPhones:30 andiPads:80];
    
    // add trees background
    UIImage *trees = [UIImage imageNamed:@"grass"];
    CGSize treeSize = [BVSize resizeUniversally:CGSizeMake(375, 150) firstTime:YES];
    UIImageView *treesView = [[UIImageView alloc] initWithImage:trees];
    treesView.frame = CGRectMake(0, viewSize.height - treeSize.height, viewSize.width, treeSize.height);
    [self.view insertSubview:treesView belowSubview:_collectionView];
    
//    // add more indicator at the bottom
//    float indicatorViewHeight = [BVSize valueOniPhones:25 andiPads:50];
//    _moreIndicatorView = [[UIView alloc] init];
//    _moreIndicatorView.backgroundColor = [BVColor r:255 g:255 b:255 alpha:0.6];
//    _moreIndicatorView.frame = CGRectMake(0, viewSize.height - indicatorViewHeight, viewSize.width, indicatorViewHeight);
//    [self.view addSubview:_moreIndicatorView];
//    
//    UIImage *moreIndicatorImg = [UIImage imageNamed:@"down-arrow-gray"];
//    CGSize moreIndicatorSize = moreIndicatorImg.size;// [BVSize resizeUniversally:CGSizeMake(35, 15) firstTime:YES];
//    
//    UIImageView *moreIndicator = [[UIImageView alloc] initWithImage:moreIndicatorImg];
//    moreIndicator.frame = CGRectMake((viewSize.width/2), _moreIndicatorView.frame.size.height/2, moreIndicatorSize.width, moreIndicatorSize.height);
//    CGPoint indicatorO = moreIndicator.frame.origin;
//    moreIndicator.frame = CGRectMake(indicatorO.x - moreIndicatorSize.width/2, indicatorO.y - moreIndicatorSize.height/2, moreIndicatorSize.width, moreIndicatorSize.height);
//    [_moreIndicatorView addSubview:moreIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_collectionView reloadData];
    
    // update coins label
    [self updateCoinsLabel];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Level Select Page"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (IBAction)goToHome:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Collection View

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int levelId = ((int)indexPath.row + 1);
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BVLevel" forIndexPath:indexPath];
//    cell.contentView.backgroundColor = [BVColor r:0 g:84 b:184 alpha:0.9];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    CGSize cellSize = cell.frame.size;
    float cellW = cellSize.width;
    float cellH = cellSize.height;
    
    // first remove any previously added label if any
    if (cell.contentView.subviews.count) {
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
//        [cell.contentView.subviews[0] removeFromSuperview];
    }
    
    // add cell background
    UIImageView *cellBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"level-cell"]];
    cellBack.frame = CGRectMake(0, 0, _cellSize.width, _cellSize.height);
    [cell.contentView addSubview:cellBack];
    
    // check if level locked or not
    NSDictionary *levelData = [[BVGameData sharedGameData] dataForLevel:levelId];
    int starsEarned = [[levelData objectForKey:@"starsEarned"] intValue];
    BOOL locked = [[levelData objectForKey:@"locked"] boolValue];
    
    if (!locked && levelData != nil) {
        //    UILabel *levelNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (cellW * 0.85), (cellH * 0.75))];
        UILabel *levelNum = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellW, cellH)];
        //    levelNum.center = cell.contentView.center;
        levelNum.textAlignment = NSTextAlignmentCenter;
        levelNum.numberOfLines = 0;
        levelNum.text = [NSString stringWithFormat:@"%i", levelId];
        levelNum.font = [UIFont fontWithName:BVdefaultFontName() size:[BVSize valueOniPhones:24 andiPads:30]];
        levelNum.textColor = [UIColor whiteColor];
        levelNum.shadowColor = [BVColor r:0 g:32 b:49];
        levelNum.shadowOffset = CGSizeMake(2, 2);
        levelNum.frame = CGRectMake(levelNum.frame.origin.x, -levelNum.frame.size.height*0.1, levelNum.frame.size.width, levelNum.frame.size.height);
        [cell.contentView addSubview:levelNum];
        
        
        UIImageView *addedStar = nil;
        CGSize starSize = [BVSize sizeOniPhones:_starAchievedIcon.size andiPads:CGSizeMake(_starAchievedIcon.size.width*1.5, _starAchievedIcon.size.height*1.5)];// [BVSize resizeUniversally:CGSizeMake(15, 14) firstTime:YES];
        CGSize starsViewSize = CGSizeMake(cellSize.width * 0.9, starSize.height * 1.1);
        float starMargin = [BVSize valueOniPhones:5 andiPads:10];
        float starY = cellH - (starSize.height * 2);
        
        UIView *starsView = [[UIView alloc] initWithFrame:CGRectMake((cellSize.width - starsViewSize.width)/2, starY, starsViewSize.width, starsViewSize.height)];
        starsView.backgroundColor = [BVColor r:69 g:117 b:135];
        starsView.layer.cornerRadius = 5.0;
        
        // add achieved stars
        for (int i=0; i<starsEarned; i++) {
            UIImageView *star = [[UIImageView alloc] initWithImage:_starAchievedIcon];
            if (!addedStar) {
                star.frame = CGRectMake(starSize.width/2, 0, starSize.width, starSize.height);
            }
            else {
                star.frame = CGRectMake(CGRectGetMaxX(addedStar.frame) + starMargin, 0, starSize.width, starSize.height);
            }
            [starsView addSubview:star];
            
            addedStar = star;
        }
        
        // add empty stars
        for (int i=0; i<(3-starsEarned); i++) {
            UIImageView *emptyStar = [[UIImageView alloc] initWithImage:_starNotAchievedIcon];
            
            if (!addedStar) {
                emptyStar.frame = CGRectMake(starSize.width/2, 0, starSize.width, starSize.height);
            }
            else {
                emptyStar.frame = CGRectMake(CGRectGetMaxX(addedStar.frame) + starMargin, 0, starSize.width, starSize.height);
            }
            [starsView addSubview:emptyStar];
            
            addedStar = emptyStar;
            
        }
        
        [starsView sizeToFit];
        
        [cell.contentView addSubview:starsView];
    }
    else {
        // level is locked
//        CGSize lockSize = [BVSize resizeUniversally:CGSizeMake(42, 45) firstTime:YES];
        
        NSDictionary *prevLevelData = [[BVGameData sharedGameData] dataForLevel:(levelId - 1)];
        BOOL prevLevelLocked = [[prevLevelData objectForKey:@"locked"] boolValue];
        
        UIImage *lock = [UIImage imageNamed:@"lock-dark-icon"];
        CGSize lockSize = lock.size;
        
        if (!prevLevelLocked && prevLevelData != nil) {
            lock = [UIImage imageNamed:@"lock-icon"];
        }
        
        UIImageView *lockView = [[UIImageView alloc] initWithImage:lock];
        lockView.frame = CGRectMake((cellW/2)-lockSize.width/2, (cellH/2)-lockSize.height/2, lockSize.width, lockSize.height);
        [cell.contentView addSubview:lockView];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [BVLevelsData totalLevels];
}

#pragma mark - CollectionView Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int levelNum = ((int)indexPath.row + 1);
//    int groupNum = ((int)indexPath.section + 1);
    CGSize screenSize = [BVSize originalScreenSize];
    
    NSDictionary *levelDefaults = [[BVGameData sharedGameData] dataForLevel:levelNum];
    BOOL locked = [[levelDefaults objectForKey:@"locked"] boolValue];
    
    if (!locked && levelDefaults != nil) {
        [self moveToLevel:levelNum];
    }
    else {
        // gather prev level info
        NSDictionary *prevLevelData = [[BVGameData sharedGameData] dataForLevel:(levelNum - 1)];
        BOOL prevLevelLocked = [[prevLevelData objectForKey:@"locked"] boolValue];
        
        if (!prevLevelLocked && prevLevelData != nil) {
            // gather level data
            NSDictionary *levelData = [BVLevelsData dataForLevel:levelNum];
            NSMutableDictionary *levelDataDict = [levelData objectForKey:@"data"];
            NSNumber *unlockFor = [levelDataDict objectForKey:@"unlockFor"];
            
            float labelSize = [BVSize valueOniPhone4s:16 iPhone5To6sPlus:18 iPad:28];
            CGSize dialogSize = CGSizeMake(screenSize.width * 0.8, screenSize.height * 0.2);
            
            BVDialogBox *dialogBox = [[BVDialogBox alloc] initWithUi:BVDialogBoxUiRedish label:[NSString stringWithFormat:@"Unlock Level %i", levelNum] size:dialogSize withCloseButton:YES];
            
            // create button
            UIImageView *labelBarView = dialogBox.labelBarView;
            CGSize labelBarSize = labelBarView.frame.size;
            float buttonWidth = dialogSize.width * 0.6;
            CGSize buttonSize = [BVSize sizeOniPhones:CGSizeMake(buttonWidth, 40) andiPads:CGSizeMake(buttonWidth, 70)];
            BVButton *unlockLevelButton = [BVButton MoneyButtonWithVal:unlockFor fontSize:labelSize size:buttonSize showCoin:YES coinSize:CGSizeMake(25, 25)];
            unlockLevelButton.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
            unlockLevelButton.center = CGPointMake(dialogBox.center.x, CGRectGetMaxY(labelBarView.frame) + ((CGRectGetHeight(dialogBox.frame) - labelBarSize.height) / 2));
            unlockLevelButton.userData = [NSMutableDictionary dictionaryWithDictionary:@{@"unlockLevel": @(levelNum), @"price": unlockFor}];
            [dialogBox addSubview:unlockLevelButton];
            
            // add target-action to button
            [unlockLevelButton addTarget:self action:@selector(processUnlockLevelRequest:) forControlEvents:UIControlEventTouchUpInside];
            
            _levelUnlockDialog = [KLCPopup popupWithContentView:dialogBox showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
            
            dialogBox.popup = _levelUnlockDialog;
            
            [_levelUnlockDialog show];
            
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Level Locked" message:@"You have to finish previous level or you can use coins to unlock this level" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"Use Coins", nil];
//            [alert show];
        }
        else {
            // this level is locked
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Level Locked" message:@"Please complete previous levels first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
            
            UIView *lockedNoticeView = [[UIView alloc] init];
            lockedNoticeView.frame = CGRectMake(0, 0, screenSize.width * 0.7, screenSize.height * 0.12);
            lockedNoticeView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
            lockedNoticeView.layer.shadowOffset = CGSizeMake(0, 2);
            lockedNoticeView.layer.shadowRadius = 2;
            lockedNoticeView.layer.shadowOpacity = 0.3;
            lockedNoticeView.layer.cornerRadius = 5.0;
            
            CGSize lockedNoticeViewSize = lockedNoticeView.frame.size;
            CGSize textLabelSize = CGSizeMake(lockedNoticeViewSize.width * 0.9, lockedNoticeViewSize.height * 0.9);
            float textLabelX = (lockedNoticeViewSize.width - textLabelSize.width) / 2;
            
            UILabel *textLabel = [[UILabel alloc] init];
            textLabel.frame = CGRectMake(textLabelX, 0, textLabelSize.width, textLabelSize.height);
            textLabel.text = @"Level Locked!";
            textLabel.font = [UIFont fontWithName:BVdefaultFontName() size:20];
            textLabel.textColor = [UIColor blackColor];
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
            textLabel.adjustsFontSizeToFitWidth = YES;
            [lockedNoticeView addSubview:textLabel];
            
//            lockedNoticeView.frame = CGRectMake(0, 0, text.frame.size.width, text.frame.size.height);
            
            KLCPopup *lockedPopup = [KLCPopup popupWithContentView:lockedNoticeView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:YES];
            [lockedPopup showWithDuration:2.0];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return _collectionViewSectionFooterSize;
    }
    
    return CGSizeMake(_collectionViewSectionFooterSize.width, 0);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Button Helpers

- (void)processUnlockLevelRequest:(BVButton *)sender
{
    int levelNum = [[sender.userData objectForKey:@"unlockLevel"] intValue];
    float levelPrice = [[sender.userData objectForKey:@"price"] floatValue];
    float totalCoinsBeforeCharging = [[BVGameData sharedGameData] totalCoins];
    __weak LevelsViewController *weakSelf = self;
    
    if ([[BVGameData sharedGameData] chargeCoinsSuccessfully:levelPrice]) {
        // disable the button
        sender.enabled = NO;
        
        // unlock level forever
        [[BVGameData sharedGameData] saveLevel:(levelNum) data:@{@"passed": @NO,
                                                                 @"pointsEarned": @0,
                                                                 @"starsEarned": @0,
                                                                 @"locked": @NO}];
        
        // reload cell's data
        [_collectionView reloadData];
        
        // update coins label
        float countTo = (float)totalCoinsBeforeCharging - levelPrice;
        [self.totalCoinsUserHave countFrom:totalCoinsBeforeCharging to:countTo withDuration:0.3];
        
        // attach block that will run when dialog completely disappears.
        _levelUnlockDialog.didFinishDismissingCompletion = ^(){
            // move to level
            [weakSelf moveToLevel:levelNum];
        };
        
        // remove the popup
        [_levelUnlockDialog dismiss:YES];
    }
    else {
        // user don't have sufficient funds
        // move the content of dialog out
        [UIView animateWithDuration:0.2 animations:^{
            
            UIView *dialogLabel = ((UIView *)_levelUnlockDialog.contentView.subviews[0]).subviews[0];
            UIView *purchaseButton = _levelUnlockDialog.contentView.subviews[1];
            
            [dialogLabel setAlpha:0];
            [purchaseButton setAlpha:0];
            
            
        } completion:^(BOOL finished) {
            
            float labelSize = [BVSize valueOniPhone4s:16 iPhone5To6sPlus:18 iPad:28];
            
            NSNumberFormatter *currencyStyle = [BVUtility currencyStyleFormatter];
            NSNumber *levelPriceNum = [NSNumber numberWithFloat:[[BVGameData sharedGameData] missingCoins:levelPrice]];
            
            UIView *labelBarView = _levelUnlockDialog.contentView.subviews[0];
            
            CGSize coinImgSize = [BVSize sizeOniPhone4s:CGSizeMake(16, 16) iPhone5To6sPlus:CGSizeMake(18, 18) iPad:CGSizeMake(28, 28)];
            
            // create a label here
            UILabel *errorLabel = [[UILabel alloc] init];
            errorLabel.font = [UIFont fontWithName:BVdefaultFontName() size:labelSize];
            errorLabel.textColor = [UIColor whiteColor];
            errorLabel.shadowColor = [BVColor r:102 g:52 b:0];
            errorLabel.shadowOffset = CGSizeMake(1, 2);
            errorLabel.text = [NSString stringWithFormat:@"You're Missing: %@", [currencyStyle stringFromNumber:levelPriceNum]];
            [errorLabel sizeToFit];
            errorLabel.center = CGPointMake(_levelUnlockDialog.contentView.center.x - coinImgSize.width/2, CGRectGetMidY(labelBarView.frame));
            errorLabel.alpha = 0;
            [labelBarView addSubview:errorLabel];
            
            // add coin just after the label
            UIImage *coinImg = [[UIImage imageNamed:@"coin-icon"] imageScaledToFitSize:coinImgSize];
            UIImageView *coinView = [[UIImageView alloc] initWithImage:coinImg];
            coinView.frame = CGRectMake(CGRectGetMaxX(errorLabel.frame), CGRectGetMidY(errorLabel.frame) - coinImgSize.height/2, coinImgSize.width, coinImgSize.height);
            [labelBarView addSubview:coinView];
            
            
            // create button
            float buttonWidth = _levelUnlockDialog.frame.size.width * 0.6;
            CGSize buttonSize = [BVSize sizeOniPhones:CGSizeMake(buttonWidth, 40) andiPads:CGSizeMake(buttonWidth, 70)];
            BVButton *goToStoreButton = [BVButton BluishButtonWithText:@"Buy Missing Coins" fontSize:labelSize size:buttonSize];
            goToStoreButton.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
            goToStoreButton.center = CGPointMake(CGRectGetMidX(labelBarView.frame), CGRectGetMaxY(labelBarView.frame) + ((CGRectGetHeight(_levelUnlockDialog.contentView.frame) - CGRectGetHeight(labelBarView.frame)) / 2));
            goToStoreButton.alpha = 0;
            [goToStoreButton addTarget:weakSelf action:@selector(moveToStore) forControlEvents:UIControlEventTouchUpInside];
            [_levelUnlockDialog.contentView addSubview:goToStoreButton];
            
            // OR label
            UILabel *orLabel = [[UILabel alloc] init];
            orLabel.text = @"or";
            orLabel.textColor = [UIColor blackColor];
            orLabel.font = [UIFont fontWithName:BVdefaultFontName() size:[BVSize valueOniPhones:18 andiPads:22]];
            [orLabel sizeToFit];
            orLabel.center = CGPointMake(_levelUnlockDialog.contentView.center.x, CGRectGetMaxY(goToStoreButton.frame) + orLabel.frame.size.height/1.3);
            [_levelUnlockDialog.contentView addSubview:orLabel];
            
            // playground button
            BVButton *playgroundButton = [BVButton GreenButtonWithText:@"Play & Earn" fontSize:labelSize size:buttonSize];
            playgroundButton.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
            playgroundButton.center = CGPointMake(_levelUnlockDialog.contentView.center.x, CGRectGetMaxY(orLabel.frame) + buttonSize.height/1.3);
            playgroundButton.alpha = 0;
            [playgroundButton addTarget:weakSelf action:@selector(moveToPlayground) forControlEvents:UIControlEventTouchUpInside];
            [_levelUnlockDialog.contentView addSubview:playgroundButton];
            
            // calculate bottom padding
            float bottomPadding = CGRectGetMinY(goToStoreButton.frame) - CGRectGetMaxY(labelBarView.frame);
            
            [UIView animateWithDuration:0.2 animations:^{
                
                // remove constraints from unlockDialogs' superview
                [_levelUnlockDialog.contentView.superview removeConstraints:_levelUnlockDialog.contentView.superview.constraints];
                
                CGSize contentViewArea = [BVUtility calculateViewArea:_levelUnlockDialog.contentView];
                CGPoint dialogViewOrigin = _levelUnlockDialog.contentView.frame.origin;
                CGSize dialogViewSize = _levelUnlockDialog.contentView.frame.size;
                float newContentViewHeight = contentViewArea.height + bottomPadding;
                
                // dialog's super view props
                UIView *dialogSuperView = _levelUnlockDialog.contentView.superview;
                CGPoint dialogSuperViewOrigin = dialogSuperView.frame.origin;
                CGSize dialogSuperViewSize = dialogSuperView.frame.size;
                
                // super view will update it's height and y-pos
                [_levelUnlockDialog.contentView.superview setFrame:CGRectMake(dialogSuperViewOrigin.x, dialogSuperViewOrigin.y - ((newContentViewHeight - dialogSuperViewSize.height)/2), dialogViewSize.width, newContentViewHeight)];
                // conent view will update it's height only
                [_levelUnlockDialog.contentView setFrame:CGRectMake(dialogViewOrigin.x, dialogViewOrigin.y, dialogViewSize.width, newContentViewHeight)];
                
            } completion:^(BOOL finished) {
                errorLabel.alpha = 1.0;
                goToStoreButton.alpha = 1.0;
                playgroundButton.alpha = 1.0;
            }];
        }];
    }
}

#pragma mark - Utility Methods

- (void)moveToLevel:(int)levelNum
{
    PlayLevelViewController *playLevelViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayLevelViewController"];
    playLevelViewController.levelNum = levelNum;
    playLevelViewController.presentingFromHomePage = NO;
    
    [self.navigationController pushViewController:playLevelViewController animated:YES];
}

- (void)moveToStore
{
    __weak LevelsViewController *weakSelf = self;
    int totalCoinsUserHaveBeforePurchase = [[BVGameData sharedGameData] totalCoins];
    _levelUnlockDialog.didFinishDismissingCompletion = ^() {
        BVInAppPurchaseDialog *coinsStoreDialog = [[BVInAppPurchaseDialog alloc] initWithPurchaseType:BVInAppPurchaseTypeCoins];
        
        KLCPopup *popup = [KLCPopup popupWithContentView:coinsStoreDialog showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
        coinsStoreDialog.popup = popup;
        [popup show];
        popup.didFinishDismissingCompletion = ^{
            
//            NSLog(@"poped out coins purchase dialog box!");
            // if total coins change, then animate the coins label
            if ([[BVGameData sharedGameData] totalCoins] != totalCoinsUserHaveBeforePurchase) {
                [weakSelf.totalCoinsUserHave countFrom:totalCoinsUserHaveBeforePurchase to:[[BVGameData sharedGameData] totalCoins] withDuration:0.3];
            }
        };
    };
    
    // remove the popup
    [_levelUnlockDialog dismiss:YES];
}

- (void)moveToPlayground
{
    __weak LevelsViewController *weakSelf = self;
    // attach block that will run when dialog completely disappears.
    _levelUnlockDialog.didFinishDismissingCompletion = ^(){
        // move to level
        PlaygroundViewController *playgroundViewController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"PlaygroundViewController"];
        [weakSelf.navigationController pushViewController:playgroundViewController animated:YES];
    };
    
    // remove the popup
    [_levelUnlockDialog dismiss:YES];
}

/**
 This method doesn't set coins, but instead update the text of the coins label
 */
- (void)updateCoinsLabel
{
    NSNumberFormatter *currencyStyle = [BVUtility currencyStyleFormatter];
    NSNumber *totalCoins = [NSNumber numberWithInteger:[[BVGameData sharedGameData] totalCoins]];
    self.totalCoinsUserHave.text = [NSString stringWithFormat:@"%@", [currencyStyle stringFromNumber:totalCoins]];
    self.totalCoinsUserHave.method = UILabelCountingMethodEaseInOut;
    self.totalCoinsUserHave.formatBlock = ^NSString *(CGFloat value) {
        NSNumberFormatter *currencyStyle = [BVUtility currencyStyleFormatter];
        NSNumber *totalCoins = [NSNumber numberWithFloat:value];
        return [currencyStyle stringFromNumber:totalCoins];
    };
}

//#pragma mark - Scroll View Delegate
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    float scrollViewContentH = scrollView.contentSize.height;
//    float bottomPoint = scrollViewContentH - _collectionView.frame.size.height;
//
//    if (scrollView.contentOffset.y >= (bottomPoint - (_collectionViewSectionFooterSize.height))) {
//        [UIView animateWithDuration:0.2 animations:^{
//            _moreIndicatorView.alpha = 0;
//        }];
//    }
//    else {
//        if (_moreIndicatorView.alpha < 0.1) {
//            [UIView animateWithDuration:0.2 animations:^{
//                _moreIndicatorView.alpha = 1;
//            }];
//        }
//    }
//}
@end
