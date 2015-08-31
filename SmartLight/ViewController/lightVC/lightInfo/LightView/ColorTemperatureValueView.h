//
//  ColorTemperatureValueView.h
//  SmartLight
//
//  Created by xtmac on 5/6/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorTemperatureValueViewDelegate <NSObject>

@optional

-(void)colorTemperatureWithWarn:(unsigned int)warn withCold:(unsigned)cold;
-(void)colorTemperatureQuickControlWithWarn:(unsigned int)warn withCold:(unsigned)cold;

@end

@interface ColorTemperatureValueView : UIView

@property (assign, nonatomic) IBOutlet id delegate;

@property (assign, nonatomic, readonly) unsigned int warn;

@property (assign, nonatomic, readonly) unsigned int cold;

-(void)initView;

-(void)setWarn:(unsigned int)warn;
-(void)setCold:(unsigned int)cold;

@end
