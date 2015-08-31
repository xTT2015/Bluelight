//
//  NewNetworkViewController.m
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "NewNetworkViewController.h"

#import "AppDelegate.h"


@interface NewNetworkViewController ()

@end

@implementation NewNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goLightVC:(UIButton *)sender{
    if (_nameField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入名称" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }else if (_passwordField.text.length == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入密码" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }else if (_confirmPasswordField.text.length == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请再次输入名称" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }else if (![_passwordField.text isEqualToString:_confirmPasswordField.text]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请两次输入的密码不一样" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }else{
        Network *testNetwork = [Network newNetwork:_nameField.text
                                          password:_passwordField.text];
        [[NetworkManager sharedManager] addNetwork:testNetwork];
        [User currentUser].myNetWork = testNetwork;
        [self performSegueWithIdentifier:@"goLightVC" sender:sender];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
