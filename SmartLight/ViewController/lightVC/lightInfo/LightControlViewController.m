//
//  LightControllerViewController.m
//  BDEBluePlus
//
//  Created by xtmac on 19/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "LightControlViewController.h"



@interface LightControlViewController (){

    DeviceType curDeviceType;
    NSArray *_defaultColorArr;
    NSMutableArray *controlLightArr;
    Color initColor;
    Color controlColor;
}

@end

@implementation LightControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    controlLightArr = [NSMutableArray array];
    
    _groupManageView.layer.masksToBounds = YES;
    _groupManageView.layer.cornerRadius = 25;
    _groupManageView.layer.borderColor = [[UIColor colorWithRed:34 / 255.0 green:64 / 255.0 blue:122 / 255.0 alpha:1] CGColor];
    _groupManageView.layer.borderWidth = 2;
    
    [_colorPlate setImage:[UIImage imageNamed:@"ColorPlate.png"]];
    [_colorPlate initView];
    
    [_brightnessView initView];
    
    _defaultColorArr = @[[UIColor colorWithRed:1 green:0 blue:0 alpha:1],
                          [UIColor colorWithRed:0 green:1 blue:0 alpha:1],
                          [UIColor colorWithRed:0 green:0 blue:1 alpha:1],
                          [UIColor colorWithRed:1 green:1 blue:0 alpha:1],
                          [UIColor colorWithRed:1 green:0 blue:1 alpha:1],
                          [UIColor colorWithRed:0 green:1 blue:1 alpha:1]];
    [_defaultColorView setColorArr:_defaultColorArr];
    
    [_colorTemperatureValueView initView];
    
    if (_playLight) {
        controlColor = _playLight.color;
        initColor = _playLight.color;
        [controlLightArr addObject:_playLight];
        [self initViewIsLightControl];
    }else if (_playGroup){
        NSArray *lightG = [User currentUser].myNetWork.lights.allObjects;
        [lightG enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.groupIdArr containsObject:[NSString stringWithFormat:@"%@",_playGroup.groupId]]) {
                [controlLightArr addObject:obj];
                if (controlLightArr.count == 1) {
                    controlColor = obj.color;
                    initColor = obj.color;
                }
            }
        }];
        [self initViewIsGroupControl];
    }else if (_playRemoter){
        [self initViewIsRemoterControl];
    }
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_playLight) {
        [_titleBtn setTitle:_playLight.name forState:UIControlStateNormal];
    }else if (_playGroup){
        [controlLightArr removeAllObjects];
        NSArray *lightG = [User currentUser].myNetWork.lights.allObjects;
        [lightG enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.groupIdArr containsObject:[NSString stringWithFormat:@"%@",_playGroup.groupId]]) {
                [controlLightArr addObject:obj];
            }
        }];
        [_titleBtn setTitle:_playGroup.name forState:UIControlStateNormal];
    }else if (_playRemoter){
        [_titleBtn setTitle:_playRemoter.name forState:UIControlStateNormal];
    }
}

