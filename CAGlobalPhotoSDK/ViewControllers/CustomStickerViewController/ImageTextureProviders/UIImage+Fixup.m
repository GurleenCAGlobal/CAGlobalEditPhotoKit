//
// HP Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

#import "UIImage+Fixup.h"

@implementation UIImage (Fixup)

// adapted from http://stackoverflow.com/questions/8915630/ios-uiimageview-how-to-handle-uiimage-image-orientation
- (UIImage *)normalize {
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (UIImage *)transparent
{
    CGFloat colorMasking[6] = {0, 0, 0, 0, 0, 0};

    CGImageRef imageRef = CGImageCreateWithMaskingColors(self.CGImage, colorMasking);
    UIImage *transparentImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return transparentImage;
}

- (UIImage *)resize:(CGSize)size
{
        UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
        [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
}

@end
