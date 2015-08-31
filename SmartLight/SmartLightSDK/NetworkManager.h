//
//  NetworkManager.h
//  SmartLight
//
//  Created by LevinYan on 3/17/15.
//  Copyright (c) 2015 BDE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Network.h"


@interface NetworkManager : NSObject

/**
 *  扫描到的网络
 */
@property (nonatomic, strong) NSMutableArray *scanNetworks;

/*
 * 网络管理单例
 */
+ (instancetype)sharedManager;


/*
 * 获取保存的网络
 * @return 保存的网络
 */
- (NSArray*)getNetworks;


/*
 * 获取网络ID为networkID的网络
 * @param networkID 网络ID
 * @return 匹配的网络
 */
- (Network*)getNetwork:(NSNumber*)networkID;


/*
 * 添加网络
 * @param network 要加的网络
 */
- (void)addNetwork:(Network*)network;


/*
 * 删除网络
 * @param network 要删除的网络
 *
 */
- (void)deleteNetwork:(Network*)network;


/**
 *  扫描网络
 *
 *  @param resultBlock 当扫描到网络时调用，network代表扫描到网络(该block会被多次调用)
 */
- (void)scanNetwork:(void (^)(Network* network))resultBlock;

@end
