//
//  KSYQRCodeVC.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/13.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYQRCodeVC.h"
#import "BaseTapSound.h"
#import <AVFoundation/AVFoundation.h>

@interface KSYQRCodeVC ()<AVCaptureMetadataOutputObjectsDelegate,UIActionSheetDelegate>{
    SystemSoundID soundID; //声音
    float move; //
}

@property (nonatomic,strong) AVCaptureDevice * device; //设备
@property (nonatomic,strong) AVCaptureDeviceInput * input; //输入
@property (nonatomic,strong) AVCaptureMetadataOutput * output; //输出
@property (nonatomic,strong) AVCaptureSession * session; //会话
@property (nonatomic,strong) AVCaptureVideoPreviewLayer * preview; //预览视图

@property (nonatomic,strong) UIImageView  *qrView; //二维码的图片
@property (nonatomic,strong) UIImageView *lineLabel; //扫描的线条
@property (nonatomic,strong) NSTimer *lineTimer; //定时器

@end

@implementation KSYQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCenterScaningFrame];
    // Do any additional setup after loading the view.
}
#pragma mark -
#pragma mark - private Methods 私有方法
/**
 创建中心扫描框
 */
-(void)setCenterScaningFrame{
    
    self.title = @"二维码";
    //创建导航栏按钮
    UIBarButtonItem* scanButtonItem = [UIBarButtonItem barButtonItemWithImageName:@"返回" frame:KSYScreen_Frame(0, 0, 35, 35) target:self action:@selector(backInterface)];
    self.navigationItem.leftBarButtonItem = scanButtonItem;
    
     move = 1.0;
    //扫描区域宽、高大小
    float QRWIDTH = 200/320.0*KSYScreenWidth;
    
    //创建扫描区域框
    _qrView=[[UIImageView alloc]init];
    _qrView.bounds = CGRectMake(0, 0, QRWIDTH, QRWIDTH);
    _qrView.center = CGPointMake(KSYScreenWidth/2.0, (KSYScreenHeight-200)/2.0);
    _qrView.backgroundColor = [UIColor clearColor];
    _qrView.image = [UIImage imageNamed:@"QRImage.png"];
    [self.view addSubview:_qrView];
    
    _lineLabel = [[UIImageView alloc]initWithFrame:CGRectMake(_qrView.frame.origin.x+2.0, _qrView.frame.origin.y + 2.0, _qrView.frame.size.width - 4.0, 3.0)];
    _lineLabel.image = [UIImage imageNamed:@"QRLine.png"];
    [self.view addSubview:_lineLabel];
    
    
    //半透明背景
    UIView *qrBacView = [[UIView alloc]init];//上
    qrBacView.frame = CGRectMake(0, 0, KSYScreenWidth, _qrView.frame.origin.y);
    qrBacView.backgroundColor = [UIColor blackColor];
    qrBacView.alpha = 0.1;
    [self.view addSubview:qrBacView];
    
    qrBacView = [[UIView alloc]init];//左
    qrBacView.frame = CGRectMake(0, _qrView.frame.origin.y, _qrView.frame.origin.x,KSYScreenHeight - _qrView.frame.origin.y);
    qrBacView.backgroundColor = [UIColor blackColor];
    qrBacView.alpha = 0.1;
    [self.view addSubview:qrBacView];
    
    qrBacView = [[UIView alloc]init];//下
    qrBacView.frame = CGRectMake(_qrView.frame.origin.x, _qrView.frame.origin.y + QRWIDTH, KSYScreenWidth - _qrView.frame.origin.x, KSYScreenHeight - _qrView.frame.origin.y - QRWIDTH);
    qrBacView.backgroundColor = [UIColor blackColor];
    qrBacView.alpha = 0.1;
    [self.view addSubview:qrBacView];
    
    qrBacView = [[UIView alloc]init];//右
    qrBacView.frame = CGRectMake(_qrView.frame.origin.x + QRWIDTH, _qrView.frame.origin.y, KSYScreenWidth - _qrView.frame.origin.x - QRWIDTH, QRWIDTH);
    qrBacView.backgroundColor = [UIColor blackColor];
    qrBacView.alpha = 0.1;
    [self.view addSubview:qrBacView];
    //判断是否可以使用相机
    [self canUseSystemCamera];
}

