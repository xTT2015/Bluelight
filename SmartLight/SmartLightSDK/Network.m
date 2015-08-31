//
//  Network.m
//  SmartLight
//
//  Created by LevinYan on 3/19/15.
//  Copyright (c) 2015 BDE. All rights reserved.
//

#import "Network.h"
#import "Light.h"
#import "AppDelegate.h"
#import "BLEManager.h"
#import "NSData+AES.h"
#import "Commom.h"
#import "DataPacket.h"
#import "Remoter.h"
#import "BlueDeviceScanner.h"


static  NSString* const kAddLightErrorDesc[] =
{
    nil,
    @"Failed: Invalid Parameter",
    nil,
    @"Failed: No Password Authentication",
    @"Failed: Have Added to Network",
};
static const NSUInteger kPasswordFixedLenght = 16;



typedef struct
{
  UInt8 len;
  UInt16 offset;
  UInt8 data[10];
}BitmapStruct;


@interface Network()

@property (nonatomic, strong) BlueDeviceScanner *autoConnectScanner;
@property (nonatomic, strong) BlueDeviceScanner *scanner;
@property (nonatomic, strong) BlueDeviceScanner *inNetworkScanner;
@property (nonatomic, strong) FBKVOController *kvoController;

@end



@implementation Network

@dynamic name;
@dynamic password;
@dynamic networkID;
@dynamic maxDeviceID;
@dynamic lights;
@dynamic remoters;

@synthesize delegate = _delegate;
@synthesize connected = _connected;
@synthesize connectedLight = _connectedLight;
@synthesize scanedNewLights = _scanedNewLights;
@synthesize scanedNewRemoters = _scanedNewRemoters;
@synthesize autoConnectScanner = _autoConnectScanner;
@synthesize inNetworkScanner = _inNetworkScanner;
@synthesize scanner = _scanner;
@synthesize kvoController = _kvoController;

+ (instancetype)newNetwork
{
  __block Network *network;
  [[AppDelegate sharedAppDelegate].managedObjectContext performBlockAndWait:^{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Network class]) inManagedObjectContext: [AppDelegate sharedAppDelegate].managedObjectContext];
    
    network = (Network*)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
    
  }];
 
  return network;
}


+ (instancetype)newNetwork:(NSString *)name password:(NSString *)password networkID:(NSNumber*)networkID{
  __block Network *network;
  [[AppDelegate sharedAppDelegate].managedObjectContext performBlockAndWait:^{
    network = [self newNetwork];
    network.name = name;
    network.password = password;
    network.networkID = networkID;
  }];
  
  return network;
}

+ (instancetype)newNetwork:(NSString *)name password:(NSString *)password
{
  srand((unsigned)time(0));
  return [Network newNetwork:name password:password networkID:[NSNumber numberWithUnsignedInteger:rand()]];
}

- (void)dealloc
{
    NSLog(@"%@ %@", [self class], NSStringFromSelector(_cmd));
}
- (NSMutableArray*)scanedNewLights
{
  if(_scanedNewLights == nil)
    _scanedNewLights = [NSMutableArray arrayWithCapacity:0];
  
  return _scanedNewLights;
}

- (NSMutableArray*)scanedNewRemoters
{
  if(_scanedNewRemoters == nil)
    _scanedNewRemoters = [NSMutableArray arrayWithCapacity:0];
  
  return _scanedNewRemoters;
}
- (FBKVOController*)kvoController
{
  if(_kvoController == nil)
    _kvoController = [[FBKVOController alloc] initWithObserver:self retainObserved:YES];
  return _kvoController;
}
- (void)importBlueDevice:(BlueDevice *)device
{
  [self _addBlueDevice:device];
}

- (void)_addBlueDevice:(BlueDevice*)device
{
  device.networkID = self.networkID;
  device.deviceID  = self.maxDeviceID;
  self.maxDeviceID = [NSNumber numberWithUnsignedInteger:self.maxDeviceID.unsignedIntegerValue + 1];
  
  [self.managedObjectContext insertObject:device];
  
  if([device isMemberOfClass:[Light class]])
    [self addLightsObject:(Light*)device];
  else
    [self addRemotersObject:(Remoter*)device];
  
  device.network = self;
  [self.managedObjectContext save:nil];
}
- (void)_addNewBlueDevice:(BlueDevice*)device
{
  __weak typeof(self) weakSelf = self;
  [self.managedObjectContext performBlockAndWait:^{
    device.networkID = self.networkID;
    device.deviceID  = self.maxDeviceID;
    weakSelf.maxDeviceID = [NSNumber numberWithUnsignedInteger:self.maxDeviceID.unsignedIntegerValue + 1];
    [weakSelf _addBlueDevice:device];
  }];
}
- (void)_addSavedBlueDevice:(BlueDevice*)device
{
  __weak typeof(self) weakSelf = self;
  [self.managedObjectContext performBlockAndWait:^{
    weakSelf.maxDeviceID = device.maxDeviceID ;
    [weakSelf _addBlueDevice:device];
  }];
}
- (void)_deleteBlueDevice:(BlueDevice*)device
{
  __weak typeof(self) weakSelf = self;
  [self.managedObjectContext performBlockAndWait:^{
    if([device isMemberOfClass:[Light class]])
    [weakSelf removeLightsObject:(Light *)device];
    else
      [weakSelf removeRemotersObject:(Remoter*)device];
  }];
}

