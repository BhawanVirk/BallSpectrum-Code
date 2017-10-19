//
//  UIImage+Scaling.m
//  AwesomeBalls
//
//  Created by Bhawan Virk on 8/11/15.
//  Copyright © 2015 Bhawan Virk. All rights reserved.
//

#import "UIImage+Scaling.h"

#define radians(degrees) (degrees * M_PI/180)

@implementation UIImage(Scaling)

- (UIImage *)imageScaledToSize:(CGSize)size
{
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

- (UIImage *)imageScaledToFitSize:(CGSize)size
{
    //calculate rect
    CGFloat aspect = self.size.width / self.size.height;
    if (size.width / aspect <= size.height)
    {
        return [self imageScaledToSize:CGSizeMake(size.width, size.width / aspect)];
    }
    else
    {
        return [self imageScaledToSize:CGSizeMake(size.height * aspect, size.height)];
    }
}

- (UIImage *)tiledImageOfSize:(CGSize)size
{
    CGSize imageViewSize = size;
    UIImage *backImageAspectFit = [self imageScaledToFitSize:imageViewSize];
    
    UIGraphicsBeginImageContextWithOptions(imageViewSize, NO, 0);
    CGContextRef imageContext = UIGraphicsGetCurrentContext();
    CGContextRotateCTM (imageContext, radians(180));
    CGContextDrawTiledImage(imageContext, CGRectMake(0, 0, backImageAspectFit.size.width, backImageAspectFit.size.height), self.CGImage);
    UIImage *finishedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    CGContextRelease(imageContext);
//    UIGraphicsEndImageContext();
    
    return finishedImage;
}


@end
