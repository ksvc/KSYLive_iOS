//
//  KSYSimplestStreamerVC.m
//  KSYLiveDemo
//
//  Created by 孙健 on 2017/2/7.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYSimplestStreamerVC.h"

@interface KSYSimplestStreamerVC ()<UIPickerViewDataSource,
UIPickerViewDelegate>{
    NSArray * _profileNames;//存放各个清晰度标签
}

@property NSInteger         curProfileIdx;
@property UILabel           *streamState;//推流状态

@end

@implementation KSYSimplestStreamerVC
- (id)initWithUrl:(NSURL *)rtmpUrl{
    if (self = [super init]) {
        _url = rtmpUrl;
        [self addObserver];
    }
    return self;
}
- (void)addObserver{ //监听推流状态改变的通知
    NSNotificationCenter * dc = [NSNotificationCenter defaultCenter] ;
    [dc addObserver:self
           selector:@selector(streamStateChanged)
               name:KSYStreamStateDidChangeNotification
             object:nil];
}
- (void)removeObserver{//移除观察者
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
    if (!_kit){
        _kit = [[KSYGPUStreamerKit alloc] init];
    }
    _curFilter = [[KSYGPUBeautifyExtFilter alloc] init];
    //摄像头位置
    _kit.cameraPosition = AVCaptureDevicePositionFront;
    //视频输出格式
    _kit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    //采集格式
    _kit.capturePixelFormat   = kCVPixelFormatType_32BGRA;
    self.view.backgroundColor = [UIColor whiteColor];
    _profileNames = [NSArray arrayWithObjects:@"360p_auto",@"360p_1",@"360p_2",@"360p_3",@"540p_auto",
                     @"540p_1",@"540p_2",@"540p_3",@"720p_auto",
                     @"720p_1",@"720p_2",@"720p_3",nil];
    [self setupUI];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)setupUI{
    _bgView = [[UIView alloc] init];
    [self.view addSubview: _bgView];
    _ctrlView = [[KSYUIView alloc] initWithFrame:self.view.bounds];
    @WeakObj(self);
    _ctrlView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };

    // top view
    _quitBtn = [_ctrlView addButton:@"退出"];
    _streamState = [_ctrlView addLable:@"空闲状态"];
    _streamState.textColor = [UIColor redColor];
    _streamState.textAlignment = NSTextAlignmentCenter;
    _cameraBtn = [_ctrlView addButton:@"前后摄像头"];
    
    // profile picker
    _profilePicker = [[UIPickerView alloc] init];
    _profilePicker.delegate   = self;
    _profilePicker.dataSource = self;
    _profilePicker.showsSelectionIndicator= YES;
    _profilePicker.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    [_profilePicker selectRow:7 inComponent:0 animated:YES];
    
    // bottom view
    _captureBtn = [_ctrlView addButton:@"开始预览"];
    _streamBtn = [_ctrlView addButton:@"开始推流"];

    [self.view addSubview:_ctrlView];
    [_ctrlView addSubview:_profilePicker];
    [self layoutUI];
}

- (void)layoutUI{
    CGRect previewRect = [self calcPreviewRect:16.0/9.0]; //
    _bgView.frame = previewRect;
    _ctrlView.frame = previewRect;
    [_ctrlView layoutUI];
    if (previewRect.origin.y > 0) {
        _ctrlView.yPos = 0;
    }
    [_ctrlView putRow:@[_quitBtn, _streamState, _cameraBtn]];
    _profilePicker.frame = CGRectMake(10, _ctrlView.yPos+_ctrlView.btnH, _ctrlView.width-20, 216);
    _ctrlView.yPos = previewRect.size.height - 30;
    [_ctrlView putRow:@[_captureBtn, [UIView new], _streamBtn]];
}

- (void)onBtn:(UIButton *)btn{
    if (btn == _captureBtn) {
        [self onCapture]; //启停预览
    }else if (btn == _streamBtn){
        [self onStream]; //启停推流
    }else if (btn == _cameraBtn){
        [self onCamera]; //切换前后摄像头
    }else if (btn == _quitBtn){
        [self onQuit]; //退出
    }
}

- (void)onCamera{ //切换前后摄像头
    [_kit switchCamera];
}

- (void)onCapture{
    _profilePicker.hidden = YES;
    if (!_kit.vCapDev.isRunning){
        _kit.videoOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        [_kit setupFilter:_curFilter];
        [_kit startPreview:_bgView]; //启动预览
    }
    else {
        [_kit stopPreview];
    }
}
- (void)onStream{
    if (_kit.streamerBase.streamState == KSYStreamStateIdle ||
        _kit.streamerBase.streamState == KSYStreamStateError) {
        [_kit.streamerBase startStream:_url]; //启动推流
    }
    else { //停止推流
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

#pragma mark - view rotate
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
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGFloat x = CGRectGetMidX(self.bgView.bounds);
    CGFloat y = CGRectGetMidY(self.bgView.bounds);
    self.kit.preview.center = CGPointMake(x,y);
}

#pragma mark - 旋转预览 iOS > 8.0
// 旋转处理，通过旋转bgView来做到画面相对手机静止不动
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        CGAffineTransform deltaTransform = coordinator.targetTransform;
        CGFloat deltaAngle = atan2f(deltaTransform.b, deltaTransform.a);
        
        CGFloat currentRotation = [[self.kit.preview.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
        // Adding a small value to the rotation angle forces the animation to occur in a the desired direction, preventing an issue where the view would appear to rotate 2PI radians during a rotation from LandscapeRight -> LandscapeLeft.
        currentRotation += -1 * deltaAngle + 0.0001;
        [self.kit.preview.layer setValue:@(currentRotation) forKeyPath:@"transform.rotation.z"];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Integralize the transform to undo the extra 0.0001 added to the rotation angle.
        CGAffineTransform currentTransform = self.kit.preview.transform;
        currentTransform.a = round(currentTransform.a);
        currentTransform.b = round(currentTransform.b);
        currentTransform.c = round(currentTransform.c);
        currentTransform.d = round(currentTransform.d);
        self.kit.preview.transform = currentTransform;
    }];
}

@end
