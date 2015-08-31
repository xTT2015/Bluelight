//
//  AbstractDevice.m
//  SmartLightLib
//
//  Created by LevinYan on 15/5/19.
//  Copyright (c) 2015年 mac mini. All rights reserved.
//

#import "BlueDevice.h"
#import "Commom.h"
#import "Network.h"
#import "AppDelegate.h"
#import "BLEManager.h"
#import "NSData+AES.h"
#import "Light.h"
#import "Remoter.h"
#import "BlueDeviceScanner.h"
static NSString *const kUnkownError = @"Unknow Error";
static const UInt8 kLightIdentifier[6] = {0xB4,0x00, 0x4D, 0x45, 0x53, 0x48};
static const UInt8 kHeadLenght = 3;
static const NSUInteger kInvalidNetworkID = -1;
typedef struct
{
  UInt8 deviceType;
  UInt32 networkID;
  UInt16 maxDeviceID;
  UInt16 deviceID;
  UInt8 address[6];
  
}AdvDataStruct;


static NSString* stringWithHexFormat(UInt8* bytes, NSUInteger length)
{
  
  NSMutableString *string = [NSMutableString stringWithCapacity:0];
  
  for(NSUInteger i = 0; i < length; i++)
  {
    [string appendFormat:@"%02X", bytes[i]];
  }
  return string;
}

@interface BlueDevice() <BLEManagerDelegate>

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMutableDictionary *respondBlocks;
@end

@implementation BlueDevice
@dynamic name;
@dynamic deviceID;
@dynamic deviceType;
@dynamic maxDeviceID;
@dynamic networkID;
@dynamic address;
@dynamic network;

@synthesize networkName;
@synthesize peripheral = _peripheral;
@synthesize isFound;
@synthesize isSaved;
@synthesize isAddedToNetwork;
@synthesize bleManager = _bleManager;
@synthesize lock = _lock;
@synthesize respondBlocks = _respondBlocks;

