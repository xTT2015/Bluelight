//
//  SingleLightViewController.m
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "SingleLightViewController.h"


#define cellSwitchLight 200

@implementation lightCell

- (void)addView:(UIControl *)control target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [control addTarget:target action:action forControlEvents:controlEvents];
}

@end

@interface SingleLightViewController ()<NetworkDelegate>

@end

@implementation SingleLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.backBtn removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLight)
                                                 name:@"ConnectedLightChange"
                                               object:nil];
}

- (void)changeLight{
    if ([User currentUser].myNetWork.connectedLight) {
        self.connectBuleImage.image = [UIImage imageNamed:@"BlueStatus_1"];
    }else{
        self.connectBuleImage.image = [UIImage imageNamed:@"BlueStatus_0"];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData];
    [User currentUser].myNetWork.delegate = self;
    [[User currentUser].myNetWork startAutoConnect];
    [[User currentUser].myNetWork scanForBlueDevice:^(BlueDevice *device) {
        [self reloadData];
    }];
    
//    NSLog(@"%@",[User currentUser].myNetWork.lights.allObjects);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count = [User currentUser].myNetWork.scanedNewLights.count + [User currentUser].myNetWork.lights.count;
    if (count != 0) {
        _NOBuleImage.alpha = 0;
        _NOBuleLabel.alpha = 0;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    lightCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lightCell"
                                                                 forIndexPath:indexPath];

    if (indexPath.item < [User currentUser].myNetWork.lights.count) {
        Light *L = [User currentUser].myNetWork.lights.allObjects[indexPath.item];
        [cell.connect_Switch setOn:[L.on boolValue]];
        cell.name_Label.text = L.name;
        cell.state_ImageView.alpha = 0;
        cell.connect_Switch.alpha = 1;
    }else{
        BlueDevice *D = [User currentUser].myNetWork.scanedNewLights[indexPath.item - [User currentUser].myNetWork.lights.count];
        cell.name_Label.text = D.name;
        cell.state_ImageView.alpha = 1;
        cell.connect_Switch.alpha = 0;
    }
    [cell addView:cell.connect_Switch target:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];
    cell.connect_Switch.tag = cellSwitchLight + indexPath.item;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 3, collectionView.frame.size.height / 3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item < [User currentUser].myNetWork.lights.count) {
        if ([User currentUser].myNetWork.connectedLight) {
            [self performSegueWithIdentifier:@"goLightColor" sender:indexPath];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"尚未连接上蓝牙，请稍后再试"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }else{
        BlueDevice *Device = [User currentUser].myNetWork.scanedNewLights[indexPath.item - [User currentUser].myNetWork.lights.count];
        [Device connect:^(NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self performSegueWithIdentifier:@"goNewLight" sender:Device];
                });
            }
        }];
    }
}

- (void)reloadData{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.myCollectionView reloadData];
    });
}


- (void)switchClick:(UISwitch *)sender{
    if ([User currentUser].myNetWork.connectedLight) {
        NSInteger index = sender.tag - cellSwitchLight;
        Light *L = [User currentUser].myNetWork.lights.allObjects[index];
        Color color;
        if (sender.on) {
            L.on = @YES;
            color = L.color;
        }else{
            L.on = @NO;
            color = kColorOff;
        }
        [[User currentUser].myNetWork quicklyControlLights:@[L] color:color];
    }else{
        [sender setOn:!sender.on animated:YES];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"尚未连接上蓝牙，请稍后再试"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma netWrok

- (void)autoAddBlueDeviceNotify:(BlueDevice*)device{
    [self reloadData];
}

- (void)autoDeleteBlueDeviceNotify:(BlueDevice*)device{
    [[User currentUser].myNetWork deleteBlueDevice:device complete:^(NSError *error) {
        if (!error) {
            [[User currentUser].myNetWork deleteBlueDevice:device complete:^(NSError *error) {
                if (!error) {
                    [self reloadData];
                }
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"goLightColor"]) {
        NSIndexPath *indexPath = sender;
        Light *L = [User currentUser].myNetWork.lights.allObjects[indexPath.item];
        [segue.destinationViewController setValue:L forKey:@"playLight"];
    }if ([segue.identifier isEqualToString:@"goNewLight"]){
        [segue.destinationViewController setValue:sender forKey:@"blueDevice"];
    }
}

-(Color)controlLight:(Light*)light{
    Color color;
    bzero(&color, sizeof(Color));
    switch (light.deviceType.integerValue) {
        case ColorfulLight:{
            //彩色灯
            if (light.on) {
                //关闭
                color.red = color.green = color.blue = color.white = 0;
            }else{
                //开启
                color = makeColor(255, 255, 255, 255);
            }
        }
            break;
        case ColorTemperatureLight:{
            if (light.on) {
                //关闭
                color.warn = color.cold = 0;
            }else{
                //开启
                color.warn = color.cold = 255;
            }
        }
            break;
        case BrightnessLight:{
            if (light.on) {
                //关闭
                color.brightness = 0;
            }else{
                //开启
                color.brightness = 255;
            }
            //            light.on = !light.on;
        }
            break;
        case OutletLight:{
            color.on = !light.on;
            
        }
            break;
        default:
            break;
    }
    return color;
}



@end
