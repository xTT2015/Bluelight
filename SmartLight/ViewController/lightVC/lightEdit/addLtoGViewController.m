//
//  addLtoGViewController.m
//  SmartLight
//
//  Created by xTT on 15/8/4.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "addLtoGViewController.h"

@implementation addLightCell

@end

@interface addLtoGViewController (){
    NSMutableArray *selectLightArr;
    NSMutableArray *addLightArr;
}

@end

@implementation addLtoGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectLightArr = [NSMutableArray array];
    addLightArr = [NSMutableArray array];
    NSArray *lightG = [User currentUser].myNetWork.lights.allObjects;
    [lightG enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
        if (![obj.groupIdArr containsObject:[NSString stringWithFormat:@"%@",_groupId]]) {
            [selectLightArr addObject:obj];
        }
    }];
}

- (IBAction)saveAddClick:(UIButton *)sender{
    [addLightArr enumerateObjectsUsingBlock:^(Light *obj, NSUInteger idx, BOOL *stop) {
        [obj.groupIdArr addObject:[NSString stringWithFormat:@"%@",_groupId]];
        obj.groupID = [obj.groupIdArr componentsJoinedByString:@","];
    }];
    [super goBack];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return selectLightArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    addLightCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"addLightCell"
                                                                   forIndexPath:indexPath];
    
    Light *L = selectLightArr[indexPath.item];
    cell.name_Label.text = L.name;
    
    if ([addLightArr containsObject:L]) {
        cell.state_ImageView.alpha = 1;
    }else{
        cell.state_ImageView.alpha = 0;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / 3, collectionView.frame.size.height / 3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Light *L = selectLightArr[indexPath.item];
    if ([addLightArr containsObject:L]) {
        [addLightArr removeObject:L];
    }else{
        [addLightArr addObject:L];
    }
    [collectionView reloadData];
}

@end
