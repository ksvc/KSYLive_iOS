//
//  KSYSimplestStreamerVC.m
//  KSYLiveDemo
//
//  Created by 孙健 on 2017/2/7.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYSimplestStreamerVC.h"
#import "KSYUIView.h"

@interface KSYSimplestStreamerVC ()<UIPickerViewDataSource,
UIPickerViewDelegate>{
    NSArray * _profileNames;
    UIButton *captureBtn;
    UIButton *streamBtn;
    UIButton *cameraBtn;
    UIButton *quitBtn;
    KSYUIView *ctrlView;
    UIView *_bgView;        // 预览视图父控件（用于处理转屏，保持画面相对手机不变）
}

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
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_bgView];
    
    ctrlView = [[KSYUIView alloc] initWithFrame:self.view.bounds];
    @WeakObj(self);
    ctrlView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
    
    // top view
    quitBtn = [ctrlView addButton:@"退出"];
    _streamState = [ctrlView addLable:@"空闲状态"];
    _streamState.textColor = [UIColor redColor];
    _streamState.textAlignment = NSTextAlignmentCenter;
    cameraBtn = [ctrlView addButton:@"前后摄像头"];
    
    // profile picker
    _profilePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 200)];
    _profilePicker.delegate   = self;
    _profilePicker.dataSource = self;
    _profilePicker.showsSelectionIndicator= YES;
    _profilePicker.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [_profilePicker selectRow:7 inComponent:0 animated:YES];
    
    // bottom view
    captureBtn = [ctrlView addButton:@"开始预览"];
    streamBtn = [ctrlView addButton:@"开始推流"];

    [self.view addSubview:ctrlView];
    [ctrlView addSubview:_profilePicker];
    
    [self layoutPreviewBgView];

    [self layoutUI];
}

- (void)layoutUI{
    ctrlView.frame = self.view.frame;
    [ctrlView layoutUI];
    [ctrlView putRow:@[quitBtn, _streamState, cameraBtn]];
    
    ctrlView.yPos = self.view.frame.size.height - 30;
    [ctrlView putRow:@[captureBtn, [UIView new], streamBtn]];
}

// 根据状态栏方向初始化预览的bgView
- (void)layoutPreviewBgView{
    // size
    CGFloat minLength = MIN(_bgView.frame.size.width, _bgView.frame.size.height);
    CGFloat maxLength = MAX(_bgView.frame.size.width, _bgView.frame.size.height);
    CGRect newFrame;
    // frame
    CGAffineTransform newTransform;
    
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (currentInterfaceOrientation == UIInterfaceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        newTransform = CGAffineTransformMakeRotation(M_PI_2*(currentInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? 1 : -1));
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    _bgView.transform = newTransform;
    _bgView.frame = newFrame;
}

// 旋转处理，通过旋转bgView来做到画面相对手机静止不动
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minLength = MIN(screenSize.width, screenSize.height);
    CGFloat maxLength = MAX(screenSize.width, screenSize.height);
    CGRect newFrame;
    
    // frame
    CGAffineTransform newTransform;
    // need stay frame after animation
    CGAffineTransform newTransformOfStay;
    // whether need to stay
    __block BOOL needStay = NO;
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            newTransform = CGAffineTransformMakeRotation(M_PI_2*(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ? 1 : -1));
        } else {
            needStay = YES;
            if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                newTransform = CGAffineTransformRotate(_bgView.transform,M_PI * 1.00001);
                newTransformOfStay = CGAffineTransformRotate(_bgView.transform, M_PI);
            }else{
                newTransform = CGAffineTransformRotate(_bgView.transform,SYSTEM_VERSION_GE_TO(@"8.0") ? 1.00001 * M_PI : M_PI * 0.99999);
                newTransformOfStay = CGAffineTransformRotate(_bgView.transform, M_PI);
                
            }
        }
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        // sometimes strongSelf can be nil in iOS version 7.0
        if (!strongSelf) {
            return ;
        }
        _bgView.transform = newTransform;
        _bgView.frame = newFrame;
    }completion:^(BOOL finished) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        if (needStay) {
            _bgView.transform = newTransformOfStay;
            _bgView.frame = newFrame;
            needStay = NO;
        }
    }];
    
}

// 旋转处理，通过旋转bgView来做到画面相对手机静止不动
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0)
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat minLength = MIN(screenSize.width, screenSize.height);
    CGFloat maxLength = MAX(screenSize.width, screenSize.height);
    CGRect newFrame;
    
    // frame
    CGAffineTransform newTransform;
    // need stay frame after animation
    CGAffineTransform newTransformOfStay;
    // whether need to stay
    __block BOOL needStay = NO;
    
    UIInterfaceOrientation currentInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIDeviceOrientation toDeviceOrientation = [UIDevice currentDevice].orientation;
    
    if (toDeviceOrientation == UIDeviceOrientationPortrait) {
        newTransform = CGAffineTransformIdentity;
        newFrame = CGRectMake(0, 0, minLength, maxLength);
    } else {
        if (currentInterfaceOrientation == UIInterfaceOrientationPortrait) {
            newTransform = CGAffineTransformMakeRotation(M_PI_2*(toDeviceOrientation == UIDeviceOrientationLandscapeRight ? 1 : -1));
        } else {
            needStay = YES;
            if (currentInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                newTransform = CGAffineTransformRotate(_bgView.transform, M_PI * 1.00001);
                newTransformOfStay = CGAffineTransformRotate(_bgView.transform, M_PI);
            }else{
                newTransform = CGAffineTransformRotate(_bgView.transform, SYSTEM_VERSION_GE_TO(@"8.0") ? 1.00001 * M_PI : M_PI * 0.99999);
                newTransformOfStay = CGAffineTransformRotate(_bgView.transform, M_PI);
            }
        }
        newFrame = CGRectMake(0, 0, maxLength, minLength);
    }
    
    __weak typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        _bgView.transform = newTransform;
        _bgView.frame =  newFrame;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return ;
        }
        if (needStay) {
            _bgView.transform = newTransformOfStay;
            _bgView.frame = newFrame;
            needStay = NO;
        }
    }];
}

- (void)onBtn:(UIButton *)btn{
    if (btn == captureBtn) {
        [self onCapture];
    }else if (btn == streamBtn){
        [self onStream];
    }else if (btn == cameraBtn){
        [self onCamera];
    }else if (btn == quitBtn){
        [self onQuit];
    }
}

- (void)onCamera{
    [_kit switchCamera];
}

- (void)onCapture{
    _profilePicker.hidden = YES;
    if (!_kit.vCapDev.isRunning){
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit setupFilter:_curFilter];
        [_kit startPreview:_bgView];
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

- (void)onViewRotate{
    [self layoutUI];
    if (_kit == nil) {
        return;
    }
    UIInterfaceOrientation orie = [[UIApplication sharedApplication] statusBarOrientation];
    [_kit rotateStreamTo:orie];
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
