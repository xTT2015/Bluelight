//
//  GroupListViewController.h
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "baseCollectionViewController.h"

@interface lightGroupCell : UICollectionViewCell

@property (weak, nonatomic)IBOutlet UILabel *name_Label;
@property (weak, nonatomic)IBOutlet UISwitch *connect_Switch;
@property (weak, nonatomic)IBOutlet UIImageView *imageView_G;


- (void)addView:(UIControl *)control target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end

@interface GroupListViewController : baseCollectionViewController

@end
