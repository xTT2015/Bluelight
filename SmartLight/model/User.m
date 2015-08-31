//
//  User.m
//  SmartLight
//
//  Created by xTT on 15/7/14.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "User.h"

@implementation User


+ (User *)currentUser
{
    static User *_user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _user = [[User alloc] init];
    });
    return _user;
}

- (instancetype)init
{
    self = [super init];
    
    return self;
}

- (void)setMyNetWork:(Network *)myNetWork{
    if (_myNetWork) {
        [[_myNetWork kvoController] unobserve:[User currentUser].myNetWork keyPath:@"connectedLight"];
    }

    _myNetWork = myNetWork;
    [self loadGroupsWithNetWorkID:myNetWork.networkID];
    
    FBKVOController *fbKVO = [[User currentUser].myNetWork kvoController];
    [fbKVO observe:[User currentUser].myNetWork
           keyPath:@"connectedLight" options:NSKeyValueObservingOptionOld
             block:^(id observer, id object, NSDictionary *change) {
                 dispatch_async(dispatch_get_main_queue(), ^(void) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectedLightChange"
                                                                         object:nil];
                 });
             }];
}

- (void)saveGroups{
    NSString* libraryDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES)[0];
    NSString* filePath = [libraryDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",_myNetWork.networkID]];
    [_myGroups writeToFile:filePath atomically:YES];
}

- (void)loadGroupsWithNetWorkID:(NSNumber *)netWorkID{
    NSString* libraryDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES)[0];
    NSString* filePath = [libraryDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",netWorkID]];
    
    _myGroups = [NSMutableArray arrayWithContentsOfFile:filePath];
    if (!_myGroups) {
        _myGroups = [NSMutableArray arrayWithArray:@[@{@"name":@"默认分组",@"groupId":@(0)}]];
    }
}
@end
