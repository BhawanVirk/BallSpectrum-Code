//
//  BVPlaygroundHero.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 10/30/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "BVPlaygroundHero.h"
#import "BVSize.h"
#import "BVPlaygroundBitmasks.h"

@implementation BVPlaygroundHero

- (instancetype)initWithColor:(UIColor *)color
{
    self = [super init];
    
    if (self) {
        
        self.name = @"main-hero";
        self.color = color;
        self.zPosition = 10;
        
        float factor = [BVSize valueOniPhones:0.061 andiPads:0.051];
        float wAndH = CGRectGetHeight([UIScreen mainScreen].bounds) * factor;
        self.size = CGSizeMake(wAndH, wAndH);
        
        SKShapeNode *shape = [[SKShapeNode alloc] init];
        
        
        // setup texture
//        self.texture = [SKTexture textureWithImage:[self circleImageWithColor:color]];
        self.texture = [SKTexture textureWithImageNamed:@"Hero1"];
        
        // add physics
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2];
        self.physicsBody.categoryBitMask = BVPlaygroundPhysicsCategoryHero;
        self.physicsBody.contactTestBitMask = BVPlaygroundPhysicsCategoryGround | BVPlaygroundPhysicsCategorySkyEnd | BVPlaygroundPhysicsCategoryObstacle | BVPlaygroundPhysicsCategoryCoin | BVPlaygroundPhysicsCategoryCellGateway;
        self.physicsBody.collisionBitMask = BVPlaygroundPhysicsCategoryGround | BVPlaygroundPhysicsCategorySkyEnd | BVPlaygroundPhysicsCategoryObstacle;
        self.physicsBody.mass = 0.056770;
        self.physicsBody.affectedByGravity = NO;
        
        NSLog(@"Hero mass: %f", self.physicsBody.mass);
    }
    return self;
}

- (void)noMoreCollision
{
    self.physicsBody.contactTestBitMask = BVPlaygroundPhysicsCategoryGround;
}

- (UIImage *)circleImageWithColor:(UIColor *)color
{
    UIImage *circle = nil;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillEllipseInRect(ctx, rect);
    
    circle = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(ctx);
    UIGraphicsEndImageContext();
    
    return circle;
}

@end
