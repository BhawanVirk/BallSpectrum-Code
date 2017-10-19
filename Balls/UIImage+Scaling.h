//
//  UIImage+Scaling.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/11/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(Scaling)

- (UIImage *)imageScaledToSize:(CGSize)size;
- (UIImage *)imageScaledToFitSize:(CGSize)size;
- (UIImage *)tiledImageOfSize:(CGSize)size;

@end
