//
//  DefaultColorView.m
//  test
//
//  Created by xtmac on 19/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "DefaultColorView.h"

@implementation DefaultColorView

-(void)setColorArr:(NSArray *)colorArr{
    CGFloat w = (270 - (colorArr.count - 1) * 10) / colorArr.count, h = self.frame.size.height;
    for (int i = 0; i < colorArr.count; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((w + 10) * i, 0, w, h)];
        view.backgroundColor = colorArr[i];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 3;
        view.tag = i;
        [self addSubview:view];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(defaultColorTap:)];
        [view addGestureRecognizer:tap];
    }
}

-(void)defaultColorTap:(UITapGestureRecognizer*)tap{
    if ([_delegate respondsToSelector:@selector(defaultColorGetColorIndex:)]) {
        [_delegate defaultColorGetColorIndex:(int)tap.view.tag];
    }
}

@end