- (void)setPassword:(NSString *)password
{
    NSMutableString *fixedLenghtPassword = [NSMutableString stringWithString:password];
    NSUInteger needLength = kPasswordFixedLenght - fixedLenghtPassword.length;
    for(NSUInteger i = 0; i < needLength; i++)
        [fixedLenghtPassword appendString:@"0"];
    
    NSString *key = NSStringFromPropery(password);
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:fixedLenghtPassword forKey:key];
    [self didChangeValueForKey:key];
    
}

- (NSArray*)getLightsWithType:(DeviceType)type
{
  NSMutableArray *lights = [NSMutableArray arrayWithCapacity:0];
  for(Light *light in self.lights.allObjects)
  {
    if(light.deviceType.unsignedIntegerValue == type)
      [lights addObject:light];
  }
  return lights;
}

- (void)setConnectedLight:(Light *)connectedLight
{
    __weak typeof(self) weakSelf = self;
    _connectedLight = connectedLight;
    if(_connectedLight){
        NSLog(@"auto connect start KVO");
        [self.kvoController observe:_connectedLight.peripheral
                            keyPath:NSStringFromPropery(state)
                            options:NSKeyValueObservingOptionOld
                              block:^(id observer, id object, NSDictionary *change) {
                                  if(weakSelf.connectedLight.peripheral.state == CBPeripheralStateDisconnected)
                                  {
                                      NSLog(@"auto connect disconnect");
                                      [weakSelf handleDisconnect];
                                      [weakSelf startAutoConnect];
                                      
                                  }
                              }];
    }
}

- (void)startAutoConnect{
    if(self.connectedLight && self.connectedLight.peripheral.state == CBPeripheralStateDisconnected){
        [self handleDisconnect];
    }
  
    __weak typeof(self) weakSelf = self;
    [self.autoConnectScanner stopScan];
    self.autoConnectScanner = [[BlueDeviceScanner alloc] init];
    NSLog(@"start auto connect");
    [self.autoConnectScanner scanForLight:self.networkID result:^(Light *light) {

        NSLog(@"auto connect found  %@", light);
        [light loadLightData];
    
        if(weakSelf.connectedLight != nil)
            return;
    
        weakSelf.connectedLight = light;
    
        __strong typeof(weakSelf) sself = weakSelf;
        NSLog(@"start auto connecting %@ peripheral %@", weakSelf.connectedLight, weakSelf.connectedLight.peripheral);
        [light connect:^(NSError *error) {
    
            if(error)
            {
                NSLog(@"auto connect error %@", error);
                [sself handleDisconnect];
                [sself startAutoConnect];
            }
            else
            {
                NSLog(@"auto connect success light %@ peripheral %@", weakSelf.connectedLight, weakSelf.connectedLight.peripheral);
            }
        }];
  }];
}
- (void)handleDisconnect
{
    [self.kvoController unobserve:self.connectedLight.peripheral keyPath:NSStringFromPropery(state)];
    self.connectedLight = nil;
}

- (void)stopAutoConnect
{
  NSLog(@"stop Auto Connect %@ %@", self.connectedLight, self.connectedLight.peripheral);
  [self.kvoController unobserve:self.connectedLight.peripheral keyPath:NSStringFromPropery(state)];
  __weak typeof(self) weakSelf = self;
    [self.connectedLight disconnect:^(NSError *error) {
      
      weakSelf.connectedLight = nil;
        
    }];
}
- (void)scanForBlueDevice:(void(^)(BlueDevice *device))resultBlock
{
  [self.scanedNewLights removeAllObjects];
  [self.scanedNewRemoters removeAllObjects];
  
  __weak typeof(self) weakSelf = self;
  [self.scanner stopScan];
  self.scanner = [[BlueDeviceScanner alloc] init];
  [self.scanner scanForBlueDevice:nil result:^(BlueDevice *device) {
    
    if(!device.isAddedToNetwork)
    {
      if([device isMemberOfClass:[Light class]])
        [weakSelf.scanedNewLights addObject:device];
      else
        [weakSelf.scanedNewRemoters addObject:device];
      
      resultBlock(device);
    }
    else if([device.networkID isEqualToNumber:weakSelf.networkID])
    {
      if(!device.isSaved)
      {
        //如果未保存在列表中，就自动添加到列表中
        [weakSelf _addSavedBlueDevice:device];
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(autoAddBlueDeviceNotify:)])
          [weakSelf.delegate autoAddBlueDeviceNotify:device];
      }
    }
    
  }];
}

