//
//  ColorTemperatureValueView.m
//  SmartLight
//
//  Created by xtmac on 5/6/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "ColorTemperatureValueView.h"

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

@interface ColorTemperatureValueView (){
    UIImageView *_mainImageView;
    UIImageView *_colorBox;
    NSTimeInterval _timeInterval;
}

@end

@implementation ColorTemperatureValueView

-(void)initView{
    _timeInterval = 0;
    
    _mainImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, WIDTH - 30, HEIGHT - 30)];
    [self addSubview:_mainImageView];
    
    [_mainImageView setImage:[UIImage imageNamed:@"ColorTemp.png"]];
    
    //创建取色框
    _colorBox = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 - 15, 30, 30)];
    _colorBox.image = [UIImage imageNamed:@"ColorBox.png"];
    [self addSubview:_colorBox];
    
    //添加手势
    _mainImageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
    [_mainImageView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
    [self addGestureRecognizer:tap];
    
    _colorBox.userInteractionEnabled = YES;
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
    [_colorBox addGestureRecognizer:pan];
}

-(void)setWarn:(unsigned int)warn{
    CGPoint point = _colorBox.center;
    point.x = warn / 255.0 * (WIDTH - 30) + 15;
    _colorBox.center = point;
}

-(void)setCold:(unsigned int)cold{
    CGPoint point = _colorBox.center;
    point.y = HEIGHT - (cold / 255.0 * (HEIGHT - 30) + 15);
    _colorBox.center = point;
}

-(void)handPan:(UIGestureRecognizer*)pan{
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [pan locationInView:self];
        [self setPoint:point];
    }else if (pan.state == UIGestureRecognizerStateEnded){
        _timeInterval = 0;
        CGPoint point = [pan locationInView:self];
        [self setPoint:point];
    }
}

-(void)setPoint:(CGPoint)point{
    if (point.x < 15) point.x = 15;
    if (point.x > WIDTH - 15) point.x = WIDTH - 15;
    if (point.y < 15) point.y = 15;
    if (point.y > HEIGHT - 15) point.y = HEIGHT - 15;
    
    _colorBox.center = point;
    
    _warn = (point.x - 15) / (WIDTH - 30) * 255;
    _cold = (HEIGHT - (point.y - 15) / (HEIGHT - 30) * 255);
    if ([_delegate respondsToSelector:@selector(colorTemperatureWithWarn:withCold:)]) {
        [_delegate colorTemperatureWithWarn:_warn withCold:_cold];
    }
    [self quickControlWithWarn:_warn withCold:_cold];
}

-(void)quickControlWithWarn:(unsigned int)warn withCold:(unsigned int)cold{
    
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    if (curTime - _timeInterval >= 0.2f) {
        _timeInterval = curTime;
        if ([_delegate respondsToSelector:@selector(colorTemperatureQuickControlWithWarn:withCold:)]) {
            [_delegate colorTemperatureQuickControlWithWarn:warn withCold:cold];
        }
    }
}

@end
