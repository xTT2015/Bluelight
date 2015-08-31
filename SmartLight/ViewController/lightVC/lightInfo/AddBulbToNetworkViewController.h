//
//  AddBulbToNetworkViewController.h
//  BDEBluePlus
//
//  Created by xtmac on 15/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "baseViewController.h"


@interface AddBulbToNetworkViewController : baseViewController

@property (strong, nonatomic) BlueDevice *blueDevice;

@property (weak, nonatomic) IBOutlet UIImageView *blubImageView;
@property (weak, nonatomic) IBOutlet UIButton    *addToNetworkBtn;
@property (weak, nonatomic) IBOutlet UIButton    *chooseGroupBtn;
@property (weak, nonatomic) IBOutlet UITextField *lightNameField;

@property (nonatomic) BOOL bAdd;

@end
