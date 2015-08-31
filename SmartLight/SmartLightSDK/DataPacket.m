//
//  DataPacket.m
//  SmartLight
//
//  Created by LevinYan on 3/23/15.
//  Copyright (c) 2015 BDE. All rights reserved.
  //

#import "DataPacket.h"

static const UInt8 kFixedHead = 0xFA;


@interface DataPacket()

@property (nonatomic, assign) UInt8 fixedHead;

@end

@implementation DataPacket

+ (instancetype)makeDataPacket:(DataPacketCodeType)code payload:(const void *)payload lenght:(UInt8)lenght
{
  DataPacket *dataPacket = [[[self class] alloc] init];
  dataPacket.fixedHead = kFixedHead;
  dataPacket.payload = [NSData dataWithBytes:payload length:lenght];
  return dataPacket;
}
- (NSData*)getData
{
  return nil;
}
@end



@implementation CommandPacket

- (NSArray*)configureCommand //0xFFB1
{
      return [NSArray arrayWithObjects:@(CommandAddLight),
                                       @(CommandDeleteLight),
                                       @(CommandIdentifyLight),
                                       @(CommandRequestAuthenticate),
                                       @(CommandSendAuthenticateCode),
                                       @(CommandChangeLightPassword),
                                       @(CommandKeepLive),
                                       @(CommandConfigureRemoter),
                                       @(CommandGetRemoterConfigure),
                                       @(CommandResetLight),
                                       nil];
}


- (NSString*)characteristicFromCode:(CommandCode)code
{
  for(NSNumber *c in self.configureCommand)
  {
    if(c.unsignedIntegerValue == code)
      return kConfigurationCharacteristicUUID;
  }
  return kControlCharacteristicUUID;
}
- (NSData*)getData
{
  UInt8 head[3];
  head[0] = self.fixedHead;
  head[1] = self.commandCode;
  head[2] = self.payload.length;
  
  NSMutableData *data = [NSMutableData dataWithCapacity:0];
  [data appendBytes:head length:sizeof(head)];
  [data appendData:self.payload];
  
  return data;
}
+ (instancetype)makeCommandPacket:(CommandCode)code payload:(const void *)payload lenght:(UInt8)lenght
{
  
  CommandPacket *commandPacket = [CommandPacket makeDataPacket:code payload:payload lenght:lenght];
  commandPacket.commandCode = code;
  commandPacket.respondCode = code + kRespondCommandOffset;
  commandPacket.characteristic = [commandPacket characteristicFromCode:code];
    return commandPacket;
}

@end


@implementation RespondPacket

+ (instancetype)makeRespondPacket:(RespondCode)code payload:(const void *)payload lenght:(UInt8)lenght
{
  RespondPacket *respondPacket = [RespondPacket makeDataPacket:code payload:payload lenght:lenght];
  respondPacket.respondCode = code;
  respondPacket.commandCode = code - kRespondCommandOffset;
    return respondPacket;
}

//- (BOOL)isRespondToCommand:(CommandPacket *)command
//{
//  if(self.code == (RespondCode)(command.commandCode + kRespondCommandOffset))
//    return YES;
//  else
//    return NO;
//}
- (NSData*)getData
{
  UInt8 head[3];
  head[0] = self.fixedHead;
  head[1] = self.respondCode;
  head[2] = self.payload.length;
  
  NSMutableData *data = [NSMutableData dataWithCapacity:0];
  [data appendBytes:head length:sizeof(head)];
  [data appendData:self.payload];
  
  return data;
}
@end
