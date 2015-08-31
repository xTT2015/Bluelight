//
//  codeViewController.h
//  SmartLight
//
//  Created by xTT on 15/8/14.
//  Copyright (c) 2015年 xTT. All rights reserved.
//

#import "baseViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface codeViewController : baseViewController<AVCaptureMetadataOutputObjectsDelegate>{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic, retain) UIImageView * line;
@end