+ (instancetype)alloc
{
  __block BlueDevice *device;
  [[AppDelegate sharedAppDelegate].managedObjectContext performBlockAndWait:^{

    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext: [AppDelegate sharedAppDelegate].managedObjectContext];
    
    device = [[super alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    device.lock = [[NSLock alloc] init];
  }];
  
  return device;
}
+ (instancetype)createWithAdvData:(NSData*)advData
{
    if([self isRemoterAdvertising:advData])
        return [[Remoter alloc] initWithAdvData:advData];
    else
        return [[Light alloc] initWithAdvData:advData];
}

+ (instancetype)createWithAddress:(NSString*)address
                             name:(NSString *)name
                       deviceType:(NSNumber *)type
                        networkID:(NSNumber *)networkID
                         deviceID:(NSNumber *)deviceID
                      maxDeviceID:(NSNumber *)maxDeviceID
{
  if(type == RemoterType)
    return [[Remoter alloc] initWithWithAddress:address
                                           name:name
                                     deviceType:type
                                      networkID:networkID
                                       deviceID:deviceID
                                    maxDeviceID:maxDeviceID];
  else
    return [[Light alloc] initWithWithAddress:address
                                         name:name
                                   deviceType:type
                                    networkID:networkID
                                     deviceID:deviceID
                                  maxDeviceID:maxDeviceID];
}

- (instancetype)initWithWithAddress:(NSString*)address
                               name:(NSString *)name
                         deviceType:(NSNumber *)type
                          networkID:(NSNumber *)networkID
                           deviceID:(NSNumber *)deviceID
                        maxDeviceID:(NSNumber *)maxDeviceID
{
    self.address = address;
    self.name = name;
    self.deviceType = type;
    self.networkID = networkID;
    self.deviceID = deviceID;
    
  
    NSUInteger localMaxID = self.network.maxDeviceID.unsignedIntegerValue;
    NSUInteger newMaxID = [maxDeviceID unsignedIntegerValue];
    NSUInteger maxID = MAX(localMaxID, newMaxID);
    self.maxDeviceID = @(maxID);
    return self;
}
+ (instancetype)fetchWithAdvData:(NSData *)advData
{
  NSString *address = [self addressFromAdvData:advData];
  return [[self fetchWithAddress:address] initWithAdvData:advData];
}
+ (instancetype)fetchWithAddress:(NSString*)addressValue
{
  __block BlueDevice *device;
  [[AppDelegate sharedAppDelegate].managedObjectContext performBlockAndWait:^{
    
    NSFetchRequest *fectchRequst = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", NSStringFromPropery(address), addressValue];
    fectchRequst.predicate = predicate;
    device = [[AppDelegate sharedAppDelegate].managedObjectContext executeFetchRequest:fectchRequst error:nil].firstObject;

  }];
  return device;
}


- (BOOL)isFound
{
  return self.peripheral ? YES : NO;
}
- (BOOL)isAddedToNetwork
{
  if(self.networkID.unsignedIntegerValue == kInvalidNetworkID)
    return NO;
  else
    return YES;
}
- (BOOL)isSaved
{
  if([BlueDevice fetchWithAddress:self.address])
    return YES;
  return NO;
}
- (void)setMaxDeviceID:(NSNumber *)maxDeviceID
{
  NSString *key  = NSStringFromSelector(@selector(maxDeviceID));
  [self willChangeValueForKey:key];
  [self setPrimitiveValue:maxDeviceID forKey:key];
  [self didChangeValueForKey:key];
  
  self.network.maxDeviceID = maxDeviceID;
}
- (NSNumber*)maxDeviceID
{
  NSString *key = NSStringFromSelector(@selector(maxDeviceID));
  [self willAccessValueForKey:key];
  NSNumber *maxDeviceID = [self primitiveValueForKey:key];
  [self didAccessValueForKey:key];
  
  return maxDeviceID;
}

- (NSMutableDictionary*)respondBlocks
{
  if(_respondBlocks == nil)
    _respondBlocks = [[NSMutableDictionary alloc] init];
  return _respondBlocks;
}
- (void)setBleManager:(BLEManager *)bleManager
{
  _bleManager = bleManager;
}

- (void)setNotification:(BOOL)enable complete:(void(^)(NSError *error))complete
{
  __weak typeof(self) weakSelf = self;
  [self.bleManager setNotifyValue:enable forCharacteristicUUIDString:kControlCharacteristicUUID peripheral:self.peripheral withResult:^(CBPeripheral *p, CBCharacteristic *c, NSError *error) {
    
     [weakSelf.bleManager setNotifyValue:enable forCharacteristicUUIDString:kConfigurationCharacteristicUUID peripheral:weakSelf.peripheral withResult:^(CBPeripheral *p, CBCharacteristic *c, NSError *error) {
       
        complete(error);
       
     }];
    
  }];
 
}

- (void)reset
{
  CommandPacket *commandPacket = [CommandPacket makeCommandPacket:CommandResetLight payload:nil lenght:0];
  [self sendCommand:commandPacket respond:nil];
}

#pragma mark Command Respond Handle
- (void)setRespondBlock:(RespondBlock)respondBlock forCommandCode:(CommandCode)code
{
  [self.lock lock];
  self.respondBlocks[@(code)] = respondBlock;
  [self.lock unlock];
}
- (void)removeRespondBlock:(CommandCode)code
{
  [self.lock lock];
  [self.respondBlocks removeObjectForKey:@(code)];
  [self.lock unlock];
}
- (void)bleConnect:(void (^)(NSError *error))completeBlock
{
  __weak typeof(self) weakSelf = self;
  
  [self.bleManager connectAndDiscService:self.peripheral withResult:^(CBPeripheral *p, NSError *error) {

    //FIXME: 当连续两次调用，返回就出错
    weakSelf.bleManager.delegate = self;
    weakSelf.peripheral = p; //未知原因，peripheral会变成另外一个实例
    
    if(error == nil)
    {
      [weakSelf setNotification:YES complete:^(NSError *error) {
        if(completeBlock)
          completeBlock(error);
      }];
    }
    else
    {
      if(completeBlock)
        completeBlock(error);
    }
    
   
    
  }];
}
- (void)connect:(void (^)(NSError *))completeBlock
{
  __strong typeof(self) weakSelf = self;

  [self bleConnect:^(NSError *error) {
    
    if(error == nil && weakSelf.network != nil) //如果已经加入网络就进行认证
    {
      [weakSelf authenticate:^(NSError *error) {
        
        if(completeBlock)
          completeBlock(error);
        
      }];
    }
    else
    {
      if(completeBlock)
        completeBlock(error);
    }
    
  }];
}


- (NSError*)connectAndWaitComplete
{
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  
  __block NSError *error = nil;
  [self connect:^(NSError *_error)
   {
     error = _error;
     dispatch_semaphore_signal(sem);
   }];
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
  return error;
}

- (void)disconnect:(void (^)(NSError *))completeBlock
{
  [self.bleManager disconnect:self.peripheral withResult:^(CBPeripheral *p, NSError *error) {
    if(completeBlock)
      completeBlock(error);
  }];
}
- (void)sendCommand:(CommandPacket *)command respond:(RespondBlock)block
{
  if(block)
  {
    [self setRespondBlock:block forCommandCode:command.commandCode];
  }
  NSLog(@"send command %@", self);
  [self.bleManager writeValue:command.getData forCharacteristicUUIDString:command.characteristic peripheral:self.peripheral withResult:nil];
}

- (void)authenticate:(void (^)(NSError*))completeBlock
{
#define AuthCodeLen 16
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
      dispatch_semaphore_t sem = dispatch_semaphore_create(0);
      
      __block UInt8 requestRespondStatus = 0;
      UInt8 *randBuf = malloc(AuthCodeLen);
      CommandPacket *requestAuthCommandPacket = [CommandPacket makeCommandPacket:CommandRequestAuthenticate payload:NULL lenght:0];
      [weakSelf sendCommand:requestAuthCommandPacket respond:^(RespondPacket *respondPacket) {
        
        UInt8 *bytes = (UInt8*)respondPacket.payload.bytes;
        requestRespondStatus = bytes[0];
        if(requestRespondStatus == 0)
        {
          memcpy((void*)randBuf, (void*)&bytes[1], AuthCodeLen);
        }
        dispatch_semaphore_signal(sem);
        
      }];
      
      dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
      if(requestRespondStatus == 1)
      {
        if(completeBlock)
          completeBlock(nil);
      }
      else
      {
        NSData *authCode = [[NSData dataWithBytes:randBuf length:AuthCodeLen] AES128EncryptWithKey:weakSelf.network.password iv:self.network.password];
        CommandPacket *sendAuthCodeCommandPacket = [CommandPacket makeCommandPacket:CommandSendAuthenticateCode payload:authCode.bytes lenght:AuthCodeLen];
        [weakSelf sendCommand:sendAuthCodeCommandPacket respond:^(RespondPacket *respondPacket) {
          
          UInt8 status = ((UInt8*)respondPacket.payload.bytes)[0];
          NSError *error = nil;
          if(status != 0)
            error = [NSError errorWithDomain:kUnkownError code:status userInfo:nil];
          
          if(completeBlock)
            completeBlock(error);
          
        }];
      }
      
    });
}

