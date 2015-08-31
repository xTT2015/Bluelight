//
//  BLEManager.h
//  WristbandApp
//
//  Created by LevinYan on 14-10-20.
//  Copyright (c) 2014年 BDE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef void (^BLEInitResultType)(CBCentralManagerState BLEManagerstate);
typedef void (^BLEScanResultType)(CBPeripheral *p, NSDictionary *advertisementData, NSNumber *RSSI, BOOL isFinished);
typedef void (^BLEConnectResultType)(CBPeripheral* p, NSError *error);
typedef void (^BLEDisconnectResultType)(CBPeripheral *p, NSError* error);
typedef void (^BLEWriteCharacResultType)(CBPeripheral* p, CBCharacteristic *c, NSError *error);
typedef void (^BLEReadCharacResultType)(CBPeripheral* p, CBCharacteristic *c, NSError *error);
typedef void (^BLEUpdateNotifyResultType)(CBPeripheral* p, CBCharacteristic *c, NSError *error);


@protocol BLEManagerDelegate <NSObject>
//当error不为nil的时，为异常断开，否则为正常断开（比如手机发起断开连接)
- (void)BLEManagerDisconnectWithPeripheral:(CBPeripheral*)p error:(NSError*)error;
- (void)BLEManagerRecvValueForPeripheral:(CBPeripheral*)p characteristic:(CBCharacteristic*)characteristic error:(NSError*)error;

@end
@interface BLEManager : NSObject
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral*   connectedPeripheral;
@property (nonatomic, strong) NSMutableArray* foundedPeripherals;
@property (nonatomic, strong) id<BLEManagerDelegate> delegate;



+(instancetype)sharedInstance;

- (CBCharacteristic*)getCharacteristicWithUUID:(CBUUID*)uuid peripheral:(CBPeripheral*)peripheral;

- (void)stopScan;

- (void)scanForPeripheralsNoDuplicatesWithServices:(NSArray*)serviceUUIDs timeOut:(NSTimeInterval)seconds withResult:(BLEScanResultType)result;

- (void)connectAndDiscService:(CBPeripheral*)p  withResult:(BLEConnectResultType)result;

- (void)disconnect:(CBPeripheral*)p withResult:(BLEDisconnectResultType)result;

- (void)writeValue:(NSData *)data forCharacteristicUUIDString:(NSString*)uuidString peripheral:(CBPeripheral *)peripheral withResult:(BLEWriteCharacResultType)result;

- (void)writeValue:(NSData*)data  forCharacteristic:(CBCharacteristic *)characteristic peripheral:(CBPeripheral*)peripheral withResult:(BLEWriteCharacResultType)result;

- (void)readValue:(NSData*)data forCharacteristic:(CBCharacteristic *)characteristic peripheral:(CBPeripheral*)peripheral withResult:(BLEReadCharacResultType)result;

- (void)setNotifyValue:(BOOL)enabled forCharacteristicUUIDString:(NSString*)uuidString peripheral:(CBPeripheral *)peripheral withResult:(BLEUpdateNotifyResultType)result;

- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic peripheral:(CBPeripheral*)peripheral;
@end
