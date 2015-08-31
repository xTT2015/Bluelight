//
//  BLEManager.m
//  WristbandApp
//
//  Created by LevinYan on 14-10-20.
//  Copyright (c) 2014年 BDE. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEManager.h"
#import <UIKit/UIKit.h>
@interface BLEManager()<CBCentralManagerDelegate, CBPeripheralDelegate>
{
  BLEInitResultType initResult;
  BLEScanResultType scanResult;
  BLEConnectResultType connectResult;
  BLEDisconnectResultType disconnectResult;
  BLEWriteCharacResultType writeCharacResult;
  BLEReadCharacResultType readCharacResult;
  BLEUpdateNotifyResultType updateNotifyResult;
  NSTimer *scanTimer;
}


@end

@implementation BLEManager

+ (instancetype)sharedInstance
{
  static BLEManager * _sharedInstance = nil;
  static dispatch_once_t once_token;
  
  dispatch_once(&once_token, ^{
    if (_sharedInstance == nil)
    {
      _sharedInstance = [[BLEManager alloc] init];
    }
  });
  
  
  return _sharedInstance;

}

- (instancetype)init
{
  self = [super init];

  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  
  self = [[BLEManager alloc] initController:^(CBCentralManagerState BLEManagerstate) {
    dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);

  return self;
}
- (void)dealloc
{
  
}
- (instancetype)initController:(BLEInitResultType)result;
{
  initResult = result;
  self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
  return self;
}


- (CBCharacteristic*)getCharacteristicWithUUID:(CBUUID*)uuid peripheral:(CBPeripheral*)peripheral
{
  for(CBService *s in peripheral.services)
  {
    for(CBCharacteristic *c in s.characteristics)
      if([c.UUID isEqual:uuid])
        return c;
  }

  return nil;
}

- (NSMutableArray*)foundedPeripherals
{
  if(_foundedPeripherals == nil)
    _foundedPeripherals = [[NSMutableArray alloc] init];
  return _foundedPeripherals;
}
- (void)stopScan
{
  [self.centralManager stopScan];
}
- (void)scanForPeripheralsNoDuplicatesWithServices:(NSArray*)serviceUUIDs timeOut:(NSTimeInterval)seconds withResult:(BLEScanResultType)result
{
  scanResult = result;
  [self.foundedPeripherals removeAllObjects];
  NSDictionary *scanOption = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
  [self.centralManager scanForPeripheralsWithServices:serviceUUIDs options:scanOption];
  if(seconds)
  {
    //scanTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(scanTimeOut:) userInfo:nil repeats:NO];
  }
  self.foundedPeripherals = nil;
}

- (void)scanTimeOut:(id)sender
{
  if (scanResult == nil)
    return;
  
  scanResult(nil, nil, nil,YES);
}

- (void)connectAndDiscService:(CBPeripheral*)p  withResult:(BLEConnectResultType)result
{
  NSLog(@"connectting to %@", p);
  connectResult = result;
  [self.centralManager connectPeripheral:p options:nil];
}
- (void)disconnect:(CBPeripheral*)p withResult:(BLEDisconnectResultType)result;
{
  NSLog(@"disconnect to %@", p);
  disconnectResult = result;
  [self.centralManager cancelPeripheralConnection:p];
}

- (void)writeValue:(NSData *)data forCharacteristicUUIDString:(NSString*)uuidString peripheral:(CBPeripheral *)peripheral withResult:(BLEWriteCharacResultType)result
{
  CBCharacteristic *c = [self getCharacteristicWithUUID:[CBUUID UUIDWithString:uuidString] peripheral:peripheral];
  [self writeValue:data forCharacteristic:c peripheral:peripheral withResult:result];
}
- (void)writeValue:(NSData*)data  forCharacteristic:(CBCharacteristic *)characteristic peripheral:(CBPeripheral*)peripheral withResult:(BLEWriteCharacResultType)result;
{
#define MAX_PACKET_LEN 20
  if(peripheral == nil || characteristic == nil)
  {
    NSLog(@"write value error: peripheral == %@ characteristic == %@", peripheral, characteristic);
  }
  NSLog(@"write value = %@ for peripheral = %@ Characteristic = %@", data, peripheral, characteristic);
  
  CBCharacteristicWriteType type;
  if(characteristic.properties & CBCharacteristicPropertyWrite)
    type = CBCharacteristicWriteWithResponse;
  else
  {
    type = CBCharacteristicWriteWithoutResponse;
    writeCharacResult = result;
  }
  
  if(peripheral && (peripheral.state == CBPeripheralStateConnected) && characteristic)
  {
    for(NSUInteger i = 0; i < data.length/MAX_PACKET_LEN; i++)
    {
      NSData *subData = [data subdataWithRange:NSMakeRange(i*MAX_PACKET_LEN, MAX_PACKET_LEN)];
      [peripheral writeValue:subData forCharacteristic:characteristic type:type];
    }
    NSUInteger remainder = data.length%MAX_PACKET_LEN;
    if(remainder)
    {
      NSData *subData = [data subdataWithRange:NSMakeRange(data.length - remainder, remainder)];
      [peripheral writeValue:subData forCharacteristic:characteristic type:type];

    }
      
  }
}
- (void)readValue:(NSData*)data forCharacteristic:(CBCharacteristic *)characteristic peripheral:(CBPeripheral *)peripheral withResult:(BLEReadCharacResultType)result
{
  readCharacResult = result;
}
- (void)setNotifyValue:(BOOL)enabled forCharacteristicUUIDString:(NSString*)uuidString peripheral:(CBPeripheral *)peripheral withResult:(BLEUpdateNotifyResultType)result
{
  CBCharacteristic *c = [self getCharacteristicWithUUID:[CBUUID UUIDWithString:uuidString] peripheral:peripheral];
  updateNotifyResult = result;
  if((c != nil) && (peripheral != nil))
    [self setNotifyValue:enabled forCharacteristic:c peripheral:peripheral];
}
- (void)setNotifyValue:(BOOL)enabled forCharacteristicUUID:(CBUUID*)uuid peripheral:(CBPeripheral *)peripheral withResult:(BLEUpdateNotifyResultType)result

{
  CBCharacteristic *c = [self getCharacteristicWithUUID:uuid peripheral:peripheral];
  updateNotifyResult = result;
  [peripheral setNotifyValue:enabled forCharacteristic:c];
}
- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic peripheral:(CBPeripheral*)peripheral 
{
  NSLog(@"set NotifyValue peripheral %@ characteristic %@", peripheral, characteristic);

  [peripheral setNotifyValue:enabled forCharacteristic:characteristic];
}
#pragma mark Bluetooth Central Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
  if(central.state == CBCentralManagerStatePoweredOn)
  {
    if(initResult)
    {
      initResult(central.state);
      initResult = nil;
    }
  }
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
  NSData *advData = advertisementData[CBAdvertisementDataManufacturerDataKey];
  if(advData.length != 22)
    return;
  
  NSLog(@"Founded Peripheral %@ rssi = %@",advertisementData, RSSI);
  
  if(scanResult == nil)
    return;

  //过滤重复发现的设备
  BOOL saved = NO;
  for(CBPeripheral *p in self.foundedPeripherals)
  {
    if([p.identifier isEqual:peripheral.identifier])
    {
      saved = YES;
      break;
    }
  }
  if(saved == NO)
  {
    [self.foundedPeripherals addObject:peripheral];
    scanResult(peripheral, advertisementData, RSSI, NO);

  }
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
  NSLog(@"didFailToConnectPeripheral to %@",peripheral);
  if(connectResult)
  {
    [self connectAndDiscService:peripheral withResult:connectResult];
  }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
  NSLog(@"did connected to %@", peripheral);
  self.connectedPeripheral = peripheral;
  self.connectedPeripheral.delegate = self;
  
  NSLog(@"start discover service");
  [self.connectedPeripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
  NSLog(@"did disconnect to %@ error = %@", peripheral, error);
  self.connectedPeripheral = nil;

  if(connectResult)
  {
    if(!error)
      error = [[NSError alloc] initWithDomain:@"Disconnect for unkown reason" code:0 userInfo:nil];
    connectResult(peripheral, error);
    connectResult = nil;
  }
  else if(disconnectResult)
  {
    disconnectResult(peripheral, error);
    disconnectResult = nil;
  }
  else
  {
    if(error == nil)
      error = [[NSError alloc] init];
    
    if([self.delegate respondsToSelector:@selector(BLEManagerDisconnectWithPeripheral:error:)])
    [self.delegate BLEManagerDisconnectWithPeripheral:peripheral error:error];
  }
}
#pragma mark Peripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
  if(error == nil)
  {
    for (CBService *s in peripheral.services)
    {
      NSLog(@"did discover service %@ peripheral %@", s, peripheral);
      [peripheral discoverCharacteristics:nil forService:s];
    }
  }
  else
  {
    NSLog(@"discover service failed");
    if(connectResult)
    {
      [self connectAndDiscService:peripheral withResult:connectResult];
    }
  }
    
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
  for(CBCharacteristic *c in service.characteristics)
    NSLog(@"did discovere characteristics %@ peripheral %@", c.UUID, peripheral);
  
  if(connectResult == nil)
    return;
  
  NSLog(@"discovered service %@",service);
  if(error == nil)
  {
    if(service == self.connectedPeripheral.services.lastObject)
    {
      NSLog(@"discover Characteristics Finished");
      connectResult(peripheral, nil);
      connectResult = nil;
    }
  }
  else
  {
    NSLog(@"didDiscoverCharacteristics Failed");
    [self connectAndDiscService:peripheral withResult:connectResult];
    connectResult = nil;
  }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
  if(error)
  {
    NSLog(@"failed to write value for characteristic = %@ error = %@", characteristic, error);
  }
  else
  {
    NSLog(@"did write value for characteristic = %@ peripheral%@ sucessfully", characteristic, peripheral);
  }
  if(writeCharacResult)
    writeCharacResult(peripheral, characteristic, error);
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
  NSLog(@"did update value = %@ for characteristic = %@ peripheral%@", characteristic.value, characteristic, peripheral);
  if(readCharacResult)
  {
    readCharacResult(peripheral, characteristic, error);
  }
  if([self.delegate respondsToSelector:@selector(BLEManagerRecvValueForPeripheral:characteristic:error:)])
  {
    [self.delegate BLEManagerRecvValueForPeripheral:peripheral characteristic:characteristic error:error];
  }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
  
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
  NSLog(@"did Update Notify = %d characteristic = %@ peripheral = %@ ",characteristic.isNotifying, characteristic, peripheral.name);

  if(updateNotifyResult)
    updateNotifyResult(peripheral, characteristic, error);
}

@end
