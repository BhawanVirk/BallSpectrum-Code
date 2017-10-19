//
//  BVButton.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 12/15/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVButton.h"
#import "BVSize.h"
#import "BVLabelNode.h"
#import "UIImage+Scaling.h"
#import "BVUtility.h"

// NOTE: BUTTON SIZE HEIGHT SHOULD BE LOWER THAN 80pts FOR BETTER RESULTS

typedef enum : NSUInteger {
    BVButtonTextureGreen,
    BVButtonTextureBluish,
    BVButtonTextureRedish,
    BVButtonTextureYellowish
} BVButtonTexture;

@implementation BVButton

+ (BVButton *)MoneyButtonWithVal:(NSNumber *)value fontSize:(int)fontSize size:(CGSize)buttonSize showCoin:(BOOL)showCoinImage coinSize:(CGSize)coinImgSize
{
    // create unlock label and coins button
    NSNumberFormatter *currencyStyle = [BVUtility currencyStyleFormatter];
    NSString *buttonText = [currencyStyle stringFromNumber:value];
    
    CGSize greenImgSize = CGSizeMake(12.5, buttonSize.height);
    NSArray *buttonTexture = [BVButton getTextureImage:BVButtonTextureGreen size:greenImgSize];
    
    UIImage *coinIcon;
    
    if (showCoinImage) {
        coinIcon = [[UIImage imageNamed:@"coin-icon"] imageScaledToFitSize:coinImgSize];
    }
    else {
        coinIcon = nil;
    }
    
    BVButton *button = [[BVButton alloc] initWithTexture:buttonTexture text:buttonText fontSize:fontSize image:coinIcon];
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    return button;
}

+ (BVButton *)GreenButtonWithText:(NSString *)text fontSize:(int)fontSize size:(CGSize)buttonSize
{
    CGSize greenImgSize = CGSizeMake(12.5, buttonSize.height);
    NSArray *buttonTexture = [BVButton getTextureImage:BVButtonTextureGreen size:greenImgSize];
    
    BVButton *button = [[BVButton alloc] initWithTexture:buttonTexture text:text fontSize:fontSize image:nil];
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    return button;
}

+ (BVButton *)BluishButtonWithText:(NSString *)text fontSize:(int)fontSize size:(CGSize)buttonSize
{
    CGSize bluishImgSize = CGSizeMake(12.5, buttonSize.height);
    NSArray *buttonTexture = [BVButton getTextureImage:BVButtonTextureBluish size:bluishImgSize];
    
    BVButton *button = [[BVButton alloc] initWithTexture:buttonTexture text:text fontSize:fontSize image:nil];
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    return button;
}

+ (BVButton *)RedishButtonWithText:(NSString *)text fontSize:(int)fontSize size:(CGSize)buttonSize
{
    CGSize redishImgSize = CGSizeMake(12.5, buttonSize.height);
    NSArray *buttonTexture = [BVButton getTextureImage:BVButtonTextureRedish size:redishImgSize];
    
    BVButton *button = [[BVButton alloc] initWithTexture:buttonTexture text:text fontSize:fontSize image:nil];
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    return button;
}

+ (BVButton *)YellowishButtonWithText:(NSString *)text fontSize:(int)fontSize size:(CGSize)buttonSize
{
    CGSize yellowishImgSize = CGSizeMake(12.5, buttonSize.height);
    NSArray *buttonTexture = [BVButton getTextureImage:BVButtonTextureYellowish size:yellowishImgSize];
    
    BVButton *button = [[BVButton alloc] initWithTexture:buttonTexture text:text fontSize:fontSize image:nil];
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    return button;
}

+ (BVButton *)CloseButtonOfSize:(CGSize)size
{
    BVButton *button = [[BVButton alloc] initWithImgNamed:@"close-button"];
    button.frame = CGRectMake(0, 0, size.width, size.height);
    
    return button;
}

- (nonnull instancetype)initWithTexture:(NSArray *)texture text:(NSString *)buttonText fontSize:(int)fontSize image:(UIImage *)image
{
    self = [super init];
    
    if (self) {
        
        UIImage *backgroundImg = [texture objectAtIndex:0];
        UIImage *hoverImage = [texture objectAtIndex:1];
        
        self.titleLabel.font = [UIFont fontWithName:BVdefaultFontName() size:fontSize];//[UIFont systemFontOfSize:fontSize];
        [self setTitle:buttonText forState:UIControlStateNormal];
        [self setBackgroundImage:backgroundImg forState:UIControlStateNormal];
        [self setBackgroundImage:hoverImage forState:UIControlStateHighlighted];
        
        if (image) {
            [self setImage:image forState:UIControlStateNormal];
            [self setImage:image forState:UIControlStateHighlighted];
        }

    }
    
    return self;
}

- (nonnull instancetype)initWithImgNamed:(NSString *)imageNamed
{
    self = [super init];
    
    if (self) {
        UIImage *buttonImg = [UIImage imageNamed:imageNamed];
        
        [self setBackgroundImage:buttonImg forState:UIControlStateNormal];
        [self setBackgroundImage:buttonImg forState:UIControlStateHighlighted];
    }
    
    return self;
}

#pragma mark - Utility Methods

+ (NSArray *)getTextureImage:(BVButtonTexture)texture size:(CGSize)size
{
    UIImage *normal;
    UIImage *pressed;
    
    switch (texture) {
        case BVButtonTextureGreen:
            normal = [[[UIImage imageNamed:@"green-button-normal"] imageScaledToSize:size] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 6, 40, 6)];
            pressed = [[[UIImage imageNamed:@"green-button-pressed"] imageScaledToSize:size] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 6, 40, 6)];
            break;
            
        case BVButtonTextureBluish:
            normal = [[[UIImage imageNamed:@"bluish-button-normal"] imageScaledToSize:size] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 6, 40, 6)];
            pressed = [[[UIImage imageNamed:@"bluish-button-pressed"] imageScaledToSize:size] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 6, 40, 6)];
            break;
            
        case BVButtonTextureRedish:
            normal = [[[UIImage imageNamed:@"redish-button-normal"] imageScaledToSize:size] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 6, 40, 6)];
            pressed = [[[UIImage imageNamed:@"redish-button-pressed"] imageScaledToSize:size] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 6, 40, 6)];
            break;
            
        case BVButtonTextureYellowish:
            normal = [[[UIImage imageNamed:@"yellowish-button-normal"] imageScaledToSize:size] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 6, 40, 6)];
            pressed = [[[UIImage imageNamed:@"yellowish-button-pressed"] imageScaledToSize:size] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 6, 40, 6)];
            break;
            
        default:
            break;
    }
    
    return @[normal, pressed];
}

@end