- (void)stopScanForBlueDevice
{
  
}

- (void)scanForBlueDeviceOfNetwork:(void (^)(BlueDevice *))resultBlock
{
  self.inNetworkScanner = [[BlueDeviceScanner alloc] init];
  [self.inNetworkScanner scanForBlueDevice:self.networkID result:^(BlueDevice *blueDevice) {
    
      if(resultBlock)
        resultBlock(blueDevice);
  }];
}

- (void)stopScanForBlueDeviceOfNetwork
{
  [self.inNetworkScanner stopScan];
}

- (void)addBlueDevice:(BlueDevice*)device complete:(void (^)(NSError *))completeBlock
{
  //network(4) + deviceID(2) + networkPassword(16) + networkNameLenght(1) + networkName(networkNameLenght) (networkNameLenght <= 20);
  
    
    UInt8 payload[4 + 2 + 16 + 1 + 20] = {0x00};
    *((UInt32 *)&payload[0]) = self.networkID.unsignedIntValue;
    *((UInt16 *)&payload[4]) = self.maxDeviceID.unsignedShortValue;
    strncpy((char*)&payload[6], self.password.UTF8String, 16);
    payload[22] = (self.name.length < 20 ? self.name.length : 20);
    strncpy((char*)&payload[23], self.name.UTF8String, 20);
    
    
    CommandPacket *commandPacket = [CommandPacket makeCommandPacket:CommandAddLight payload:payload lenght:sizeof(payload)];
    __weak typeof(self) weakSelf = self;
    [device sendCommand:commandPacket respond:^(RespondPacket *respondPacket)
     {
       UInt8 status = ((UInt8*)respondPacket.payload.bytes)[0];
       NSError *error = nil;
       if(status != 0)
       {
         error = [NSError errorWithDomain:kAddLightErrorDesc[status] code:status userInfo:nil];
       }
       else
       {
         [weakSelf _addBlueDevice:device];
         [device disconnect:nil];
       }
       
       if(completeBlock)
         completeBlock(error);
     }];

}


- (void)deleteBlueDevice:(BlueDevice *)device complete:(void (^)(NSError *))completeBlock
{

  __weak typeof(self) weakSelf = self;

 [device connect:^(NSError *error) {
   
   if(error)
   {
     completeBlock(error);
     return;
   }
   
   CommandPacket *commandPacket = [CommandPacket makeCommandPacket:CommandDeleteLight payload:NULL lenght:0];
   [device sendCommand:commandPacket respond:^(RespondPacket *respondPacket) {
     
     [weakSelf _deleteBlueDevice:device];
     [device disconnect:nil];
     
     if(completeBlock)
       completeBlock(error);
   }];
    
  }];
}

- (BlueDevice*)getBlueDeviceWithID:(NSNumber*)deviceID
{
  for(Light *light in self.lights.allObjects)
  {
    if([light.deviceID isEqualToNumber:deviceID])
      return light;
  }
  for(Remoter *remoter in self.remoters.allObjects)
  {
    if([remoter.deviceID isEqualToNumber:deviceID])
      return remoter;
  }
  return nil;
}
- (Light*)getLightWithDeviceID:(NSNumber*)deviceID
{
  for(Light *light in self.lights.allObjects)
  {
    if([light.deviceID isEqualToNumber:deviceID])
      return light;
  }
  return nil;
}


- (void)disconnect:(void (^)(NSError *))completeBlock
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.connectedLight disconnect:^(NSError *error) {
      if(completeBlock)
        completeBlock(error);
    }];
  });
}



- (void)makeChangePasswordPayload:(UInt8*)buf password:(NSString*)password
{
  srand((unsigned)time(NULL));
  UInt32 randCode = rand();
  UInt8 data[16] = {0x0};
  memcpy(data, (void *)&randCode, sizeof(randCode));
  NSData *randPlaintext = [NSData dataWithBytes:data length:sizeof(data)];
  NSData *randChiphertext = [randPlaintext AES128DecryptWithKey:self.password iv:self.password];
  
  NSData *newPasswordData = [password dataUsingEncoding:NSUTF8StringEncoding];
  NSData *newPasswordChipherText = [newPasswordData AES128DecryptWithKey:self.password iv:self.password];
  
  memcpy(buf, &randCode, sizeof(randCode));
  memcpy(&buf[4], randChiphertext.bytes, 4);
  memcpy(&buf[8], newPasswordChipherText.bytes, 16);
}




