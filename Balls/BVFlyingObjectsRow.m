//
//  BVFlyingObjectsRow.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 9/23/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVFlyingObjectsRow.h"
#import "BVSize.h"

@implementation BVFlyingObjectsRow

- (instancetype)initWithScrollingSpeed:(int)scrollingSpeed andDirection:(int)scrollingDirection
{
    self = [super init];
    
    if (self) {
        float rowHeight = [BVSize valueOniPhones:30 andiPads:30];
        self.size  = [BVSize resizeUniversally:CGSizeMake(self.size.width, rowHeight) firstTime:YES useFullWidth:YES];
        self.color = [UIColor clearColor];//[UIColor colorWithWhite:0.5 alpha:0.1];
        self.scrollingSpeed = scrollingSpeed;
        self.scrollingDirection = scrollingDirection;
    }
    
    return self;
}

@end
