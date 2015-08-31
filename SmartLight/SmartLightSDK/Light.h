//
//  Light.h
//  SmartLight
//
//  Created by LevinYan on 3/5/15.
//  Copyright (c) 2015 BDE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreData/CoreData.h>
#import "DataPacket.h"
#import "BlueDevice.h"

#define SET_BITMAP_TO_BUF(bit, buf) (buf[bit/8] |= (1 << (bit%8)))

extern const NSUInteger kPageMask;
extern const NSUInteger quickControlCommandOffset;

typedef NS_ENUM(NSUInteger, ContolMode)
{
  NormalMode = 0,
  QuickMode,
  AllTypeMode,
};

@interface Light : BlueDevice


/**
 *  开关状态
 */
@property (strong, nonatomic) NSNumber *on;


/*
 * 灯的当前颜色
 */
@property (nonatomic, assign) Color color;

/*
 * 灯的分组
 */
@property (nonatomic, strong) NSString *groupID;

@property (nonatomic, strong) NSMutableArray *groupIdArr;

+ (NSData*)makeControlPayload:(NSArray*)lights mode:(ContolMode)mode color:(Color)color;

- (void)setColor:(Color)color;

- (void)saveLightColor;
- (void)loadLightData;
@end
