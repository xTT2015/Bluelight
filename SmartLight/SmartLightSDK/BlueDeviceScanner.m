//
//  BlueDeviceScanner.m
//  SmartLightLib
//
//  Created by LevinYan on 15/6/5.
//  Copyright (c) 2015年 mac mini. All rights reserved.
//

#import "BlueDeviceScanner.h"
#import "BLEManager.h"
#import "Light.h"
#import "Remoter.h"
#import "Network.h"
@interface BlueDeviceScanner()

@property (nonatomic, strong) BLEManager *bleManager;
@end

@implementation BlueDeviceScanner

- (instancetype)init
{
  self = [super init];
  _bleManager = [[BLEManager alloc] init];
  return self;
}
- (void)scanForBlueDevice:(NSNumber *)networkID result:(void (^)(BlueDevice *))result
{
  NSLog(@"start scan for network = %lX device", networkID.unsignedLongValue);
  __weak typeof(self) weakSelf = self;
  [self.bleManager scanForPeripheralsNoDuplicatesWithServices: nil /*@[[CBUUID UUIDWithString:kServiceUUID]]*/ timeOut:0 withResult:^(CBPeripheral *p, NSDictionary *advertisementData, NSNumber *RSSI, BOOL isFinished)
   {
     NSData *advData = [advertisementData valueForKey:CBAdvertisementDataManufacturerDataKey];
     if(![BlueDevice isBlueDeviceAdvertising:advData])
       return ;
     
     BlueDevice *device = nil;
   
     //判断该设备是否已经保存在数据库，如果是从数据中获取数据构造设备对象，否则用广播数据构造设备对象
     if([BlueDevice isSavedBlueDeviceAdvertising:advData])
     {
       device = [BlueDevice fetchWithAdvData:advData];
       if(!device.isAddedToNetwork) //该设备已经被重置，所以需要删除出网络
       {
         if([device isKindOfClass:[Light class]])
           [device.network removeLightsObject:(Light*)device];
         else
           [device.network removeRemotersObject:(Remoter*)device];
         
         if([device.network.delegate respondsToSelector:@selector(autoDeleteBlueDeviceNotify:)])
           [device.network.delegate autoDeleteBlueDeviceNotify:device];
         
         //重新构造一个新的设备
         device = [BlueDevice createWithAdvData:advData];
       }
     }
     else
       device = [BlueDevice createWithAdvData:advData];
     
     if(device.peripheral.state != CBPeripheralStateDisconnected)//由于iOS可以重复扫描到已经连接的设备，所以这里要过滤
     {
       return;
     }
     device.peripheral = p;
       NSLog(@"device.name  ==  %@",device.name);
     if (device.name.length == 0) {
        device.name = p.name;
     }
     device.bleManager = weakSelf.bleManager;
     device.networkName = [advertisementData valueForKey:CBAdvertisementDataLocalNameKey];
     
     
     if(networkID == nil || [device.networkID isEqualToNumber:networkID])
       result(device);
     
   }];
}
- (void)stopScan
{
  [self.bleManager stopScan];
}
- (void)scanForLight:(NSNumber *)networkID result:(void (^)(Light *))result
{
  [self scanForBlueDevice:networkID result:^(BlueDevice *blueDevice) {
    
    if([blueDevice isKindOfClass:[Light class]])
      result((Light*)blueDevice);
  }];
}
- (void)scanForRemoter:(NSNumber *)networkID result:(void (^)(Remoter *))result
{
  [self scanForBlueDevice:networkID result:^(BlueDevice *blueDevice) {
    
    if([blueDevice isKindOfClass:[Remoter class]])
      result((Remoter*)blueDevice);
  }];}
@end