-(void)initView{
    switch (curDeviceType) {
        case ColorfulLight:{    //彩色灯
            _defaultColorView.hidden = NO;
            _colorPlate.hidden = NO;
            _colorTemperatureValueView.hidden = YES;
            _brightnessView.hidden = NO;
            [_colorPlate setColorBoxIsVisible:NO];
//            [_colorPlate setColorBoxCenterPoint:CGPointMake(_controlConfig.colorfulLightPointX.floatValue, _controlConfig.colorfulLightPointY.floatValue)];
            [_colorPlate setImage:[UIImage imageNamed:@"RGBLight.png"]];
            [_brightnessView setBrightness:128];
            [_brightnessView setColor:[UIColor colorWithRed:controlColor.red / 255.0
                                                      green:controlColor.green / 255.0
                                                       blue:controlColor.blue / 255.0
                                                      alpha:1]];
            _lightBtn1.backgroundColor = [UIColor colorWithRed:18 / 255.0 green:44 / 255.0 blue:92 / 255.0 alpha:1];
            _lightBtn2.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:54 / 255.0 blue:107 / 255.0 alpha:1];
            _lightBtn3.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:54 / 255.0 blue:107 / 255.0 alpha:1];
        }
            break;
        case ColorTemperatureLight:{    //色温灯
            _defaultColorView.hidden = YES;
            _colorPlate.hidden = YES;
            _colorTemperatureValueView.hidden = NO;
            _brightnessView.hidden = YES;
            [_colorTemperatureValueView setWarn:controlColor.warn];
            [_colorTemperatureValueView setCold:controlColor.cold];
            
            _lightBtn1.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:54 / 255.0 blue:107 / 255.0 alpha:1];
            _lightBtn2.backgroundColor = [UIColor colorWithRed:18 / 255.0 green:44 / 255.0 blue:92 / 255.0 alpha:1];
            _lightBtn3.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:54 / 255.0 blue:107 / 255.0 alpha:1];
        }
            break;
        case BrightnessLight:{    //亮度灯
            _defaultColorView.hidden = YES;
            _colorPlate.hidden = YES;
            _colorTemperatureValueView.hidden = YES;
            _brightnessView.hidden = NO;
            [_brightnessView setColor:[UIColor yellowColor]];
            [_brightnessView setBrightness:controlColor.brightness];
            _lightBtn1.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:54 / 255.0 blue:107 / 255.0 alpha:1];
            _lightBtn2.backgroundColor = [UIColor colorWithRed:26 / 255.0 green:54 / 255.0 blue:107 / 255.0 alpha:1];
            _lightBtn3.backgroundColor = [UIColor colorWithRed:18 / 255.0 green:44 / 255.0 blue:92 / 255.0 alpha:1];
        }
            break;
        default:
            break;
    }
}

//当面板是灯控制面板的时候掉调用此方法
-(void)initViewIsLightControl{
    _groupManageView.hidden = YES;
    curDeviceType = _playLight.deviceType.intValue;
    [_titleBtn setTitle:_playLight.name forState:UIControlStateNormal];
    [self initView];
}

//当控制面板为组控制面板的时候调用此方法
-(void)initViewIsGroupControl{
    curDeviceType = ColorfulLight;
    [_titleBtn setTitle:_playGroup.name forState:UIControlStateNormal];
    [self initView];
}

//当控制面板为随意控控制面板的时候调用此方法
-(void)initViewIsRemoterControl{
    _groupManageView.hidden = YES;
    [_titleBtn setTitle:_playRemoter.name forState:UIControlStateNormal];
    [self initView];
}

