//
//  eidtLorGViewController.h
//  SmartLight
//
//  Created by xTT on 15/8/4.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "baseCollectionViewController.h"

@interface editlightCell : UICollectionViewCell

@property (weak, nonatomic)IBOutlet UIButton *delete_Btn;
@property (weak, nonatomic)IBOutlet UIImageView *add_ImgView;
@property (weak, nonatomic)IBOutlet UILabel *name_Label;

- (void)addView:(UIControl *)control target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end

@interface editLorGViewController : baseCollectionViewController

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn;

/*!
 *  组控制时为组对象，否则为空
 */
@property (strong, nonatomic) Group *editGroup;
@property (strong, nonatomic) NSNumber *groupIndex;

/**
 *  单灯控制时为灯对象，否则为空
 */
@property (strong, nonatomic) Light *editLight;

@end
