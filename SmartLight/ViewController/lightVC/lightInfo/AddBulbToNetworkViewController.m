//
//  AddBulbToNetworkViewController.m
//  BDEBluePlus
//
//  Created by xtmac on 15/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "AddBulbToNetworkViewController.h"



@interface AddBulbToNetworkViewController ()<UIActionSheetDelegate>{
    int groupId;
}

@end

@implementation AddBulbToNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    groupId = 0;
    
    _addToNetworkBtn.layer.masksToBounds = YES;
    _addToNetworkBtn.layer.cornerRadius = 5;
    
    _lightNameField.layer.masksToBounds = YES;
    _lightNameField.layer.cornerRadius = 5;
    _lightNameField.layer.borderWidth = 2;
    _lightNameField.layer.borderColor = [[UIColor colorWithRed:34/255.0 green:64/255.0 blue:122/255.0 alpha:1] CGColor];
    _lightNameField.text = _blueDevice.name;
    CGRect rect = _lightNameField.frame;
    rect.size.width = 10;
    UIView *leftView = [[UIView alloc] initWithFrame:rect];
    _lightNameField.leftViewMode = UITextFieldViewModeAlways;
    _lightNameField.leftView = leftView;
    
    _chooseGroupBtn.layer.masksToBounds = YES;
    _chooseGroupBtn.layer.cornerRadius = 5;
    _chooseGroupBtn.layer.borderWidth = 2;
    _chooseGroupBtn.layer.borderColor = [[UIColor colorWithRed:34/255.0 green:64/255.0 blue:122/255.0 alpha:1] CGColor];
    if (_blueDevice.deviceType.intValue == RemoterType) {
        _chooseGroupBtn.enabled = NO;
    }
    
    _blubImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Light_Big_0%d.png", [_blueDevice.deviceType intValue]]];
}

- (IBAction)hideKeyboard {
    [self.view endEditing:YES];
}

-(void)setBlueDevice:(BlueDevice *)blueDevice{
    _blueDevice = blueDevice;
}

- (IBAction)backBtnAction {
    [_blueDevice disconnect:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
#pragma mark Button Action
- (IBAction)flashBtnAction {
    [_blueDevice identify:^{}];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        NSDictionary *dic = [User currentUser].myGroups[buttonIndex - 1];
        groupId = [dic[@"groupId"] intValue];
        [_chooseGroupBtn setTitle:dic[@"name"] forState:UIControlStateNormal];
    }
}

- (IBAction)selectGroupBtnAction {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    [[User currentUser].myGroups enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        [sheet addButtonWithTitle:obj[@"name"]];
    }];
    [sheet showInView:self.view];
}

- (IBAction)addBulbToNetworkBtnAction {
    NSString *lightName = _lightNameField.text;
    if (_lightNameField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"设备名称不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (lightName.length > 16) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"设备名称不能超过16个字符" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
        
    [[User currentUser].myNetWork addBlueDevice:_blueDevice complete:^(NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本地添加失败" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [alert show];
            });
        }else{
            NSLog(@"本地添加完成");
            [_blueDevice setName:lightName];
            if([_blueDevice isKindOfClass:[Light class]]) {
                Light *l = (Light *)_blueDevice;
                l.groupID = [NSString stringWithFormat:@"%d",groupId];
                [l loadLightData];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [super goBack];
            });
        }
    }];
}

@end
