//
//  BlueDevice.h
//  SmartLightLib
//
//  Created by LevinYan on 15/5/19.
//  Copyright (c) 2015年 mac mini. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreData/CoreData.h>
#import "DataPacket.h"

@class BLEManager;

typedef NS_ENUM(NSUInteger, DeviceType)
{
  RemoterType = 0,
  ColorfulLight,
  ColorTemperatureLight,
  BrightnessLight,
  OutletLight,
};
typedef NS_ENUM(UInt8, FirmwareInfoType)
{
  FirmwareInfoVersion = 1,
  FirmwareInfoDate,
  FirmwareInfoName,
};

typedef void (^RespondBlock)(RespondPacket* respondPacket) ;
@class Network;

/**
 *  该产品名字为Blue+，所以BlueDevice描述一个Blue+设备，BlueDevice为抽象类，
 *  子类BlueLight为描述Blue+灯设备
 *
 */
@interface BlueDevice : NSManagedObject


/*
 * 名字
 */
@property (nonatomic, retain) NSString * name;

/*
 * 设备标识号
 */
@property (nonatomic, retain) NSNumber * deviceID;

/**
 *  设备类型
 */
@property (nonatomic, retain) NSNumber * deviceType;

/*
 * 设备广播时携带的网络最大设备号
 */
@property (nonatomic, retain) NSNumber * maxDeviceID;

/*
 * 网络标识号
 */
@property (nonatomic, retain) NSNumber * networkID;

/*
 * 地址
 */
@property (nonatomic, retain) NSString * address;

/*
 * 所在的网络
 */
@property (nonatomic, retain) Network  * network;

/**
 *  网络名字
 */
@property (nonatomic, strong) NSString *networkName;

/*
 * 蓝牙外设
 */
@property (nonatomic, strong) CBPeripheral * peripheral;


@property (nonatomic, strong) BLEManager *bleManager;
/**
 *  是否发现设备，当被扫描到，为YES，否则为NO
 */
@property (nonatomic, assign) BOOL isFound;


/**
 *  是否已经添加入网络
 */
@property (nonatomic, assign) BOOL isAddedToNetwork;

/**
 *  是否已经保存在数据库中
 */
@property (nonatomic, assign) BOOL isSaved;
/**
 *  根据blue+设备的广播数据创建对象
 *
 *  @param advData 广播数据
 *
 *  @return blueDevice对象
 */
+ (instancetype)createWithAdvData:(NSData*)advData;


/**
 *  从云端获取数据创建对象
 *
 *  @param address     地址
 *  @param type        设备类型
 *  @param networkID   网络ID
 *  @param deviceID    设备ID
 *  @param maxDeviceID 网络内最大设备ID
 *
 *  @return 设备对象
 */
+ (instancetype)createWithAddress:(NSString*)address
                             name:(NSString *)name
                       deviceType:(NSNumber *)type
                        networkID:(NSNumber *)networkID
                         deviceID:(NSNumber *)deviceID
                      maxDeviceID:(NSNumber *)maxDeviceID;

/**
 *  根据blue+设备的广播数据从数据库中取出对象
 *
 *  @param advData 广播数据
 *
 *  @return blueDevice对象
 */
+ (instancetype)fetchWithAdvData:(NSData *)advData;


/*
 * 连接
 * @param completeBlock连接完成block，当error为nil代表连接成功，否则为失败
 */
- (void)connect:(void (^)(NSError* error))completeBlock;



/*
 * 断开连接
 * @param completeBlock断开连接完成block，当error为nil代表成功，否则为失败
 */
- (void)disconnect:(void (^)(NSError *error))completeBlock;
/*
 * 发送命令
 * @param command代表命令
 * @param block代表命令返回的响应
 */
- (void)sendCommand:(CommandPacket *)command  respond:(RespondBlock)block;


/**
 *  表示当前网络连接的灯，发送该指令，当前连接的灯会闪烁
 */
- (void)identify:(void (^)())complete;

/**
 *  获取固件信息
 *
 *  @param type          类型
 *  @param completeBlock 返回信息
 */
- (void)getFirmwareInfo:(FirmwareInfoType)type complete:(void (NSString* info))completeBlock;

- (void)reset;

@end


@interface BlueDevice(AdvParser)

+ (NSString*)addressFromAdvData:(NSData*)advData;

+ (NSNumber*)networkIDFromAdvData:(NSData*)advData;

- (instancetype)initWithAdvData:(NSData *)advData;

+ (BOOL)isSavedBlueDeviceAdvertising:(NSData*)advData;

+ (BOOL)hasBlueDeviceAddedToNetwork:(NSData*)advData;

+ (BOOL)isBlueDeviceAdvertising:(NSData *)advData;

+ (BOOL)isRemoterAdvertising:(NSData*)advData;


@end