-(void)setRemoter:(Remoter *)remoter withColor:(Color)color withRemoterControlDeviceType:(RemoterControlDeviceType)remoterControlDeviceType{
    switch (remoterControlDeviceType) {
        case RemoterControlColofulLight:{
//            _controlConfig.white = @(0);
//            _controlConfig.red = @(color.red * color.white / 255);
//            _controlConfig.red = @(color.green * color.white / 255);
//            _controlConfig.blue = @(color.blue * color.white / 255);
            curDeviceType = ColorfulLight;
        }
            break;
        case RemoterControlColorTemperatureLight:{
//            _controlConfig.warn = @(color.warn);
//            _controlConfig.cold = @(color.cold);
            curDeviceType = ColorTemperatureLight;
        }
            break;
        case RemoterControlBrightnessLight:{
//            _controlConfig.brightness = @(color.brightness);
            curDeviceType = BrightnessLight;
        }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark Button Action

- (void)goBack{
    if (controlLightArr.count > 0) {
        Light *L = controlLightArr[0];
        if ([L.on boolValue]) {
            [self quickControlWithColor:initColor];
        }
    }
    [super goBack];
}

- (IBAction)_confirmBtnTouchUpInsideAction {
    [controlLightArr enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
        obj.on = @YES;
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeCurLightType:(UIButton *)sender {
    curDeviceType = (int)sender.tag;
    [self initView];
}


-(void)quickControlWithColor:(Color)color{
    [controlLightArr enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
        [obj setColor:color];
    }];
    [[User currentUser].myNetWork quicklyControlLights:controlLightArr color:color];
}

#pragma mark
#pragma mark ColorPlateView Delegate
-(void)colorPlateGetColorRed:(unsigned int)red green:(unsigned int)green blue:(unsigned int)blue{
    controlColor.red = red;
    controlColor.green = green;
    controlColor.blue = blue;
//    [_controlConfig setRed:[NSNumber numberWithInt:red]];
//    [_controlConfig setGreen:[NSNumber numberWithInt:green]];
//    [_controlConfig setBlue:[NSNumber numberWithInt:blue]];
//    [_controlConfig setIsDefaultColor:@0];
//    
//    CGPoint point = [_colorPlate getColorBoxCenterPoint];
//    [_controlConfig setColorfulLightPointX:[NSNumber numberWithFloat:point.x]];
//    [_controlConfig setColorfulLightPointY:[NSNumber numberWithFloat:point.y]];
    [_brightnessView setColor:[UIColor colorWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1]];
}

-(void)colorPlateQuickControl:(unsigned int)red green:(unsigned int)green blue:(unsigned int)blue{
    [self quickControlWithColor:makeColor(0,
                                          red * _brightnessView.getBrightness / 255,
                                          green * _brightnessView.getBrightness / 255,
                                          blue * _brightnessView.getBrightness / 255)];
}

#pragma mark
#pragma mark BrightnessView Delegate
-(void)brightnessViewGetBrightness:(int)brightness{
    switch (curDeviceType) {
        case ColorfulLight:{
            //彩色灯
//            [_controlConfig setWhite:[NSNumber numberWithInt:brightness]];
        }
            break;
        case BrightnessLight:{
            //亮度灯
//            [_controlConfig setBrightness:[NSNumber numberWithInt:brightness]];
        }
            break;
        default:
            break;
    }
    controlColor.brightness = brightness;
}

-(void)brightnessViewQuickControlWithBrightness:(int)brightness{
    switch (curDeviceType) {
        case ColorfulLight:{
            //彩色灯
        
            [self quickControlWithColor:makeColor(0,
                                                  controlColor.red * brightness / 255.0,
                                                  controlColor.green * brightness / 255.0,
                                                  controlColor.blue * brightness / 255.0)];
        }
            break;
        case BrightnessLight:{
            //亮度灯
            Color color = {0x0};
            color.brightness = brightness;
            [self quickControlWithColor:color];
        }
            break;
        default:
            break;
    }
    
    
}

#pragma mark
#pragma mark ColorTemperatureValueView Delegate
-(void)colorTemperatureWithWarn:(unsigned int)warn withCold:(unsigned int)cold{
    controlColor.warn = warn;
    controlColor.cold = cold;
}

-(void)colorTemperatureQuickControlWithWarn:(unsigned int)warn withCold:(unsigned int)cold{
//    Color color = {0x0};
    controlColor.warn = warn;
    controlColor.cold = cold;
    [self quickControlWithColor:controlColor];
}

#pragma mark
#pragma mark DefaultColorView Delegate
-(void)defaultColorGetColorIndex:(int)index{
//    [_controlConfig setIsDefaultColor:@1];
//    [_controlConfig setDefaultColorIndex:[NSNumber numberWithInt:index]];
    switch (index) {
        case 0:{
            controlColor.red = 255;
            controlColor.green = 0;
            controlColor.blue = 0;
        }
            break;
        case 1:{
            controlColor.red = 0;
            controlColor.green = 255;
            controlColor.blue = 0;
        }
            break;
        case 2:{
            controlColor.red = 0;
            controlColor.green = 0;
            controlColor.blue = 255;
        }
            break;
        case 3:{
            controlColor.red = 255;
            controlColor.green = 255;
            controlColor.blue = 0;
        }
            break;
        case 4:{
            controlColor.red = 255;
            controlColor.green = 0;
            controlColor.blue = 255;
        }
            break;
        case 5:{
            controlColor.red = 0;
            controlColor.green = 255;
            controlColor.blue = 255;
        }
            break;
        default:
            break;
    }
    [self quickControlWithColor:makeColor(0,
                                          controlColor.red * _brightnessView.getBrightness / 255,
                                          controlColor.green * _brightnessView.getBrightness / 255,
                                          controlColor.blue * _brightnessView.getBrightness / 255)];
//    [self quickControlWithColor:controlColor];
    
    [_colorPlate setColorBoxIsVisible:NO];
    [_brightnessView setColor:[UIColor colorWithRed:controlColor.red / 255.0
                                              green:controlColor.green / 255.0
                                               blue:controlColor.blue / 255.0
                                              alpha:1]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (_playGroup) {
        [segue.destinationViewController setValue:@([[User currentUser].myGroups indexOfObject:[_playGroup keyValues]])
                                           forKey:@"groupIndex"];
        [segue.destinationViewController setValue:_playGroup forKey:@"editGroup"];
    }else if (_playLight){
        [segue.destinationViewController setValue:_playLight forKey:@"editLight"];
    }
}

@end