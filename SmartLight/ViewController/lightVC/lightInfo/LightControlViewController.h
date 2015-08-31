//
//  LightControllerViewController.h
//  BDEBluePlus
//
//  Created by xtmac on 19/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "baseViewController.h"
#import "Remoter.h"

#import "ColorPlateView.h"
#import "BrightnessView.h"
#import "DefaultColorView.h"
#import "ColorTemperatureValueView.h"

@interface LightControlViewController : baseViewController<ColorPlateViewDelegate,BrightnessViewDelegate,DefaultColorViewDelegate,ColorPlateViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *groupManageView;
@property (weak, nonatomic) IBOutlet ColorPlateView *colorPlate;
@property (weak, nonatomic) IBOutlet BrightnessView *brightnessView;
@property (weak, nonatomic) IBOutlet DefaultColorView *defaultColorView;
@property (weak, nonatomic) IBOutlet ColorTemperatureValueView *colorTemperatureValueView;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UIButton *lightBtn1;
@property (weak, nonatomic) IBOutlet UIButton *lightBtn2;
@property (weak, nonatomic) IBOutlet UIButton *lightBtn3;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;

/*!
 *  组控制时为组对象，否则为空
 */
@property (strong, nonatomic) Group *playGroup;


/**
 *  单灯控制时为灯对象，否则为空
 */
@property (strong, nonatomic) Light *playLight;


/**
 *  随意控配置时为随意控，否则为空
 */
@property (strong, nonatomic) Remoter *playRemoter;



/**
 *  当控制面板为随意控控制类型的时候，设置控制面板的配置
 *
 *  @param color                    设置控制面板配置属性的color值
 *  @param remoterControlDeviceType 设置随意控要控制的灯的类型
 */
/**
 *  当控制面板为随意控控制类型的时候，设置控制面板的配置
 *
 *  @param remoter                  设置随意控
 *  @param color                    设置控制面板配置属性的color值
 *  @param remoterControlDeviceType 设置随意控要控制的灯的类型
 */
-(void)setRemoter:(Remoter *)remoter withColor:(Color)color withRemoterControlDeviceType:(RemoterControlDeviceType)remoterControlDeviceType;


@end
