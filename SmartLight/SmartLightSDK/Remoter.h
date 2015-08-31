//
//  Remoter.h
//  SmartLightLib
//
//  Created by LevinYan on 15/5/19.
//  Copyright (c) 2015年 mac mini. All rights reserved.
//

#import "BlueDevice.h"

typedef NS_ENUM(NSUInteger, RemoterControlDeviceType)
{
    RemoterControlOutletLight = 0x04,
    RemoterControlColofulLight,
    RemoterControlColorTemperatureLight,
    RemoterControlBrightnessLight,
    RemoterControlAllDevice,
};
@class Light;

@interface Remoter : BlueDevice


/**
 *  配置随意控设备
 *
 *  @param lights        随意控控制的灯
 *  @param deviceType    控制类型
 *  @param color         控制效果
 *  @param completeBlock 完成callback
 */
- (void)configureToControl:(NSArray*)lights deviceType:(RemoterControlDeviceType)deviceType color:(Color)color complete:(void (^)(NSError *error))completeBlock;


/**
 *  读取随意控的配置信息
 *
 *  @param successBlock 成功callback，deviceType表示控制类型，lights表示随意控控制的灯，
 * color 表示控制效果
 *  @param failBlock    失败callback
 */
- (void)getRemoterConfigureSuccess:(void (^)(RemoterControlDeviceType deviceType, NSArray *lights, Color color))successBlock fail:(void (^)(NSError* error))failBlock;
@end
