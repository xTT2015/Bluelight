//
//  LocalNetworkListViewController.m
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "LocalNetworkListViewController.h"

@interface LocalNetworkListViewController ()

@end

@implementation LocalNetworkListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)backBtnAction {
    [self.navigationController popViewControllerAnimated:YES];
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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [[UIAlertView alloc] initWithTitle:@"输入密码" message:<#(NSString *)#> delegate:<#(id)#> cancelButtonTitle:<#(NSString *)#> otherButtonTitles:<#(NSString *), ...#>, nil]
    
    [User currentUser].myNetWork = [[NetworkManager sharedManager] getNetworks][indexPath.row];
    [self performSegueWithIdentifier:@"goLightVC" sender:nil];
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
