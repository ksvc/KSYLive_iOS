//
//  KSYSimplestStreamerVC.m
//  KSYLiveDemo
//
//  Created by 孙健 on 2017/2/7.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYSimplestStreamerVC.h"
#import <libksygpulive/KSYGPUStreamerKit.h>

@interface KSYSimplestStreamerVC ()<UIPickerViewDataSource,
UIPickerViewDelegate>{
    NSArray * _profileNames;
}
@property KSYGPUStreamerKit *kit;
@property UIPickerView      *profilePicker;
@property NSInteger         curProfileIdx;
@property NSURL             *url;
@property UILabel           *streamState;
@property GPUImageOutput<GPUImageInput>* curFilter;

@end

@implementation KSYSimplestStreamerVC
- (id)initWithUrl:(NSString *)rtmpUrl{
    if (self = [super init]) {
        _url = [NSURL URLWithString:rtmpUrl];
        [self addObserver];
    }
    return self;
}
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamStateChanged) name:KSYStreamStateDidChangeNotification object:nil];
}
- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)streamStateChanged{
    switch (_kit.streamerBase.streamState) {
        case KSYStreamStateIdle:
        _streamState.text = @"空闲状态";
        break;
        case KSYStreamStateConnecting:
        _streamState.text = @"连接中";
        break;
        case KSYStreamStateConnected:
        _streamState.text = @"已连接";
        break;
        case KSYStreamStateDisconnecting:
        _streamState.text = @"失去连接";
        break;
        case KSYStreamStateError:
        _streamState.text = @"连接错误";
        break;
        default:
        break;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _kit = [[KSYGPUStreamerKit alloc] init];
    _curFilter = [[KSYGPUBeautifyExtFilter alloc] init];
    _kit.cameraPosition = AVCaptureDevicePositionFront;
    _kit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    _kit.capturePixelFormat   = kCVPixelFormatType_32BGRA;
    self.view.backgroundColor = [UIColor whiteColor];
    _profileNames = [NSArray arrayWithObjects:@"360p_auto",@"360p_1",@"360p_2",@"360p_3",@"540p_auto",
                     @"540p_1",@"540p_2",@"540p_3",@"720p_auto",
                     @"720p_1",@"720p_2",@"720p_3",nil];
    [self setupUI];
}
- (void)setupUI{
    _profilePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 200)];
    [self.view addSubview: _profilePicker];
    _profilePicker.delegate   = self;
    _profilePicker.dataSource = self;
    _profilePicker.showsSelectionIndicator= YES;
    _profilePicker.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [_profilePicker selectRow:7 inComponent:0 animated:YES];

    UIButton *captureBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height-35, 120, 30)];
    [self.view addSubview:captureBtn];
    [captureBtn setTitle:@"开始预览" forState:UIControlStateNormal];
    [captureBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [captureBtn setBackgroundColor:[UIColor lightGrayColor]];
    [captureBtn addTarget:self action:@selector(onCapture) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *streamBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-125, self.view.frame.size.height-35, 120, 30)];
    [self.view addSubview:streamBtn];
    [streamBtn setTitle:@"开始推流" forState:UIControlStateNormal];
    [streamBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [streamBtn setBackgroundColor:[UIColor lightGrayColor]];
    [streamBtn addTarget:self action:@selector(onStream) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *quitBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 20, 60, 30)];
    [self.view addSubview:quitBtn];
    [quitBtn setTitle:@"退出" forState:UIControlStateNormal];
    [quitBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [quitBtn setBackgroundColor:[UIColor lightGrayColor]];
    [quitBtn addTarget:self action:@selector(onQuit) forControlEvents:UIControlEventTouchUpInside];
    
    _streamState = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 60, 20, 120, 30)];
    [self.view addSubview:_streamState];
    _streamState.textAlignment = NSTextAlignmentCenter;
    _streamState.textColor = [UIColor redColor];
}
- (void)onCapture{
    _profilePicker.hidden = YES;
    if (!_kit.vCapDev.isRunning){
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit setupFilter:_curFilter];
        [_kit startPreview:self.view];
    }
    else {
        [_kit stopPreview];
    }
}
- (void)onStream{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        [_kit.streamerBase startStream:_url];
    }
    else {
        [_kit.streamerBase stopStream];
    }
}
- (void)onQuit{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self removeObserver];
    [_kit stopPreview];
    _kit = nil;
}
#pragma mark - profile picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    return 1; // 单列
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    return _profileNames.count;//
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    return [_profileNames objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    if (row >= 0 && row <= 3){
        _curProfileIdx = row;
    }else if (row >= 4 && row <= 7){
        _curProfileIdx = 100 + (row - 4);
    }else if (row >= 8 && row <= 11){
        _curProfileIdx = 200 + (row - 8);
    }else{
        _curProfileIdx = 103;
    }
    _kit.streamerProfile = _curProfileIdx;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
