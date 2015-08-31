//
//  baseTabViewController.h
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "baseViewController.h"

@interface baseTabViewController : baseViewController

@property (nonatomic, weak) IBOutlet UITableView *myTableView;

@property (nonatomic, strong) NSMutableArray *sourceArr;
@end
