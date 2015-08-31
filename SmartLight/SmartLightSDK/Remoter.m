//
//  Remoter.m
//  SmartLightLib
//
//  Created by LevinYan on 15/5/19.
//  Copyright (c) 2015年 mac mini. All rights reserved.
//

#import "Remoter.h"
#import "Light.h"
#import "BLEManager.h"
#import "Network.h"

static NSString * kGetConfigureErrorDesc[] =
{
  nil,
  @"No Configure Infomation",
  @"No Add To Network",
  @"No Authentication",
};
@implementation Remoter


- (NSData*)makePayload:(NSArray*)lights deviceType:(RemoterControlDeviceType)deviceType color:(Color)color
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
  UInt8 payload[17] = {0x00};
  
  payload[0] = deviceType;
    
  switch (deviceType)
  {
    case RemoterControlOutletLight:
          payload[1] = color.on;
          break;
    case RemoterControlColofulLight:
      payload[1] = color.white;
      payload[2] = color.red;
      payload[3] = color.green;
      payload[4] = color.blue;
      break;
      
    case RemoterControlColorTemperatureLight:
      payload[1] = color.cold;
      payload[2] = color.warn;
      break;
      
    case RemoterControlBrightnessLight:
      payload[1] = color.brightness;
      break;
      
     default:
      break;
  }
  
  
  *((UInt16*)&payload[5]) = head;
  memcpy(&payload[7], bitmap, sizeof(bitmap));
  
  return [NSData dataWithBytes:payload length:sizeof(payload)];
}


- (void)configureToControl:(NSArray*)lights deviceType:(RemoterControlDeviceType)deviceType color:(Color)color complete:(void (^)(NSError *error))completeBlock
{
  NSData *payload = [self makePayload:lights deviceType:deviceType color:color];
  CommandPacket *command = [CommandPacket makeCommandPacket:CommandConfigureRemoter payload:payload.bytes lenght:payload.length];
  [self sendCommand:command respond:^(RespondPacket *respondPacket) {
    
    UInt8 status = ((UInt8*)respondPacket.payload.bytes)[0];
    NSError *error = nil;
    if(status)
      error = [NSError errorWithDomain:@"设备未加入网络" code:0 userInfo:nil];
    if(completeBlock)
      completeBlock(error);
    
  }];
}

- (void)getRemoterConfigureSuccess:(void (^)(RemoterControlDeviceType deviceType, NSArray *lights, Color color))successBlock
                       fail:(void (^)(NSError* error))failBlock
{
    CommandPacket *command = [CommandPacket makeCommandPacket:CommandGetRemoterConfigure payload:NULL lenght:0];
    [self sendCommand:command respond:^(RespondPacket *respondPacket) {
        
        UInt8 *bytes = (UInt8*)respondPacket.payload.bytes;
        UInt8 code = bytes[0];
        if(code != 0)
        {
          NSError *error = [NSError errorWithDomain:kGetConfigureErrorDesc[code] code:code userInfo:nil];
          if(failBlock)
          {
            failBlock(error);
          }
        }
        else
        {
          RemoterControlDeviceType deviceType = bytes[1];
          Color color;
          switch(deviceType)
          {
            case RemoterControlOutletLight:
              color.on = bytes[2];
              break;
              
            case RemoterControlColofulLight:
              color.white = bytes[2];
              color.red = bytes[3];
              color.green = bytes[4];
              color.blue = bytes[5];
              break;
              
            case RemoterControlColorTemperatureLight:
              color.cold = bytes[2];
              color.warn = bytes[3];
              break;
              
            case RemoterControlBrightnessLight:
              color.brightness = bytes[2];
              break;
            default:
              break;
          }
          NSArray *lights = [self.network bitmapPayloadToLights:&bytes[6]];
          if(successBlock)
            successBlock(deviceType, lights, color);
        }
    }];
    
}

@end