- (void)canUseSystemCamera{
    if (![BaseTapSound ifCanUseSystemCamera]) {
        _lineLabel.hidden = YES;
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"此应用已被禁用系统相机" message:@"请在iPhone的 \"设置->隐私->相机\" 选项中,允许访问你的相机" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        _lineLabel.hidden = NO;
        [self createQRView];
    }
}

//创建扫描
- (void)createQRView{
    
    //扫描区域宽、高大小
    float QRWIDTH = 200/320.0*KSYScreenWidth;
    
    //手电筒开关
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(_qrView.frame.origin.x + QRWIDTH/2.0 - 20, _qrView.frame.origin.y + _qrView.frame.size.height + 20, 40, 40);
    btn.selected = NO;
    
    [btn setImage:[UIImage imageNamed:@"ocr_flash-off"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"ocr_flash-on"] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(openOrClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // Output
    _output = [[AVCaptureMetadataOutput alloc] init];
    [ _output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue ()];
    // Session
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]){
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output]){
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    //设置扫描有效区域(上、左、下、右)
    [_output setRectOfInterest : CGRectMake (( _qrView.frame.origin.y )/ KSYScreenHeight ,(_qrView.frame.origin.x)/ KSYScreenWidth , QRWIDTH / KSYScreenHeight , QRWIDTH / KSYScreenWidth )];
    // Preview
    _preview =[ AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill ;
    _preview.frame = self.view.layer.bounds ;
    [self.view.layer insertSublayer:_preview atIndex:0];
    // Start
    [_session startRunning];
    
    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
}

//移动线条
- (void)moveLine{
    float upY = _qrView.frame.origin.y + _qrView.frame.size.height - 2.0 - 3.0;
    float y = _lineLabel.frame.origin.y;
    y = y+move;
    CGRect lineFrame=CGRectMake(_lineLabel.frame.origin.x, y, _qrView.frame.size.width - 4.0, 3.0);
    _lineLabel.frame = lineFrame;
    if (y < _qrView.frame.origin.y + 2.0 || y > upY) {
        move = -move;
    }
    
}

#pragma mark -
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

//扫描成功后的代理方法
- (void)captureOutput:( AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray*)metadataObjects fromConnection:(AVCaptureConnection*)connection
{
    NSString *stringValue;//扫描结果
    if ([metadataObjects count ] > 0 ){
        // 停止扫描
        [_session stopRunning];
        if ([_lineTimer isValid]) {
            [_lineTimer invalidate];
            _lineTimer = nil;
            _lineLabel.hidden = YES;
        }
        [[BaseTapSound shareTapSound]playSystemSound];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        stringValue = metadataObject. stringValue ;
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"QRCodeResult" message:stringValue preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startingQRCode];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)startingQRCode {
    if (self.session) {
        [self.session startRunning ];
        if (self.lineTimer) {
            [self.lineTimer invalidate];
            self.lineTimer = nil;
        }
        self.lineTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
        self.lineLabel.hidden = NO;
    }
    
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等

/**
 闪光灯关闭

 @param sender 闪光灯按钮
 */
- (void)openOrClose:(UIButton *)sender{
    sender.selected = !sender.selected;
    if ([sender isSelected]) {
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOn];
        [_device unlockForConfiguration];
    }else{
        [_device lockForConfiguration:nil];
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_device unlockForConfiguration];
    }
}

- (void)leftButtonHaveClick:(UIButton *)sender{
    if ([_lineTimer isValid]) {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    [_device lockForConfiguration:nil];
    [_device setTorchMode:AVCaptureTorchModeOff];
    [_device unlockForConfiguration];
    [self.navigationController popViewControllerAnimated:YES];
}


/**
 返回上一界面
 */
-(void)backInterface{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - life cycle 视图的生命周期

- (void)dealloc{
    if ([_lineTimer isValid]) {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (_session) {
        [_session startRunning ];
        if (_lineTimer) {
            [_lineTimer invalidate];
            _lineTimer = nil;
        }
        _lineTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
        _lineLabel.hidden = NO;
        
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
