//
//  GroupListViewController.m
//  BDEBluePlus
//
//  Created by xtmac on 18/5/15.
//  Copyright (c) 2015年 xtmac. All rights reserved.
//

#import "SelectGroupViewController.h"
//#import "NetworkTabBarController.h"
//#import "NetworkObject.h"
//#import "GroupObject.h"
//#import "HttpRequest.h"
//#import "BDECache.h"

@interface SelectGroupViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>{
    NSArray                 *_groups;
    __weak IBOutlet UITableView *_tableView;
}

@end

@implementation SelectGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    NetworkTabBarController *tabBar = (NetworkTabBarController*)self.tabBarController;
//    _groups = tabBar.networkObject.groupObjectArr;
}

- (IBAction)backBtnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 1;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return [UIView new];
    }
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 35)];
    [view setBackgroundColor:[UIColor colorWithRed:17 / 255.0 green:39 / 255.0 blue:82 / 255.0 alpha:1]];
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger iRet = 0;
    if (section == 0) {
        return 1;
    }else if (section == 1){
        iRet = _groups.count;
    }
    return iRet;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:109 / 255.0 green:170 / 255.0 blue:221 / 255.0 alpha:1]];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"添加新的分组";
    }else if (indexPath.section == 1){
//        GroupObject *group = _groups[indexPath.row];
//        cell.textLabel.text = group.name;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        //添加新的分组，弹出对话框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入分组名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        alert.tag = 1;
        [alert show];
    }else if (indexPath.section == 1){
        //选择分组
        if ([_delegate respondsToSelector:@selector(SelectGroupDidSelectGroup:)]) {
            [_delegate SelectGroupDidSelectGroup:_groups[indexPath.row]];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        do {
            NSString *groupName = [alertView textFieldAtIndex:0].text;
            
            if (!groupName || !groupName.length) {
//                [NSHELPER showWarningBox:@"分组名称不能为空"];
                break;
            }
            
            if (groupName.length > 16) {
//                [NSHELPER showWarningBox:@"分组名称长度不能超过16个字符"];
                break;
            }
            
//            BOOL haveGroupName = NO;
//            //寻找与输入的组名相同的名字
//            for (GroupObject *group in _groups) {
//                if ([groupName isEqualToString:group.name]) {
//                    haveGroupName = YES;
//                    break;
//                }
//            }
//            
//            if (haveGroupName) {
//                [NSHelper showWarningBox:@"已经有此名称的分组"];
//                break;
//            }
            
//            GroupObject *groupTemp = _groups.lastObject;
//            GroupObject *group = [[GroupObject alloc] initWithGroupDic:@{@"name" : groupName, @"groupid" : [NSNumber numberWithInt:[groupTemp.groupID intValue] + 1]}];
//            NSMutableArray *temp = [NSMutableArray arrayWithArray:_groups];
//            [temp addObject:group];
//            _groups = [NSArray arrayWithArray:temp];
//            NetworkTabBarController *tabBar = (NetworkTabBarController*)self.tabBarController;
//            NetworkObject *networkObject = [[NetworkObject alloc] initWithNetworkDic:@{@"uuid" : tabBar.networkObject.uuid, @"groups" : _groups}];
//            [HttpRequest updateBDENetworkWithAppID:[[XLinkExportObject sharedObject].authKey intValue] withNetworkObjectDic:[networkObject getNetworkObjectDictionary] withDelegate:self];
        } while (0);
    }
}


@end
