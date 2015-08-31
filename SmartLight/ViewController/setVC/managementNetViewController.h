//
//  managementNetViewController.h
//  SmartLight
//
//  Created by xTT on 15/7/28.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "baseTabViewController.h"

@interface managementNetViewController : baseTabViewController

@property (nonatomic ,weak)IBOutlet UILabel *titleLabel;

@property (nonatomic) BOOL isDelete;
@end
