//
//  LevelsViewController.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 11/18/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"

@interface LevelsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) IBOutlet UICountingLabel *totalCoinsUserHave;

@end
