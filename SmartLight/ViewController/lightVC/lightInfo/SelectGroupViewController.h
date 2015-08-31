//
//  SelectGroupViewController.h
//  BDEBluePlus
//
//  Created by xtmac on 18/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GroupObject;


@protocol SelectGroupViewControllerDelegate <NSObject>

-(void)SelectGroupDidSelectGroup:(GroupObject*)group;

@end

@interface SelectGroupViewController : UIViewController

@property (assign, nonatomic) id<SelectGroupViewControllerDelegate> delegate;

@end
