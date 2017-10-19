//
//  BVLabelNode.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/6/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVLabelNode.h"

#pragma mark - Functions
NSString *BVdefaultFontName() {
    return @"Optima-Bold";
}

NSString *BVdefaultFontItalicName() {
    return @"Optima-BoldItalic";
}

UIColor *BVdefaultFontColor() {
    return [UIColor colorWithRed:33/255.0f green:33/255.0f blue:33/255.0f alpha:1.0];
}

float BVdefaultFontSize() {
    return 16.0f;
}

float BVdynamicFontSize(CGSize viewSize) {
    return viewSize.width * 0.04;
}

float BVdynamicFontSizeWithFactor(CGSize viewSize, float factor) {
    return viewSize.width * factor;
}

@implementation BVLabelNode

#pragma mark - Initializers

+ (nonnull instancetype)labelWithText:(nullable NSString *)text
{
    return [[self alloc] initWithFontNamed:BVdefaultFontName() andText:text];
}

+ (BVLabelNode *)labelWithText:(NSString *)text color:(UIColor *)fontColor size:(CGFloat)fontSize shadowColor:(UIColor *)shadowColor offSetX:(float)shadowOffSetX offSetY:(float)shadowOffSetY
{
    BVLabelNode *label = [BVLabelNode labelWithText:text];
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.fontColor = shadowColor;
    label.fontSize = fontSize;
    label.zPosition = 3;
    
    BVLabelNode *labelShadow = [BVLabelNode labelWithText:text];
    labelShadow.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    labelShadow.fontColor = fontColor;
    labelShadow.fontSize = fontSize;
    labelShadow.zPosition = label.zPosition - 1;
    labelShadow.position = CGPointMake(labelShadow.position.x - shadowOffSetX, labelShadow.position.y - shadowOffSetY);
    
    [label addChild:labelShadow];
    
    return label;
}

- (nonnull instancetype)initWithFontNamed:(nullable NSString *)fontName andText:(nullable NSString *)text
{
    self = [super initWithFontNamed:fontName];
    
    if (self) {
        self.fontColor = BVdefaultFontColor();
        self.fontSize = BVdefaultFontSize();
        self.text = text;
    }
    
    return self;
}

#pragma mark - Utility Methods

+ (BVLabelNode *)notificationLabelWithText:(NSString *)text color:(UIColor *)fontColor size:(float)fontSize pos:(CGPoint)position
{
    // add points label
    BVLabelNode *nLabel = [BVLabelNode labelWithText:text];
    nLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    nLabel.fontColor = fontColor;
    nLabel.fontSize = fontSize;
    nLabel.zPosition = 5;
    nLabel.position = position;
    
    // animate and delete label
    SKAction *animateAndDelete = [SKAction sequence:@[[SKAction group:@[[SKAction moveByX:0.0 y:10.0 duration:0.5],
                                                                        [SKAction fadeOutWithDuration:0.5]]],
                                                      [SKAction removeFromParent]]];
    [nLabel runAction:animateAndDelete];
    
    return nLabel;
}

@end