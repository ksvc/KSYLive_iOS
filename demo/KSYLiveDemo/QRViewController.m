//
//  QRViewController.m
//  KSYLiveDemo
//
//  Created by 孙健 on 16/4/13.
//  Copyright © 2016年 qyvideo. All rights reserved.
//

#import "QRViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface QRViewController ()<AVCaptureMetadataOutputObjectsDelegate>{
    UIView      *_viewPreview;          //预览视图
    UILabel     *_QRLabel;              //地址栏
    UIButton    *_scanBtn;              //扫描按钮
    UIView      *_boxView;              //扫面框
    BOOL        _isReading;             //正在扫描
    CALayer     *_scanLayer;            //扫描图层
    CGFloat     _width;
    CGFloat     _height;
    CGFloat     _btnWdt;
    
    UIButton    *_cancelBtn;             // 退出扫码界面
    
}
- (BOOL)startReading;
- (void)stopReading;

@property (nonatomic, strong) AVCaptureSession *captureSeesion;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer  *videoPreviewLayer;

@end

@implementation QRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //init
    [self initVariable];
    [self addViews];
    [self startReading];
}

- (void)initVariable{
    _captureSeesion = nil;
    _isReading      = NO;
    _width  = self.view.frame.size.width;
    _height = self.view.frame.size.height;
}

- (void)addViews{
    _viewPreview = [self addViewPreview];
    _QRLabel     = [self addLable];
    _scanBtn     = [self addButton];
    _cancelBtn   = [self addCancelButton];
}

- (UIButton *)addCancelButton {
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(_width / 2, _height - 30, _width / 2, 30)];
    [self.view addSubview:button];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(quitQRScaner) forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.borderColor   = [UIColor blackColor].CGColor;
    button.layer.borderWidth   = 1;
    button.layer.cornerRadius  = 5;
    return button;
}

- (void)quitQRScaner {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)addViewPreview{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 64, _width, _height - 94)];
    [self.view addSubview:view];
    return view;
}
- (UILabel *)addLable{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 64, _width, 30)];
    label.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:label];
    label.layer.masksToBounds = YES;
    label.layer.borderWidth   = 1;
    label.layer.borderColor   = [UIColor blackColor].CGColor;
    label.layer.cornerRadius  = 2;
    [self.view addSubview:label];
    return label;
}
- (UIButton *)addButton{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, _height - 30, _width / 2, 30)];
    [self.view addSubview:button];
    [button setTitle:@"正在扫描..." forState:UIControlStateNormal];
    [button addTarget:self action:@selector(reScan) forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.borderColor   = [UIColor blackColor].CGColor;
    button.layer.borderWidth   = 1;
    button.layer.cornerRadius  = 5;
    return button;
}
- (void)reScan{
    if (!_isReading) {
        if ([self startReading]) {
            [_scanBtn setTitle:@"正在扫描..." forState:UIControlStateNormal];
            [_QRLabel setText:@"Scanning for QR Code"];
            
        }
    }
    else{
        [self stopReading];
        [_scanBtn setTitle:@"重新扫描" forState:UIControlStateNormal];
    }
    
    _isReading = !_isReading;
}
// start reading
- (BOOL)startReading{
    NSError *error;
    
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"QRVC: %@", [error localizedDescription]);
        return NO;
    }
    
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    //4.实例化捕捉会话
    _captureSeesion = [[AVCaptureSession alloc] init];
    
    //4.1.将输入流添加到会话
    [_captureSeesion addInput:input];
    
    //4.2.将媒体输出流添加到会话中
    [_captureSeesion addOutput:captureMetadataOutput];
    
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSeesion];
    
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    
    //9.将图层添加到预览view的图层上
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    //10.设置扫描范围
    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    
    //10.1.扫描框
    _boxView = [[UIView alloc] initWithFrame:CGRectMake(_viewPreview.bounds.size.width * 0.2f, _viewPreview.bounds.size.height * 0.2f, _viewPreview.bounds.size.width - _viewPreview.bounds.size.width * 0.4f, _viewPreview.bounds.size.height - _viewPreview.bounds.size.height * 0.4f)];
    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
    _boxView.layer.borderWidth = 1.0f;
    
    [_viewPreview addSubview:_boxView];
    
    //10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor brownColor].CGColor;
    
    [_boxView.layer addSublayer:_scanLayer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
    [timer fire];
    
    //10.开始扫描
    [_captureSeesion startRunning];
    
    return YES;
}
- (void)moveScanLayer:(NSTimer *)timer
{
    CGRect frame = _scanLayer.frame;
    if (_boxView.frame.size.height < _scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        _scanLayer.frame = frame;
    }else{
        
        frame.origin.y += 5;
        
        [UIView animateWithDuration:0.1 animations:^{
            _scanLayer.frame = frame;
        }];
    }
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [_QRLabel performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            _isReading = NO;
        }
    }
}
-(void)stopReading{
    [_captureSeesion stopRunning];
    _captureSeesion = nil;
    [_scanLayer removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
    [_scanBtn setTitle:@"重新扫描" forState:UIControlStateNormal];
    if (self.getQrCode) {
        self.getQrCode(_QRLabel.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
