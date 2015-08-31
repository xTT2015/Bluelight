//
//  addLtoGViewController.h
//  SmartLight
//
//  Created by xTT on 15/8/4.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "baseCollectionViewController.h"

@interface addLightCell : UICollectionViewCell

@property (weak, nonatomic)IBOutlet UIImageView *state_ImageView;
@property (weak, nonatomic)IBOutlet UILabel *name_Label;

@end

@interface addLtoGViewController : baseCollectionViewController


@property (strong, nonatomic) NSNumber *groupId;
@end
