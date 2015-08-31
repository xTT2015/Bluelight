//
//  GroupListViewController.m
//  SmartLight
//
//  Created by xTT on 15/7/13.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "GroupListViewController.h"

#import "Group.h"

#define cellSwitchLight 200
@implementation lightGroupCell

- (void)addView:(UIControl *)control target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [control addTarget:target action:action forControlEvents:controlEvents];
}

@end

@interface GroupListViewController ()

@end

@implementation GroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.backBtn removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.myCollectionView reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [User currentUser].myGroups.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    lightGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"lightGroupCell"
                                                                forIndexPath:indexPath];
    
    if (indexPath.item == [User currentUser].myGroups.count) {
        cell.name_Label.text = @"添加分组";
        cell.imageView_G.image = [UIImage imageNamed:@"GroupAdd"];
        cell.connect_Switch.alpha = 0;
    }else{
        NSDictionary *dic = [User currentUser].myGroups[indexPath.item];
        
        cell.name_Label.text = dic[@"name"];
        cell.imageView_G.image = [UIImage imageNamed:@"group_01"];
        cell.connect_Switch.alpha = 1;
        
        
        [cell addView:cell.connect_Switch
               target:self
               action:@selector(switchClick:)
     forControlEvents:UIControlEventValueChanged];
        cell.connect_Switch.tag = cellSwitchLight + [dic[@"groupId"] integerValue];
        [cell.connect_Switch setOn:NO];

        NSArray *lightG = [User currentUser].myNetWork.lights.allObjects;
        [lightG enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.groupIdArr containsObject:[NSString stringWithFormat:@"%d",cell.connect_Switch.tag - cellSwitchLight]]) {
                [cell.connect_Switch setOn:[obj.on boolValue]];
                *stop = YES;
            }
        }];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 3, collectionView.frame.size.height / 3);
}

- (void)switchClick:(UISwitch *)sender{    
    NSArray *lightG = [User currentUser].myNetWork.lights.allObjects;
    NSMutableArray *arr = [NSMutableArray array];
    __block Color color;
    [lightG enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.groupIdArr containsObject:[NSString stringWithFormat:@"%d",sender.tag - cellSwitchLight]]) {
            [arr addObject:obj];
            if (arr.count == 1) {
                color = obj.color;
            }
            if (sender.on) {
                obj.on = @YES;
            }else {
                obj.on = @NO;
                color = kColorOff;
            }
        }
    }];
    [[User currentUser].myNetWork quicklyControlLights:arr color:color];
//    [self.myCollectionView reloadData];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == [User currentUser].myGroups.count){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入分组名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert show];
    }else{
        [self performSegueWithIdentifier:@"goLightColor" sender:indexPath];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *groupName = [alertView textFieldAtIndex:0].text;
        if (groupName.length != 0) {
            NSDictionary *dic = [[User currentUser].myGroups lastObject];
            int groupID = [dic[@"groupId"] intValue];
            [[User currentUser].myGroups addObject:@{@"name":groupName,
                                                     @"groupId":@(groupID + 1)}];
            [[User currentUser] saveGroups];
            [self.myCollectionView reloadData];
        }
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
    NSIndexPath *indexPath = sender;
    NSDictionary *dic = [User currentUser].myGroups[indexPath.item];
    [segue.destinationViewController setValue:[Group objectWithKeyValues:dic] forKey:@"playGroup"];
}


@end
