//
//  managementNetViewController.m
//  SmartLight
//
//  Created by xTT on 15/7/28.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "managementNetViewController.h"

@interface managementNetViewController ()
{
    NSInteger index;
}
@end

@implementation managementNetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_isDelete) {
        _titleLabel.text = @"删除网络";
    }else{
        _titleLabel.text = @"切换网络";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[NetworkManager sharedManager] getNetworks].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell.textLabel setTextColor:[UIColor colorWithRed:109 / 255.0 green:170 / 255.0 blue:221 / 255.0 alpha:1]];
        cell.backgroundColor = [UIColor clearColor];
    }
    Network *network = [[NetworkManager sharedManager] getNetworks][indexPath.row];
    if (network.name.length > 0) {
        cell.textLabel.text = network.name;
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"Unknow Network (%@)", network.networkID];
    }
    if ([network.networkID intValue] == [[User currentUser].myNetWork.networkID intValue]) {
        cell.textLabel.textColor = [UIColor yellowColor];
    }else{
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isDelete) {
        if ([[NetworkManager sharedManager] getNetworks].count == 1) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法删除"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }else{
            index = indexPath.row;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否删除该网络"
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }else{
        [User currentUser].myNetWork = [[NetworkManager sharedManager] getNetworks][indexPath.row];
        [super goBack];
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (index == [[NetworkManager sharedManager] getNetworks].count - 1) {
            [User currentUser].myNetWork = [[NetworkManager sharedManager] getNetworks][0];
        }
        [[NetworkManager sharedManager] deleteNetwork:[[NetworkManager sharedManager] getNetworks][index]];
        [super goBack];
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
