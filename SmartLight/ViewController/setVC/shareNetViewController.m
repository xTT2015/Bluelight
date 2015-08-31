//
//  shareNetViewController.m
//  SmartLight
//
//  Created by xTT on 15/8/14.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "shareNetViewController.h"
#import "QRCodeGenerator.h"

#import "NetworkManager.h"

#import "User.h"

#define pageLength 400

@implementation shareNetViewController{
    NSInteger allPage;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
    NSMutableDictionary *allDataDic = [NSMutableDictionary dictionary];
    
    NSMutableArray *lightArr = [NSMutableArray array];
    
    NSArray *keyArr = @[@"address",@"name",@"deviceType",@"networkID",@"deviceID",@"maxDeviceID",@"groupID"];
    [[NetworkManager sharedManager].getNetworks enumerateObjectsUsingBlock:^(Network *obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *networkDic = [obj keyValuesWithKeys:@[@"name",@"password",@"networkID"]];
        [networkDic setObject:[Light keyValuesArrayWithObjectArray:obj.lights.allObjects
                                                              keys:keyArr]
                       forKey:@"BlueDevice"];
        
        
        NSString* libraryDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES)[0];
        NSString* filePath = [libraryDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",obj.networkID]];
        [networkDic setObject:[NSMutableArray arrayWithContentsOfFile:filePath] forKey:@"Groups"];
        
        
        [lightArr addObject:networkDic];
    }];
    
    [allDataDic setObject:lightArr forKey:@"Network"];


    NSData *allData = [NSJSONSerialization dataWithJSONObject:allDataDic
                                                   options:kNilOptions error:nil];
    
    NSString *imgBase64 = [allData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    
    
    
    
    
    
    //生成二维码
    NSInteger length = imgBase64.length;
    allPage = length / pageLength;
    if (length - (allPage * pageLength) > 0) {
        allPage ++;
    }
    for (int i = 0; i < allPage; i++) {
        NSInteger getLen = pageLength;
        if (length < (i + 1) * pageLength) {
            getLen = length - i * pageLength;
        }
        NSDictionary *dic = @{@"pages":@(allPage),
                              @"curPage":@(i + 1),
                              @"data":[imgBase64 substringWithRange:NSMakeRange(i * pageLength, getLen)]};
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:kNilOptions error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20 + i * self.view.frame.size.width, 40,
                                                                               self.view.frame.size.width - 40,
                                                                               self.view.frame.size.width - 40)];
        
        imageView.image = [QRCodeGenerator qrImageForString:jsonStr
                                                  imageSize:imageView.frame.size.width];
        [_scrollView addSubview:imageView];
        NSLog(@"page = %d",i);
    }

    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width * allPage, _scrollView.frame.size.height);
    _titleLabel.text = [NSString stringWithFormat:@"1/%d",allPage];
//    
//    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"%@",allDataDic);
//    
//    _imageView.image = [QRCodeGenerator qrImageForString:jsonStr
//                                               imageSize:_imageView.frame.size.width];
}

- (void) scrollViewDidScroll:(UIScrollView *)sender {
    // 得到每页宽度
    CGFloat pageWidth = sender.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int currentPage = floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _titleLabel.text = [NSString stringWithFormat:@"%d/%d",currentPage + 1,allPage];
}

@end
