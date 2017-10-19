//
//  BVDialogBox.m
//  BallSpectrum
//
//  Created by Bhawan Virk on 1/17/16.
//  Copyright © 2016 Bhawan Virk. All rights reserved.
//

#import "BVDialogBox.h"
#import "BVSize.h"
#import "UIImage+Scaling.h"
#import "BVColor.h"
#import "BVLabelNode.h"
#import "BVButton.h"

@implementation BVDialogBox

@synthesize contentBackgroundColor = _contentBackgroundColor;

- (instancetype)initWithUi:(BVDialogBoxUi)uiType label:(NSString *)label size:(CGSize)size withCloseButton:(BOOL)addCloseButton
{
    self = [super init];
    
    if (self) {
        // default label size
        _labelSize = [BVSize valueOniPhone4s:16 iPhone5To6sPlus:18 iPad:28];
        
        // user can use coins to unlock this level
        self.frame = CGRectMake(0, 0, size.width, size.height);
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.3;
        self.layer.cornerRadius = 5.0;
        self.layer.borderWidth = 1;
        
        // create label background bar
        [self setupUiType:uiType withLabel:label];
        
        if (addCloseButton) {
            [self addCloseButton];
        }
    }
    
    return self;
}

#pragma mark - UI Helper

- (void)setupUiType:(BVDialogBoxUi)uiType withLabel:(NSString *)label
{
    switch (uiType) {
        case BVDialogBoxUiRedish:
            [self addSubview:[self createLabelBarWithImgNamed:@"dialog-label-bar-redish" addLabel:label]];
            self.layer.borderColor = [BVColor r:97 g:34 b:75].CGColor;
            break;
            
        case BVDialogBoxUiBrown:
            [self addSubview:[self createLabelBarWithImgNamed:@"dialog-label-bar-brown" addLabel:label]];
            self.layer.borderColor = [BVColor r:97 g:61 b:34].CGColor;
            break;
            
        case BVDialogBoxUiBlack:
            [self addSubview:[self createLabelBarWithImgNamed:@"dialog-label-bar-black" addLabel:label]];
            self.layer.borderColor = [UIColor blackColor].CGColor;
            break;
            
        default:
            break;
    }
}

- (UIView *)createLabelBarWithImgNamed:(NSString *)barImgName addLabel:(NSString *)labelText
{
    CGSize labelBarSize = [BVSize sizeOniPhone4s:CGSizeMake(12.5, 40) iPhone5To6sPlus:CGSizeMake(12.5, 50) iPad:CGSizeMake(12.5, 80)];
    UIImage *labelBarImg = [[[UIImage imageNamed:barImgName] imageScaledToSize:labelBarSize] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 8, 40, 8)];
    _labelBarView = [[UIImageView alloc] initWithImage:labelBarImg];
    _labelBarView.tag = 1;
    _labelBarView.frame = CGRectMake(0, 0, self.frame.size.width, labelBarSize.height);
    
    // create label
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:BVdefaultFontName() size:_labelSize];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [BVColor r:102 g:52 b:0];
    label.shadowOffset = CGSizeMake(1, 2);
    label.text = labelText;
    [label sizeToFit];
    label.center = CGPointMake(self.center.x, CGRectGetMidY(_labelBarView.frame));
    [_labelBarView addSubview:label];
    
    return _labelBarView;
}

- (void)addCloseButton
{
    CGSize buttonSize = [BVSize sizeOniPhone4s:CGSizeMake(22, 22) iPhone5To6sPlus:CGSizeMake(24, 24) iPad:CGSizeMake(28, 28)];
    BVButton *closeButton = [BVButton CloseButtonOfSize:buttonSize];
    
    float buttonX = CGRectGetMaxX(self.frame) - (buttonSize.width * 1.5);
    float buttonY = CGRectGetMidY(_labelBarView.frame) - (buttonSize.height/2);
    
    closeButton.frame = CGRectMake(buttonX, buttonY, buttonSize.width, buttonSize.height);
    // add close button action target
    [closeButton addTarget:self action:@selector(dismissPopup:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
}

#pragma mark - Button Action Handler

- (void)dismissPopup:(BVButton *)sender
{
    [self.popup dismiss:YES];
}

#pragma mark - Getter & Setter

- (void)setContentBackgroundColor:(UIColor *)contentBackgroundColor
{
    _contentBackgroundColor = contentBackgroundColor;
    self.backgroundColor = contentBackgroundColor;
}

@end