- (void)identify:(void (^)())complete
{
  CommandPacket *commandPacket = [CommandPacket makeCommandPacket:CommandIdentifyLight payload:NULL lenght:0];
  [self sendCommand:commandPacket respond:^(RespondPacket *respondPacket) {
    if(complete)
      complete();
  }];
  
}
- (void)getFirmwareInfo:(FirmwareInfoType)type complete:(void (NSString *))completeBlock
{
  [self connectAndWaitComplete];
  CommandPacket *command = [CommandPacket makeCommandPacket:CommandGetFirmwareInfo payload:&type lenght:sizeof(type)];
  [self sendCommand:command respond:^(RespondPacket *respondPacket) {
    
  }];
}
- (BOOL)isRespondValid:(NSData*)data
{
  if(data != nil && data.length >= kHeadLenght)
  {
    UInt8 payloadLenght = ((UInt8*)data.bytes)[kHeadLenght - 1];
    if(data.length == (kHeadLenght + payloadLenght))
      return YES;
  }
  return NO;
}

- (void)handleRespond:(CBCharacteristic*)characteristic
{
    UInt8 *bytes = (UInt8*)characteristic.value.bytes;
    RespondCode code = bytes[1];
    UInt8 payloadLenght = bytes[2];
    if(code == RespondKeepLive)//保持底层连接
    {
        CommandPacket *commandPacket = [CommandPacket makeCommandPacket:CommandKeepLive payload:NULL lenght:0];
        [self sendCommand:commandPacket respond:nil];
        return;
    }
    RespondPacket *respondPacket = [RespondPacket makeRespondPacket:code payload:&bytes[3] lenght:payloadLenght];
    RespondBlock respondBlock = self.respondBlocks[@(respondPacket.commandCode)];
    if(respondBlock)
    {
      respondBlock(respondPacket);
      [self removeRespondBlock:respondPacket.commandCode];
    }
}
#pragma mark BLEManager Delegate
- (void)BLEManagerRecvValueForPeripheral:(CBPeripheral *)p characteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
  [self handleRespond:characteristic];
}

