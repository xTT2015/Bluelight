//
//  DataPacket.h
//  SmartLight
//
//  Created by LevinYan on 3/23/15.
//  Copyright (c) 2015 BDE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

static NSString *const kServiceUUID                      = @"0xFFB0";
static NSString *const kControlCharacteristicUUID        = @"0xFFB3";
static NSString *const kConfigurationCharacteristicUUID  = @"0xFFB1";

typedef UInt8 DataPacketCodeType;

static const UInt8 kRespondCommandOffset = 0x80;

typedef NS_ENUM(DataPacketCodeType, CommandCode)
{
  CommandControlLight             = 0x01,
  CommandGetAllLights             = 0x02,
  CommandChangeNetworkPassword    = 0x03,
  CommandRequestAuthenticate      = 0x11,
  CommandSendAuthenticateCode     = 0x12,
  CommandAddLight                 = 0x13,
  CommandIdentifyLight            = 0x14,
  CommandDeleteLight              = 0x15,
  CommandChangeLightPassword      = 0x16,
  CommandKeepLive                 = 0x17,
  CommandConfigureRemoter         = 0x18,
  CommandGetRemoterConfigure      = 0x19,
  CommandGetFirmwareInfo          = 0x31,
  CommandResetLight               = 0x1F,
};

typedef NS_ENUM(DataPacketCodeType, RespondCode)
{
  RespondControlLight             = CommandControlLight             + kRespondCommandOffset,
  RespondGetAllLights             = CommandGetAllLights             + kRespondCommandOffset,
  RespondChangeNetworkPassword    = CommandChangeNetworkPassword    + kRespondCommandOffset,
  RespondRequestAuthenticate      = CommandRequestAuthenticate      + kRespondCommandOffset,
  RespondSendAuthenticateCode     = CommandSendAuthenticateCode     + kRespondCommandOffset,
  RespondAddLight                 = CommandAddLight                 + kRespondCommandOffset,
  RespondDeleteLight              = CommandDeleteLight              + kRespondCommandOffset,
  RespondChangeLightPassword      = CommandChangeLightPassword      + kRespondCommandOffset,
    RespondKeepLive               = CommandKeepLive                 + kRespondCommandOffset,
  RespondConfigureRemoter         = CommandConfigureRemoter        + kRespondCommandOffset,
  RespondGetRemoterConfigure      = CommandGetRemoterConfigure     +   kRespondCommandOffset,
};


typedef struct
{
  UInt8 white;
  UInt8 red;
  UInt8 green;
  UInt8 blue;
  UInt8 warn;
  UInt8 cold;
  UInt8 brightness;
  BOOL  on;
}Color;

typedef NS_ENUM(NSUInteger, ControlAction)
{
  ControlActionChangeColor = 0x00,
  ControlActionTurnOff,
  ControlActionTurnOn,
};

static const Color kColorOff = {0, 0, 0, 0};
static const Color kColorOn  = {0xFF, 0xFF, 0xFF, 0xFF};
CG_INLINE Color makeColor(UInt8 white, UInt8 red, UInt8 green, UInt8 blue)
{
  Color color;
  color.white = white;
  color.red = red;
  color.green = green;
  color.blue = blue;
  return color;
}
@interface DataPacket : NSObject

@property (nonatomic, strong) NSData * payload;
@property (nonatomic, assign) CommandCode commandCode;
@property (nonatomic, assign) RespondCode respondCode;

- (NSData*)getData;

@end


@interface CommandPacket : DataPacket

@property (nonatomic, strong) NSString * characteristic;


+ (instancetype)makeCommandPacket:(CommandCode)code payload:(const void *)payload lenght:(UInt8)lenght;

@end


@interface RespondPacket : DataPacket


+ (instancetype)makeRespondPacket:(RespondCode)code payload:(const void *)payload lenght:(UInt8)lenght;
//- (BOOL)isRespondToCommand:(CommandPacket*)command;
@end
