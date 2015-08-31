//
//  SingleLightViewController.h
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "baseCollectionViewController.h"

@interface lightCell : UICollectionViewCell

@property (weak, nonatomic)IBOutlet UIImageView *state_ImageView;
@property (weak, nonatomic)IBOutlet UILabel *name_Label;
@property (weak, nonatomic)IBOutlet UISwitch *connect_Switch;


- (void)addView:(UIControl *)control target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end

@interface SingleLightViewController : baseCollectionViewController

@property (weak, nonatomic) IBOutlet UIImageView *connectBuleImage;

@property (weak, nonatomic) IBOutlet UIImageView *NOBuleImage;
@property (weak, nonatomic) IBOutlet UILabel *NOBuleLabel;

@end
