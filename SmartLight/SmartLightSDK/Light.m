//
//  Light.m
//  SmartLight
//
//  Created by LevinYan on 3/5/15.
//  Copyright (c) 2015 BDE. All rights reserved.
//

#import "Light.h"
#import "Network.h"
#import "AppDelegate.h"
#import "BLEManager.h"
#import "NSData+AES.h"


const NSUInteger kPageMask = 8;
const NSUInteger quickControlCommandOffset = 4;


static NSString* const kChangeLightPasswordErrorDesc[] =
{
  nil,
  @"Failed: Invalid Parameter",
  @"Failed: Not Add to Network",
  @"Failed: Not Authentication",
};



@implementation Light

@dynamic name;
@dynamic deviceID;
@dynamic networkID;
@dynamic address;
@dynamic network;
@dynamic groupID;
@dynamic on;

@synthesize color = _color;
@synthesize groupIdArr;

+ (NSData*)makeControlPayload:(NSArray*)lights mode:(ContolMode)mode color:(Color)color
{
  //page(13bit) + lenght(3bit) + bitmap(10Byte)
  NSArray *sortLights = [lights sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    
    Light *light1 = obj1;
    Light *light2 = obj2;
    if(light1.deviceID.unsignedIntegerValue > light2.deviceID.unsignedIntegerValue)
      return NSOrderedDescending;
    else
      return NSOrderedAscending;
  }];
  
  //TODO:暂时不支持分为多个page
  Light *minDeviceIDLight = sortLights.firstObject;
  UInt16 page = minDeviceIDLight.deviceID.unsignedIntegerValue/kPageMask;
  UInt16 head = 0x05 | (page << 3);
  UInt8 bitmap[10] = {0x00};
  for(Light *light in sortLights)
  {
    UInt8 bit = light.deviceID.unsignedIntegerValue - page*kPageMask;
    SET_BITMAP_TO_BUF(bit, bitmap);
  }
  UInt8 payload[18] = {0x00};
  
  payload[0] = minDeviceIDLight.deviceType.unsignedCharValue;
  DeviceType deviceType = payload[0];
  if(mode == AllTypeMode)
  {
    payload[0] = 0x08;
    payload[1] = color.on;
  }
  else
  {
    if(mode == QuickMode)
      payload[0] += quickControlCommandOffset;
    
    switch (deviceType)
    {
      case ColorfulLight:
            payload[2] = color.white;
            payload[3] = color.red;
            payload[4] = color.green;
            payload[5] = color.blue;
            break;
        
      case ColorTemperatureLight:
            payload[2] = color.cold;
            payload[3] = color.warn;
            break;
        
      case BrightnessLight:
            payload[2] = color.brightness;
            break;
        
      case OutletLight:
            payload[2] = color.on;
            break;
      default:
            break;
    }
  
  }
  *((UInt16*)&payload[6]) = head;
  memcpy(&payload[8], bitmap, sizeof(bitmap));
  
  return [NSData dataWithBytes:payload length:sizeof(payload)];
}


- (void)dealloc
{
  
}
- (void)makeChangePasswordPayload:(UInt8*)buf password:(NSString*)password
{
  srand((unsigned)time(NULL));
  UInt32 randCode = rand();
  UInt8 data[16] = {0x0};
  memcpy(data, (void *)&randCode, sizeof(randCode));
  NSData *randPlaintext = [NSData dataWithBytes:data length:sizeof(data)];
  NSData *randChiphertext = [randPlaintext AES128DecryptWithKey:self.network.password iv:self.network.password];
  
  NSData *newPasswordData = [password dataUsingEncoding:NSUTF8StringEncoding];
  NSData *newPasswordChipherText = [newPasswordData AES128DecryptWithKey:self.network.password iv:self.network.password];
  
  memcpy(buf, &randCode, sizeof(randCode));
  memcpy(&buf[4], randChiphertext.bytes, 4);
  memcpy(&buf[8], newPasswordChipherText.bytes, 16);
}

- (void)changePassword:(NSString*)newPassword  complete:(void (^)(NSError *error))completeBlock
{
    [self connect:^(NSError *error) {
      UInt8 payload[24];
      [self makeChangePasswordPayload:payload password:newPassword];
      CommandPacket *commandPacket = [CommandPacket makeCommandPacket:CommandChangeLightPassword payload:payload lenght:sizeof(payload)];
      [self sendCommand:commandPacket respond:^(RespondPacket *respondPacket) {
        
        UInt8 status = ((UInt8*)respondPacket.payload.bytes)[1];
        NSError *error = nil;
        if(status)
        {
          error = [NSError errorWithDomain:kChangeLightPasswordErrorDesc[status] code:status userInfo:nil];
        }
        
        if(completeBlock)
          completeBlock(error);
      }];

    }];
    
}

- (void)setColor:(Color)color{
    _color = color;
    [self saveLightColor];
}

- (void)saveLightColor{
    NSString *key = [NSString stringWithFormat:@"%@_color",self.address];
    [[NSUserDefaults standardUserDefaults] setObject:[NSData dataWithBytes:&_color length:sizeof(_color)]
                                              forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"保存颜色 %@",[NSData dataWithBytes:&_color length:sizeof(_color)]);
}

- (void)loadLightData{
    NSString *key = [NSString stringWithFormat:@"%@_color",self.address];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];

    if (data) {
        [data getBytes:&_color length:sizeof(_color)];
        NSLog(@"读取颜色 %@",data);
    }else{
        _color = kColorOn;
    }
    NSLog(@"%@",self.groupID);
    NSLog(@"%@",[self.groupID componentsSeparatedByString:@","]);
    NSArray *arr = [self.groupID componentsSeparatedByString:@","];
    self.groupIdArr = [[NSMutableArray alloc] initWithArray:arr];
//    _color = *(Color *)[value pointerValue];
}


//-(BOOL)on{
//  _on = false;
//  switch (self.deviceType.intValue) {
//    case ColorfulLight:{
//      if (_color.red || _color.green || _color.blue) {
//        _on = true;
//      }
//    }
//      break;
//    case ColorTemperatureLight:{
//      if (_color.warn || _color.cold) {
//        _on = true;
//      }
//    }
//      break;
//    case BrightnessLight:{
//      if (_color.brightness) {
//        _on = true;
//      }
//    }
//      break;
//    case OutletLight:{
//      _on = _color.on;
//    }
//      break;
//    default:
//      break;
//  }
//  return _on;
//}

@end
