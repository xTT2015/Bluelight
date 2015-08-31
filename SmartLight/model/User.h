//
//  User.h
//  SmartLight
//
//  Created by xTT on 15/7/14.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Network.h"

#import "Group.h"

#import "MJExtension.h"


@interface User : NSObject

@property (strong, nonatomic) Network *myNetWork;

@property (strong, nonatomic) NSMutableArray *myGroups;


+ (User *)currentUser;

- (void)saveGroups;

@end
