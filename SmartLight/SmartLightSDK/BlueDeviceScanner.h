//
//  BlueDeviceScanner.h
//  SmartLightLib
//
//  Created by LevinYan on 15/6/5.
//  Copyright (c) 2015年 mac mini. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BlueDevice;
@class Light;
@class Remoter;
@interface BlueDeviceScanner : NSObject

- (void)scanForBlueDevice:(NSNumber *)networkID result:(void (^)(BlueDevice *blueDevice))result;
- (void)stopScan;
- (void)scanForLight:(NSNumber *)networkID result:(void (^)(Light *light))result;
- (void)scanForRemoter:(NSNumber *)networkID result:(void (^)(Remoter *remoter))result;
@end
