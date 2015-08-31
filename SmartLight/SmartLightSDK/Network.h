//
//  Network.h
//  SmartLight
//
//  Created by LevinYan on 3/19/15.
//  Copyright (c) 2015 BDE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Light.h"
#import "Remoter.h"
#import "FBKVOController.h"

#import "MJExtension.h"

@protocol NetworkDelegate <NSObject>

/**
 *  自动添加属于该网络的设备通知，当扫描到属于本网络并且未到添加设备列表(lights，remoters),
 *  会自动添加到对应的列表里，然后通过该方法，通知应用层
 *
 *  @param blue+设备
 *
 */

- (void)autoAddBlueDeviceNotify:(BlueDevice*)device;

/**
 *  当扫描的设备原来属于网络，但是已经被重置，或者其他用户删除出网络
 *  会自动从本地设备列表中删除，然后通过该方法通知应用层
 *
 *  @param device blue+设备
 */
- (void)autoDeleteBlueDeviceNotify:(BlueDevice*)device;
@end

@interface Network : NSManagedObject


/**
 *  代理
 */
@property (nonatomic, weak) id<NetworkDelegate> delegate;
/*
 * 网络名字
 */
@property (nonatomic, retain) NSString * name;


/*
 * 网络密码
 */
@property (nonatomic, retain) NSString * password;

/*
 * 网络标识号
 */
@property (nonatomic, retain) NSNumber * networkID;

/*
 * 网络最大设备号，用于当设备加入网络时，给设备分配设备号
 */
@property (nonatomic, retain) NSNumber * maxDeviceID;

/*
 * 已添加到网络的灯
 */
@property (nonatomic, retain) NSSet *lights;

/**
 *  已添加到网络的遥控器
 */
@property (nonatomic, retain) NSSet *remoters;

/*
 * 网络连接状态
 */
@property (nonatomic, assign) BOOL connected;



/**
 *  扫描到新的灯（还没有添加入任何网络）
 */
@property (nonatomic, strong) NSMutableArray *scanedNewLights;


/**
 *  扫描到新的遥控器(还没有添加入任何网络）
 */
@property (nonatomic, strong) NSMutableArray *scanedNewRemoters;

/*
 * 当前连接的灯
 */
@property (nonatomic, strong) Light *connectedLight;

+ (instancetype)newNetwork;

/*
 * 创建网络
 * @param name 网络名称
 * @param password 网络密码
 * @return 返回网络实例
 */

+ (instancetype)newNetwork:(NSString*)name password:(NSString*)password;

/*
 * 创建网络
 * @param name 网络名称
 * @param password 网络密码
 * @param networkID 网络ID
 * @return 返回网络实例
 */

+ (instancetype)newNetwork:(NSString *)name password:(NSString *)password networkID:(NSNumber*)networkID;


- (NSArray*)getLightsWithType:(DeviceType)type;


/*
 * 断开连接
 */
- (void)disconnect:(void (^)(NSError *error))completeBlock;




/*
 * 开启自动连接，自动扫描网络内的设备，并且连接上，当断开时，会自动重连
 */
- (void)startAutoConnect;

/*
 * 停止自动连接，如果当前是处于连接状态，断开当前连接，并且不会自动重连
 */
- (void)stopAutoConnect;

/**
 *  扫描blue+设备
 *
 *  @param timeout     扫描时长 0代表一直扫描
 *  @param resultBlock 当扫描到设备调用,该block有会被多次调用
 */
- (void)scanForBlueDevice:(void(^)(BlueDevice *device))resultBlock;

/**
 *  停止扫描blue+设备
 */
- (void)stopScanForBlueDevice;

/**
 *  扫描属于本网络的blue+设备
 *
 *  @param resultBlock 当扫描到设备调用,该block有会被多次调用
 */
- (void)scanForBlueDeviceOfNetwork:(void (^)(BlueDevice *device))resultBlock;

/**
 *  停止扫描属于本网络的设备
 */
- (void)stopScanForBlueDeviceOfNetwork;

/*
 * 添加blue+设备到网络
 * @param device BlueDevice实例
 * @param completeBlock 完成block，成功error为nil，否则为非nil
 */

- (void)addBlueDevice:(BlueDevice*)device complete:(void (^)(NSError *))completeBlock;

/**
 *  导入设备到数据中（不需要连接的，用于导入云端的设备）
 *
 *  @param device blue+实例
 */
- (void)importBlueDevice:(BlueDevice*)device;

/*
 * 把blue+设备从网络中删除
 * @param device BlueDevice实例
 * @param completeBlock 完成block，成功error为nil，否则为非nil
 */
//TODO: 内部支持先扫描上灯，然后连接上，再删除
- (void)deleteBlueDevice:(BlueDevice *)device complete:(void (^)(NSError *))completeBlock;


/**
 *  表示当前网络连接的灯，发送该指令，当前连接的灯会闪烁
 */
- (void)identifyConnectedLight;

/*
 * 控制灯
 * @param lights 需要控制的灯（该灯必须为同一个类型,参考DeviceType），数组内位Light实例
 * @param color  color代表为改变的颜色
 * @param resultBlock 状态返回，lights表示状态更新的灯，为Light实例,该block可能会被调用多次
 */
//TODO: 增加0x08
- (void)controlLights:(NSArray*)lights color:(Color)color result:(void (^)(NSArray *lights))resultBlock;



/**
 *  控制所有类型灯
 *
 *  @param lights 需要控制的灯
 *  @param on     开关
 */
- (void)controlAllTypeLights:(NSArray*)lights on:(BOOL)on;



/**
 *  快速控制灯，无状态反馈
 *
 *  @param lights 需要控制的灯（该灯必须为同一个类型,参考DeviceType），数组内位Light实例
 *  @param color  color代表为改变的颜色
 */
- (void)quicklyControlLights:(NSArray *)lights color:(Color)color;



- (NSArray*)bitmapPayloadToLights:(UInt8*)payload;

- (FBKVOController*)kvoController;

@end

@interface Network (CoreDataGeneratedAccessors)

- (void)addLightsObject:(Light *)value;
- (void)removeLightsObject:(Light *)value;
- (void)addLights:(NSSet *)values;
- (void)removeLights:(NSSet *)values;

- (void)addRemotersObject:(Remoter *)value;
- (void)removeRemotersObject:(Remoter *)value;
- (void)addRemoters:(NSSet *)values;
- (void)removeRemoters:(NSSet *)values;

@end