- (void)BLEManagerDisconnectWithPeripheral:(CBPeripheral *)p error:(NSError *)error
{
  
}

@end


@implementation BlueDevice(AdvParser)


+ (AdvDataStruct)parseAdvData:(NSData*)advData
{
  AdvDataStruct advDataStruct;
  UInt8 *bytes = (UInt8*)advData.bytes;
  
  advDataStruct.deviceType = bytes[6];
  advDataStruct.networkID = (bytes[7] | (bytes[8] << 8) | (bytes[9] << 16) | (bytes[10] << 24));
  advDataStruct.maxDeviceID = (bytes[11] | bytes[12] << 8) + 1;
  advDataStruct.deviceID = (bytes[13] | bytes[14] << 8);
  memcpy(advDataStruct.address, &bytes[16], sizeof(advDataStruct.address));
  return advDataStruct;
}
- (instancetype)initWithAdvData:(NSData *)advData
{
  __weak typeof(self) weakSelf = self;
  [[AppDelegate sharedAppDelegate].managedObjectContext performBlockAndWait:^{
    
    AdvDataStruct advDataStruct = [BlueDevice parseAdvData:advData];
    NSString* address = stringWithHexFormat(advDataStruct.address, sizeof(advDataStruct.address));
    DeviceType deviceType = advDataStruct.deviceType;
    NSUInteger networkID = advDataStruct.networkID;
    NSUInteger deviceID = advDataStruct.deviceID;
 
    NSUInteger localMaxID = self.network.maxDeviceID.unsignedIntegerValue;
    NSUInteger advMaxID = advDataStruct.maxDeviceID;
    NSUInteger maxID = MAX(localMaxID, advMaxID);
    (void)[weakSelf initWithWithAddress:address
                                   name:self.name
                             deviceType:@(deviceType)
                              networkID:@(networkID)
                               deviceID:@(deviceID)
                            maxDeviceID:@(maxID)];
  }];
  
  return self;
  
}


+ (NSString*)addressFromAdvData:(NSData*)advData
{
  AdvDataStruct advDataStruct = [BlueDevice parseAdvData:advData];
  return  stringWithHexFormat(advDataStruct.address, sizeof(advDataStruct.address));
}

+ (NSNumber*)networkIDFromAdvData:(NSData *)advData
{
  return @([BlueDevice parseAdvData:advData].networkID);
}

+ (BOOL)isSavedBlueDeviceAdvertising:(NSData*)advData
{
  if([self fetchWithAddress:[self addressFromAdvData:advData]])
    return YES;
  return NO;
}

+ (BOOL)isBlueDeviceAdvertising:(NSData *)advData
{
  if(advData && advData.length == 22)
  {
    UInt8 *bytes = (UInt8*)advData.bytes;
    if(memcmp(bytes, kLightIdentifier, sizeof(kLightIdentifier)) == 0)
      return YES;
  }
  return NO;
}

+ (BOOL)hasBlueDeviceAddedToNetwork:(NSData*)advData
{
  if([BlueDevice parseAdvData:advData].networkID == 0xFFFFFFFF)
    return NO;
  else
    return YES;
}

+ (BOOL)isRemoterAdvertising:(NSData*)advData
{
  UInt8 *bytes = (UInt8*)advData.bytes;
  UInt8 deviceType = bytes[6];
  if(deviceType == RemoterType)
    return YES;
  else
    return NO;
}


@end
