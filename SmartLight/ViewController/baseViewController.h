//
//  baseViewController.h
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkManager.h"

#import "User.h"

@interface baseViewController : UIViewController<UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *backBtn;
- (void)goBack;

@end
