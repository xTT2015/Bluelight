//
//  UIImageView+ColorAtPixel.h
//  SmartHome
//
//  Created by xtmac on 3/7/14.
//  Copyright (c) 2014年 XT800. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct{
    unsigned int red:8;
    unsigned int green:8;
    unsigned int blue:8;
    unsigned int alpha:8;
}RGBAColor;

@interface UIImageView (ColorAtPixel)

//- (UIColor*)colorAtPixel:(CGPoint)point;

-(RGBAColor)colorAtPixel:(CGPoint)point;

@end
