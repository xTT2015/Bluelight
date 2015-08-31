//
//  codeViewController.m
//  SmartLight
//
//  Created by xTT on 15/8/14.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "codeViewController.h"

#import "Network.h"

#import "SVProgressHUD.h"
@interface codeViewController (){
    NSString *codeStr;
    NSInteger codeCurPage;
    NSInteger codeAllPage;
}

@end

@implementation codeViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    codeCurPage = 0;
    codeAllPage = 0;
    
    upOrdown = NO;
    num =0;
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02
                                             target:self
                                           selector:@selector(animation)
                                           userInfo:nil
                                            repeats:YES];
}

-(void)animation
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(50, 110+2*num, 220, 2);
        if (2*num == 280) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(50, 110+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupCamera];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
}

- (void)setupCamera
{
    CGFloat width = self.view.frame.size.width;
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =CGRectMake(15,110, width - 30, width - 30);
    [self.view.layer addSublayer:self.preview];
    
    // Start
    [_session startRunning];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, width - 20, width - 20)];
    imageView.image = [UIImage imageNamed:@"pick_bg"];
    [self.view addSubview:imageView];
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(50, 110, width - 100, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    NSString *stringValue;
    
    if ([metadataObjects count] > 0 && ![SVProgressHUD getSharedView])
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        
        NSData *data = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
        if (!data) {
            return;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
        
        NSLog(@"%@",dic);
        if (!dic) {
            return;
        }
        
        NSInteger curPage = [dic[@"curPage"] integerValue];
        if (codeCurPage + 1 == curPage){
            if (codeAllPage == 0) {
                codeAllPage = [dic[@"pages"] integerValue];
                codeStr = dic[@"data"];
            }else{
                codeStr = [NSString stringWithFormat:@"%@%@",codeStr, dic[@"data"]];
            }
            codeCurPage = curPage;
        }
        
        if(codeAllPage == 0){
            [SVProgressHUD showSuccessWithStatus:@"请扫描第一个二维码"];
        }else if (codeAllPage == codeCurPage) {
            [self getCodeData];
        }else{
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"请扫描 %d/%d 二维码",codeCurPage + 1,codeAllPage]];
        }
    }
}

- (void)getCodeData{
    NSData *data = [[NSData alloc] initWithBase64EncodedString:codeStr
                                                     options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:nil];
    if (dic) {
        [dic [@"Network"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            if (![[NetworkManager sharedManager] getNetwork:obj[@"networkID"]]) {
                Network *net = [Network newNetwork:obj[@"name"]
                                          password:obj[@"password"]
                                         networkID:obj[@"networkID"]];
                [[NetworkManager sharedManager] addNetwork:net];
                
                [obj[@"BlueDevice"] enumerateObjectsUsingBlock:^(NSDictionary *blueDic, NSUInteger idx, BOOL *stop) {
                    Light *blueDevice = [Light createWithAddress:blueDic[@"address"]
                                                            name:blueDic[@"name"]
                                                      deviceType:blueDic[@"deviceType"]
                                                       networkID:blueDic[@"networkID"]
                                                        deviceID:blueDic[@"deviceID"]
                                                     maxDeviceID:blueDic[@"maxDeviceID"]];
                    blueDevice.groupID = blueDic[@"groupID"];
                    [net importBlueDevice:blueDevice];
                }];
                
                [User currentUser].myGroups = obj[@"Groups"];
                [[User currentUser] saveGroups];
                
                NSString* libraryDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES)[0];
                NSString* filePath = [libraryDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",obj[@"networkID"]]];
                [obj[@"Groups"] writeToFile:filePath atomically:YES];
                
            }
        }];
        [_session stopRunning];
        [super goBack];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
