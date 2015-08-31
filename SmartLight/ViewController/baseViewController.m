//
//  baseViewController.m
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "baseViewController.h"

@interface baseViewController ()

@end

@implementation baseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"01_02back_normal.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(20, 20, 36, 36);
    [_backBtn setImage:[UIImage imageNamed:@"01_02back_normal"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_backBtn];
}

- (void)goBack{
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    if (!vc) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
