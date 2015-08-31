//
//  setLightViewController.m
//  SmartLight
//
//  Created by xTT on 15/7/21.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "setLightViewController.h"

@interface setLightViewController ()

@end

@implementation setLightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sourceArr = [NSMutableArray arrayWithArray:@[@"增加网络", @"切换网络", @"删除网络",@"分享网络", @"强制清除设备记忆", @"随意控配置", @"关于"]];
    [self.backBtn removeFromSuperview];
}

#pragma mark
#pragma mark UITableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sourceArr.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 40;
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.text = self.sourceArr[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入网络名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
            UITextField *nameField = [alert textFieldAtIndex:0];
            nameField.placeholder = @"网络名称";
            UITextField *passwordField = [alert textFieldAtIndex:1];
            passwordField.placeholder = @"密码";
            [alert show];
        }
            break;
        case 1:{
            [self performSegueWithIdentifier:@"goManagementNet" sender:indexPath];
        }
            break;
        case 2:{
            [self performSegueWithIdentifier:@"goManagementNet" sender:indexPath];
        }
            break;
        case 3:{
            [self performSegueWithIdentifier:@"goShare" sender:nil];
        }
            break;
        case 4:{
            [self performSegueWithIdentifier:@"goReset" sender:nil];
        }
            break;
        case 5:{
//            [self performSegueWithIdentifier:@"goControlList" sender:nil];
        }
            break;
        case 6:{
            [self performSegueWithIdentifier:@"goAbout" sender:nil];
        }
            break;
        default:
            break;
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        UITextField *nameField = [alertView textFieldAtIndex:0];
        UITextField *passwordField = [alertView textFieldAtIndex:1];
        Network *testNetwork = [Network newNetwork:nameField.text
                                          password:passwordField.text];
        [[NetworkManager sharedManager] addNetwork:testNetwork];
    }
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
    if (sender) {
        NSIndexPath *indexPath = sender;
        if (indexPath.row == 2) {
            [segue.destinationViewController setValue:@(YES) forKey:@"isDelete"];
        }
    }
}


@end