- (void)changePassowrdForNetwork:(NSString*)newPassword result:(void (^)(NSArray *lights))resultBlock
{
  UInt8 payload[24];
  [self makeChangePasswordPayload:payload password:newPassword];
  CommandPacket *commandPacket = [CommandPacket makeCommandPacket:CommandChangeNetworkPassword payload:payload lenght:sizeof(payload)];
  __weak typeof(self) weakSelf = self;
  [self.connectedLight sendCommand:commandPacket respond:^(RespondPacket *respondPacket) {
    
    UInt8 *bytes = (UInt8*)respondPacket.payload.bytes;
    NSArray *lights = [weakSelf bitmapPayloadToLights:&bytes[5]];
    if(resultBlock)
      resultBlock(lights);
  }];
}

- (BitmapStruct) payloadToBitmap:(const UInt8*)payload
{
  BitmapStruct bitmapStruct;
  bitmapStruct.len = (payload[0] & 0x0F)*2;
  UInt16 offset = *((UInt16*)payload);
  bitmapStruct.offset = offset >> 4;
  memcpy(bitmapStruct.data, &payload[2], bitmapStruct.len);
  return bitmapStruct;
}
- (void)bitmapTopayloa:(BitmapStruct)bitmapStruct payload:(UInt8 *)payload
{
  *((UInt16*)payload) = (bitmapStruct.offset << 4) | bitmapStruct.len;
  memcpy(&payload[2], bitmapStruct.data, bitmapStruct.len*2);
}

- (NSArray*)bitmapPayloadToLights:(UInt8*)payload
{
  BitmapStruct bitmapStruct = [self payloadToBitmap:payload];
  NSUInteger bitmapCount = bitmapStruct.len*8;
  NSUInteger i = 0;
  UInt8 *bitmapData = bitmapStruct.data;
  NSMutableArray *lights = [NSMutableArray array];
  while(i < bitmapCount)
  {
    NSUInteger byteIndex = i/8;
    NSUInteger bitmapOffsetInByte = i%8;
    if((bitmapData[byteIndex] & (1 << bitmapOffsetInByte)))
    {
      NSUInteger deviceID = bitmapStruct.offset * kPageMask + i;
      Light *light = [self getLightWithDeviceID:[NSNumber numberWithUnsignedInteger:deviceID]];
      if(light)
        [lights addObject:light];
    }
    i++;
  }
  
  return lights;
}

- (void)identifyConnectedLight
{
  [self.connectedLight identify:nil];
}

- (void)lights:(NSArray*)lights ToBitmap:(UInt8*)bytes
{
  
}


- (void)_controlLights:(NSArray *)lights mode:(ContolMode)mode color:(Color)color result:(void (^)(NSArray *))resultBlock
{
  //page(13bit) + lenght(3bit) + bitmap(10Byte)
 
  NSData *payload = [Light makeControlPayload:lights mode:mode color:color];
  
  CommandPacket *command = [CommandPacket makeCommandPacket:CommandControlLight payload:payload.bytes lenght:payload.length];
  __weak typeof(self) weakSelf = self;
  [self.connectedLight sendCommand:command respond:^(RespondPacket *respondPacket) {
    
    UInt8 *bytes = (UInt8*)respondPacket.payload.bytes;
    Color color;
    NSArray *lights = [weakSelf bitmapPayloadToLights:&bytes[6]];
    Light *light = lights.firstObject;
    DeviceType deviceType = light.deviceType.unsignedIntegerValue;
    switch(deviceType)
    {
        case ColorfulLight:
        color = makeColor(bytes[2], bytes[3], bytes[4], bytes[5]);
        break;
        
        case ColorTemperatureLight:
        color.warn = bytes[2];
        color.cold = bytes[3];
        break;
        
        case BrightnessLight:
        color.brightness = bytes[2];
        break;
        
        case OutletLight:
        color.on = bytes[3];
        break;
        
        default:
        break;
    }
    
    for(Light *light in lights)
      light.color = color;
    
    if(resultBlock)
      resultBlock(lights);
    
  }];

}
- (void)controlLights:(NSArray*)lights color:(Color)color result:(void (^)(NSArray *lights))resultBlock
{
  [self _controlLights:lights mode:NormalMode color:color result:^(NSArray *lights) {
    
    if(resultBlock)
      resultBlock(lights);
    
  }];
}

- (void)controlAllTypeLights:(NSArray *)lights on:(BOOL)on
{
  Color color = {0x0};
  color.on = on;
  [self _controlLights:lights mode:AllTypeMode color:color result:nil];
}
- (void)quicklyControlLights:(NSArray *)lights color:(Color)color
{
  [self _controlLights:lights mode:QuickMode color:color result:nil];
}

- (BOOL)isBlueDeviceInNetwork:(BlueDevice*)device
{
    if([device.networkID isEqualToNumber:self.networkID])
        return YES;
    else
        return NO;
}



@end
