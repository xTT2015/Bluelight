//
//  BrightnessView.h
//  test
//
//  Created by xtmac on 19/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BrightnessViewDelegate <NSObject>

@optional

-(void)brightnessViewGetBrightness:(int)brightness;
-(void)brightnessViewQuickControlWithBrightness:(int)brightness;

@end

@interface BrightnessView : UIView

@property (assign, nonatomic) IBOutlet id<BrightnessViewDelegate> delegate;

-(void)initView;

-(void)setColor:(UIColor*)color;

-(void)setBrightness:(int)brightness;

-(int)getBrightness;

@end
