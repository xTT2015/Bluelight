//
//  eidtLorGViewController.m
//  SmartLight
//
//  Created by xTT on 15/8/4.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "editLorGViewController.h"

#define cellBtnLight 200

#define deleteLight_Tag 300
#define deleteGroup_Tag 301


#define deleteLonG_Tag 302

@implementation editlightCell

- (void)addView:(UIControl *)control target:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [control addTarget:target action:action forControlEvents:controlEvents];
}

@end

@interface editLorGViewController (){
    NSMutableArray *editLightArr;
    Light *delLight;
}

@end

@implementation editLorGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_editGroup) {
        [_titleBtn setTitle:_editGroup.name forState:UIControlStateNormal];
        _nameField.text = _editGroup.name;
        editLightArr = [NSMutableArray array];
        [_deleBtn setTitle:@"删除改分组" forState:UIControlStateNormal];
    }else if (_editLight){
        [_titleBtn setTitle:_editLight.name forState:UIControlStateNormal];
        _nameField.text = _editLight.name;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [editLightArr removeAllObjects];
    NSArray *lightG = [User currentUser].myNetWork.lights.allObjects;
    [lightG enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.groupIdArr containsObject:[NSString stringWithFormat:@"%@",_editGroup.groupId]]) {
            [editLightArr addObject:obj];
        }
    }];
    [self.myCollectionView reloadData];
}

- (IBAction)saveEditClick:(UIButton *)sender{
    if (_nameField.text.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"名字不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if (_editGroup) {
        _editGroup.name = _nameField.text;
        [[User currentUser].myGroups replaceObjectAtIndex:[_groupIndex unsignedIntegerValue]
                                               withObject:[_editGroup keyValues]];
    }else if (_editLight){
        _editLight.name = _nameField.text;
    }
    [super goBack];
}

- (IBAction)deleteClick:(UIButton *)sender{
    if (_editGroup) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否删除此分组" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = deleteGroup_Tag;
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"要将该智能灯从网络中删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = deleteLight_Tag;
        [alert show];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (editLightArr) {
        return editLightArr.count + 1;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    editlightCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"editlightCell"
                                                                    forIndexPath:indexPath];
    
    if (indexPath.item == editLightArr.count) {
        cell.add_ImgView.image = [UIImage imageNamed:@"GroupAdd"];
        cell.name_Label.alpha = 0;
        cell.delete_Btn.alpha = 0;
    }else{
        Light *L = editLightArr[indexPath.item];
        cell.name_Label.text = L.name;
        cell.add_ImgView.image = [UIImage imageNamed:@"Light_Mid_01"];
        [cell addView:cell.delete_Btn target:self action:@selector(deleteLightClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.delete_Btn.tag = cellBtnLight + indexPath.item;
        
        cell.name_Label.alpha = 1;
        cell.delete_Btn.alpha = 1;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 3, collectionView.frame.size.height / 2);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == editLightArr.count) {
        [self performSegueWithIdentifier:@"goAddLtoG" sender:nil];
    }
}

- (void)deleteLightClick:(UIButton *)sender{
    delLight = editLightArr[sender.tag - cellBtnLight];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"要将改智能灯从该分组中删除吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = deleteLonG_Tag;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    switch (alertView.tag) {
        case deleteLight_Tag:
        {
            [[User currentUser].myNetWork deleteBlueDevice:_editLight complete:^(NSError *error) {
                if (error) {
                    NSLog(@"deleteBlueDevice %@",error);
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                }
            }];
        }
        break;
        case deleteGroup_Tag:
        {
            [editLightArr enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
                [obj.groupIdArr removeObject:[NSString stringWithFormat:@"%@",_editGroup.groupId]];
                obj.groupID = [obj.groupIdArr componentsJoinedByString:@","];
            }];
            [[User currentUser].myGroups removeObject:[_editGroup keyValues]];
            [[User currentUser] saveGroups];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        case deleteLonG_Tag:
        {
            [editLightArr removeObject:delLight];
            [delLight.groupIdArr removeObject:[NSString stringWithFormat:@"%@",_editGroup.groupId]];
            delLight.groupID = [delLight.groupIdArr componentsJoinedByString:@","];
            [self.myCollectionView reloadData];
        }
            break;
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [segue.destinationViewController setValue:_editGroup.groupId forKey:@"groupId"];
}

@end
