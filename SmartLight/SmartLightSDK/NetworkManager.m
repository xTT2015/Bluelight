//
//  NetworkManager.m
//  SmartLight
//
//  Created by LevinYan on 3/17/15.
//  Copyright (c) 2015 BDE. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NetworkManager.h"
#import "AppDelegate.h"
#import "Network.h"
#import "BLEManager.h"
#import "BlueDevice.h"
#import "BlueDeviceScanner.h"

@interface NetworkManager()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) BLEManager *bleManager;
@property (nonatomic, strong) BlueDeviceScanner *scanner;
@end

@implementation NetworkManager

+ (instancetype)sharedManager
{
  static NetworkManager *_manager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _manager = [[NetworkManager alloc] init];
    _manager.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    _manager.bleManager = [[BLEManager alloc] init];
    _manager.scanNetworks = [NSMutableArray arrayWithCapacity:0];
  });
  return _manager;
}


- (NSArray*)getNetworks
{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Network class])];
  return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (Network*)getNetwork:(NSNumber *)networkID
{
  NSArray *networks = [self getNetworks];
  for(Network *network in networks)
  {
    if([network.networkID isEqualToNumber:networkID])
      return network;
  }
  return nil;
}
- (void)addNetwork:(Network *)network
{
  [self.managedObjectContext performBlockAndWait:^{
    
    [self.managedObjectContext insertObject:network];
    
  }];
}

- (void)deleteNetwork:(Network *)network
{
  [self.managedObjectContext performBlockAndWait:^{
    
    [self.managedObjectContext deleteObject:network];

  }];
}

- (Network*)getNetworkFromScanNetworks:(NSNumber*)networkID
{
  for(Network *network in self.scanNetworks)
  {
    if([network.networkID isEqualToNumber:networkID])
      return network;
  }
  return nil;
}
- (void)scanNetwork:(void (^)(Network* network))resultBlock
{
  self.scanner = [[BlueDeviceScanner alloc] init];
  [self.scanNetworks removeAllObjects];
  [self.scanner scanForBlueDevice:nil result:^(BlueDevice *blueDevice) {
    
    if(!blueDevice.isAddedToNetwork)
      return;
    
    
    NSNumber *networkID = blueDevice.networkID;
    Network *scanedNetwork = nil;
    
    if((scanedNetwork = [self getNetworkFromScanNetworks:networkID]) == nil)
    {
      Network *network = [Network newNetwork];
      network.networkID = networkID;
      network.name = blueDevice.networkName;
      
      [self.scanNetworks addObject:network];
      if(resultBlock)
        resultBlock(network);
    }
    else
    {
      if(scanedNetwork.name == nil)
        scanedNetwork.name = blueDevice.networkName;
    }
  }];
}
@end
