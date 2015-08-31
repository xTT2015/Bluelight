//
//  ColorPlateView.m
//  test
//
//  Created by xtmac on 19/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "ColorPlateView.h"
#import "UIImageView+ColorAtPixel.h"

@interface ColorPlateView (){
    float       _radius;
    UIImageView *_colorBox;
    NSTimeInterval _timeInterval;
}

@end

@implementation ColorPlateView

-(id)initWithColorPlateWithOrigin:(CGPoint)point withRadius:(float)radius{
    CGRect rect;
    rect.origin = point;
    rect.size = CGSizeMake(radius * 2, radius * 2);
    if (self = [super initWithFrame:rect]) {
        [self initView];
    }
    return self;
}

-(void)initView{
    _timeInterval = 0;
    _radius = self.frame.size.width / 2;
    //圆边
//    self.layer.masksToBounds = YES;
//    self.layer.cornerRadius = _radius;
    
    //创建取色框
    _colorBox = [[UIImageView alloc] initWithFrame:CGRectMake(_radius - 15, _radius - 15, 30, 30)];
    _colorBox.image = [UIImage imageNamed:@"ColorBox.png"];
    [self addSubview:_colorBox];
    
    //添加手势
    self.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(getColorPan:)];
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getColorPan:)];
    [self addGestureRecognizer:tap];
}

#pragma mark
#pragma mark 拖动手势
-(void)getColorPan:(UIGestureRecognizer*)pan{
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        _colorBox.hidden = NO;
        CGPoint point = [pan locationInView:pan.view];
        [self setPoint:point];
    }else if (pan.state == UIGestureRecognizerStateEnded){
        _colorBox.hidden = NO;
        CGPoint point = [pan locationInView:pan.view];
        _timeInterval = 0;
        [self setPoint:point];
    }
}

-(void)setPoint:(CGPoint)point{
    double w = point.x - _radius, h = point.y - _radius;
    double R = sqrt(w * w + h * h);
    if (R < _radius - 1) {
        
        
    }else{
        point.x = w * _radius / R + _radius - (w < 0 ? -2 : 2);
        point.y = h * _radius / R + _radius - (h < 0 ? -2 : 2);
        
    }
    _colorBox.center = point;
    RGBAColor color = [self colorAtPixel:point];
    if ([_delegate respondsToSelector:@selector(colorPlateGetColorRed:green:blue:)]) {
        [_delegate colorPlateGetColorRed:color.red green:color.green blue:color.blue];
    }
    [self quickControlWithRed:color.red withGreen:color.green withBlue:color.blue];
}

-(void)quickControlWithRed:(int)red withGreen:(int)green withBlue:(int)blue{
    
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    if (curTime - _timeInterval >= 0.2f) {
        _timeInterval = curTime;
        if ([_delegate respondsToSelector:@selector(colorPlateQuickControl:green:blue:)]) {
            [_delegate colorPlateQuickControl:red green:green blue:blue];
        }
    }
}

-(void)setIsControllable:(BOOL)isControllable{
    _isControllable = isControllable;
    _colorBox.hidden = !isControllable;
    self.userInteractionEnabled = isControllable;
}

-(void)setColorBoxIsVisible:(BOOL)isVisible{
    _isColorBoxVisible = isVisible;
    _colorBox.hidden = !isVisible;
}

-(void)setColorBoxCenterPoint:(CGPoint)point{
    point.x *= self.frame.size.width;
    point.y *= self.frame.size.height;
    _colorBox.center = point;
}

-(CGPoint)getColorBoxCenterPoint{
    return CGPointMake(_colorBox.center.x / self.frame.size.width, _colorBox.center.y / self.frame.size.height);
}

@end
