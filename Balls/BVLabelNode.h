//
//  BVLabelNode.h
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/6/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

NSString * _Nonnull BVdefaultFontName();
NSString * _Nonnull BVdefaultFontItalicName();
UIColor * _Nonnull BVdefaultFontColor();
float BVdefaultFontSize();
float BVdynamicFontSize(CGSize viewSize);
float BVdynamicFontSizeWithFactor(CGSize viewSize, float factor);

@interface BVLabelNode : SKLabelNode

+ (nonnull instancetype)labelWithText:(nullable NSString *)text;
+ (nonnull BVLabelNode *)labelWithText:(nonnull NSString *)text color:(nonnull UIColor *)fontColor size:(CGFloat)fontSize shadowColor:(nonnull UIColor *)shadowColor offSetX:(float)shadowOffSetX offSetY:(float)shadowOffSetY;
+ (nonnull BVLabelNode *)notificationLabelWithText:(nonnull NSString *)text color:(nonnull UIColor *)fontColor size:(float)fontSize pos:(CGPoint)position;

@end