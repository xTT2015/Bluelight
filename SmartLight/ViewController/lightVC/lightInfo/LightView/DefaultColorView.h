//
//  DefaultColorView.h
//  test
//
//  Created by xtmac on 19/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DefaultColorViewDelegate <NSObject>

@optional
-(void)defaultColorGetColorIndex:(int)index;

@end

@interface DefaultColorView : UIView

@property (assign, nonatomic) IBOutlet id<DefaultColorViewDelegate> delegate;

@property (strong, nonatomic, readonly) NSArray *colorArr;

-(void)setColorArr:(NSArray *)colorArr;

@end
