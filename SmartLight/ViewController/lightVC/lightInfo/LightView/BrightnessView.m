//
//  BrightnessView.m
//  test
//
//  Created by xtmac on 19/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "BrightnessView.h"

@interface BrightnessView (){
    UIView      *_colorView;
    UIImageView *_colorBox;
    NSTimeInterval _timeInterval;
}

@end

@implementation BrightnessView

-(id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

-(void)initView{
    
    _timeInterval = 0;
    
    self.backgroundColor = [UIColor clearColor];
    
    _colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height * 2 / 3)];
    _colorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    _colorView.layer.masksToBounds = YES;
    _colorView.layer.cornerRadius = _colorView.frame.size.height / 2;
    _colorView.userInteractionEnabled = YES;
    _colorView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_colorView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:_colorView.frame];
    imageView.image = [UIImage imageNamed:@"Mask.png"];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = _colorView.frame.size.height / 2;
    [self addSubview:imageView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(getBrightnessPan:)];
    [_colorView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getBrightnessPan:)];
    [_colorView addGestureRecognizer:tap];
    
    _colorBox = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
    _colorBox.userInteractionEnabled = YES;
    _colorBox.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);;
    _colorBox.image = [UIImage imageNamed:@"ColorBox.png"];
    [self addSubview:_colorBox];
    
    [_colorBox addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(getBrightnessPan:)]];
    
}

-(void)setColor:(UIColor *)color{
    _colorView.backgroundColor = color;
}

-(int)getBrightness{
    return (int)((_colorBox.center.x - _colorView.frame.origin.x) * 255 / _colorView.frame.size.width);
}

-(void)setBrightness:(int)brightness{
    CGPoint point;
    point.y = self.frame.size.height / 2;
    point.x = brightness / 255.0 * _colorView.frame.size.width + _colorView.frame.origin.x;
    _colorBox.center = point;
}

#pragma mark
#pragma mark 拖动手势
-(void)getBrightnessPan:(UIGestureRecognizer*)pan{
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [pan locationInView:self];
        [self setPoint:point];
    }else if(pan.state == UIGestureRecognizerStateEnded){
        CGPoint point = [pan locationInView:self];
        _timeInterval = 0;
        [self setPoint:point];
    }
}

-(void)setPoint:(CGPoint)point{
    point.y = self.frame.size.height / 2;
    if (point.x < _colorView.frame.origin.x){
        point.x = _colorView.frame.origin.x;
    }else if (point.x > _colorView.frame.origin.x + _colorView.frame.size.width){
        point.x = _colorView.frame.origin.x + _colorView.frame.size.width;
    }
    _colorBox.center = point;
    if ([_delegate respondsToSelector:@selector(brightnessViewGetBrightness:)]) {
        [_delegate brightnessViewGetBrightness:[self getBrightness]];
    }
    [self quickControlWithBrightness:[self getBrightness]];
}

-(void)quickControlWithBrightness:(int)brightness{
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    if (curTime - _timeInterval >= 0.2f) {
        _timeInterval = curTime;
        if ([_delegate respondsToSelector:@selector(brightnessViewQuickControlWithBrightness:)]) {
            [_delegate brightnessViewQuickControlWithBrightness:brightness];
        }
    }
}



@end
