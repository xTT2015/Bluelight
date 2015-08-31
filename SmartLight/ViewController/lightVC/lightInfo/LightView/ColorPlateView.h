//
//  ColorPlateView.h
//  test
//
//  Created by xtmac on 19/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPlateViewDelegate <NSObject>

@optional

-(void)colorPlateGetColorRed:(unsigned int)red green:(unsigned int)green blue:(unsigned int)blue;
-(void)colorPlateQuickControl:(unsigned int)red green:(unsigned int)green blue:(unsigned int)blue;
@end

@interface ColorPlateView : UIImageView


/**
 *  代理
 */
@property (assign, nonatomic) IBOutlet id<ColorPlateViewDelegate> delegate;


/**
 *  取色盘是否可用
 */
@property (assign, nonatomic, readonly) BOOL isControllable;


/**
 *  取色框是否可见
 */
@property (assign, nonatomic, readonly) BOOL isColorBoxVisible;


-(void)initView;


/**
 *  初始化取色盘
 *
 *  @param point  取色盘的位置
 *  @param radius 取色盘的半径
 *
 *  @return ColorPlateView的实例对象
 */
-(id)initWithColorPlateWithOrigin:(CGPoint)point withRadius:(float)radius;


/**
 *  设置取色盘是否可用
 *
 *  @param isControllable   TRUE:取色盘可用 FALSE:取色盘不可用
 */
-(void)setIsControllable:(BOOL)isControllable;


/**
 *  设置取色框是否可见
 *
 *  @param isVisible TRUE:取色框可见 FALSE:取色框不可见
 */
-(void)setColorBoxIsVisible:(BOOL)isVisible;


/**
 *  设置取色框的中心位置
 *
 *  @param point 取色框的中心位置
 */
-(void)setColorBoxCenterPoint:(CGPoint)point;


/**
 *  获取取色框的中心位置
 *
 *  @return 取色框的中心位置，0.0 - 1.0,位置占取色盘大小的百分比
 */
-(CGPoint)getColorBoxCenterPoint;

@end

