//
//  AppDelegate.h
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIWindow *window;

+ (instancetype)sharedAppDelegate;

@end

