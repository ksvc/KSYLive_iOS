//
//  KSYLandScapeKitVC.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/29.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYLandScapeKitVC.h"
#import "KSYCustomCollectView.h"
#import "KSYHeadControl.h"
#import "KSYSettingModel.h"
#import "KSYQRCode.h"
#import "KSYLandScapeControlView.h"
#import "UIView+Toast.h"
#import "AppDelegate.h"
#import "UIView+Extension.h"
#import "JHRotatoUtil.h"
#import "KSYSecondView.h"

@interface KSYLandScapeKitVC (){
    UIImageView *_foucsCursorImageView;//对焦框
}

@property (nonatomic,strong) UIView *topView; //界面顶部视图UI
@property (nonatomic,strong) KSYLandScapeControlView *liveUIView; //直播UI
@property (nonatomic,strong) KSYSecondView *skinCareView; //美颜视图

@property (nonatomic,assign) BOOL mirrorState; //镜像状态
@property (nonatomic,assign) BOOL muteState; //静音状态

@property (nonatomic,assign) NSInteger skinCareSelectIndex; //美颜选中的索引
@property (nonatomic,assign) float exfoliatingSliderValue; //磨皮
@property (nonatomic,assign) float whiteSliderValue; //美白
@property (nonatomic,assign) float hongrunSliderValue; //红润
//@property (nonatomic,assign) BOOL settingBool;

@end

@implementation KSYLandScapeKitVC

#pragma mark -
#pragma mark - life cycle 视图的生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setKitParameter];
    [self beginCapture];
    [self streamFunc];
    [self addTopSubView];
    [self addLiveUI];
    [self addObserver];
    [self addFoucsCursorgeImageView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //允许横竖屏切换
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 1;
    //显示直播顶部UI视图
    self.topView.hidden = NO;
    //显示直播UI视图
    self.liveUIView.hidden = NO;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [JHRotatoUtil forceOrientation: UIInterfaceOrientationLandscapeRight];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    //横竖屏切换
}

#pragma mark -
#pragma mark - private methods 私有方法
/**
 设置kit的参数
 */
-(void) setKitParameter {
    if (!_wxStreamerKit) {
        _wxStreamerKit = [[KSYGPUStreamerKit alloc]init];
    }
    //根据模型拿到推流的设置
    KSYSettingModel* model = [KSYSettingModel modelWithDictionary:self.modelSenderDic];
    //音频编码器类型
    _wxStreamerKit.streamerBase.audioCodec = model.audioCodecType;
    //视频编码器类型
    _wxStreamerKit.streamerBase.videoCodec = model.videoCodecTpye;
    //推流分辨率
    //_wxStreamerKit.previewDimension = model.strResolutionSize;
    _wxStreamerKit.streamDimension =  model.strResolutionSize;;
    //性能模式
    _wxStreamerKit.streamerBase.videoEncodePerf = model.performanceModel;
    //直播场景
    _wxStreamerKit.streamerBase.liveScene = model.liveSence;
    //videoFPS (测试)
    _wxStreamerKit.streamerBase.videoFPS = 20;
    //设置滤镜为空
    _currentFilter = nil;
    //摄像头的位置
    _wxStreamerKit.cameraPosition = AVCaptureDevicePositionBack;
    //视频输出格式
    _wxStreamerKit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    //采集格式
    _wxStreamerKit.capturePixelFormat = kCVPixelFormatType_32BGRA;
    
    _wxStreamerKit.streamerBase.videoInitBitrate =  800;
    _wxStreamerKit.streamerBase.videoMaxBitrate  = 1000;
    _wxStreamerKit.streamerBase.videoMinBitrate  =    0;
    _wxStreamerKit.streamerBase.audiokBPS        =   48;
    // 设置编码码率控制
    _wxStreamerKit.streamerBase.recScene     = KSYRecScene_ConstantQuality;
    
    //设置美颜滑块的默认值
    self.exfoliatingSliderValue = 0.5;
    self.whiteSliderValue = 0.5;
    self.hongrunSliderValue = 0.5;
    
    //设置镜像和静音
    //镜像状态
    self.mirrorState = NO;
    //静音状态
    self.muteState = NO;
}
/**
 开始预览
 */
-(void)beginCapture{
    if (!_wxStreamerKit.vCapDev.isRunning) {
        
        _wxStreamerKit.videoOrientation = UIInterfaceOrientationLandscapeRight;
        [_wxStreamerKit setupFilter:_currentFilter];
        //启动预览
        [_wxStreamerKit startPreview:self.safeAreaView];
    }
    else{
        [_wxStreamerKit stopPreview];
    }
}
/**
 开始推流
 */
-(void)streamFunc{
    if (_wxStreamerKit.streamerBase.streamState == KSYStreamStateIdle || _wxStreamerKit.streamerBase.streamState == KSYStreamStateError) {
        //启动推流
        [_wxStreamerKit.streamerBase startStream:self.rtmpUrl];
    }
    else{
        [_wxStreamerKit stopPreview];
    }
}
/** 添加顶部的按钮*/
- (void)addTopSubView {
    
    self.topView = [[UIView alloc]init];
    [self.safeAreaView addSubview:self.topView];
    //    self.topView.backgroundColor = [UIColor blueColor];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.safeAreaView);
        make.top.equalTo(self.safeAreaView).offset(20);
        make.width.equalTo(self.safeAreaView);
        make.height.mas_equalTo(@45);
    }];
    
    KSYHeadControl* control = [[KSYHeadControl alloc]init];
    [self.topView addSubview:control];
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(10);
        make.top.equalTo(self.topView);
        make.width.mas_equalTo(@120);
        make.height.mas_equalTo(@45);
    }];
    
    UIButton* closeBtn = [[UIButton alloc]initButtonWithTitle:@"" titleColor:[UIColor whiteColor] font:KSYUIFont(14) backGroundColor:KSYRGB(112,87,78)  callBack:^(UIButton *sender) {
        NSLog(@"%@",@"关闭");
        //移除美颜的二级视图
        [self.skinCareView removeFromSuperview];
        [self removeObserver];
        [_wxStreamerKit stopPreview];
        _wxStreamerKit = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"关闭"] forState:UIControlStateNormal];
    [self.topView addSubview:closeBtn];
    
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView).offset(-10);
        make.top.equalTo(control.mas_top);
        make.width.mas_equalTo(@45);
        make.height.equalTo(control.mas_height);
    }];
    
}

-(void)addLiveUI{
    KSYLandScapeControlView* liveUIView = [[KSYLandScapeControlView alloc]init];
    
    KSYWeakSelf;
    liveUIView.buttonBlock = ^(UIButton *sender) {
        //按钮响应回传。开始在congtroller里面进行设置
        [weakSelf buttonClickAction:sender];
    };
    [self.safeAreaView addSubview:liveUIView];
    [liveUIView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.safeAreaView);
        make.top.equalTo(self.topView.mas_bottom);
        make.width.equalTo(self.safeAreaView);
        make.bottom.equalTo(self.safeAreaView);
    }];
    self.liveUIView = liveUIView;
    
}

-(void)addSkinCareView{
//    //美颜视图
    self.skinCareView = [[KSYSecondView alloc]init];
    self.skinCareView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    NSArray* titleArray = @[@"美颜",@"滤镜"];
    [self.skinCareView setUpSubView:titleArray];
    [self.skinCareView showSecondView];
    
    //设置每次设置的参数
    self.skinCareView.sliderView.whiteSlider.sldier.value = self.whiteSliderValue;
    self.skinCareView.sliderView.hongrunSlider.sldier.value = self.hongrunSliderValue;
    self.skinCareView.sliderView.exfoliatingSlider.sldier.value = self.exfoliatingSliderValue;
}
- (void)addFoucsCursorgeImageView{
    _foucsCursorImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"对焦"]];
    _foucsCursorImageView.frame = CGRectMake(80, 80, 80, 80);
    [self.safeAreaView addSubview:_foucsCursorImageView];
    _foucsCursorImageView.alpha = 0;
}
/**
 添加观察者,监听推流状态改变的通知
 */
-(void)addObserver{
    //监听推流状态
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    
    [notification addObserver:self selector:@selector(streamStateChange:) name:KSYStreamStateDidChangeNotification object:nil];
    
    //监听配置改变
    [notification addObserver:self selector:@selector(streamConfigChange:) name:KYSStreamChangeNotice object:nil];
   
    //监听美颜参数的改变
    [notification addObserver:self selector:@selector(streamSkinCareChangeState:) name:KSYSkinCareChangeNotice object:nil];
}
/**
 移除观察者
 */
-(void)removeObserver{
    [[NSNotificationCenter defaultCenter]removeObserver: self];
}

//将UI的坐标转换成相机坐标
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates{
    CGSize frameSize = self.safeAreaView.frame.size;
    CGSize apertureSize = [_wxStreamerKit captureDimension];
    CGPoint point = viewCoordinates;
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    CGFloat xc = .5f;
    CGFloat yc = .5f;
    
    if (viewRatio > apertureRatio) {
        CGFloat y2 = frameSize.height;
        CGFloat x2 = frameSize.height * apertureRatio;
        CGFloat x1 = frameSize.width;
        CGFloat blackBar = (x1 - x2) / 2;
        if (point.x >= blackBar && point.x <= blackBar + x2) {
            xc = point.y / y2;
            yc = 1.f - ((point.x - blackBar) / x2);
        }
    }else {
        CGFloat y2 = frameSize.width / apertureRatio;
        CGFloat y1 = frameSize.height;
        CGFloat x2 = frameSize.width;
        CGFloat blackBar = (y1 - y2) / 2;
        if (point.y >= blackBar && point.y <= blackBar + y2) {
            xc = ((point.y - blackBar) / y2);
            yc = 1.f - (point.x / x2);
        }
    }
    return CGPointMake(xc, yc);
}
#pragma mark -
#pragma mark - Override 复写方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //显示直播顶部UI视图
    self.topView.hidden = NO;
    //显示直播UI视图
    self.liveUIView.hidden = NO;
    self.skinCareView.hidden = YES;
}
//设置摄像头对焦位置
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint current = [touch locationInView:self.safeAreaView];
    CGPoint point = [self convertToPointOfInterestFromViewCoordinates:current];
    if (_liveUIView.hidden == YES){
        return;
    }
    
    [_wxStreamerKit exposureAtPoint:point];
    [_wxStreamerKit focusAtPoint:point];
    _foucsCursorImageView.center = current;
    _foucsCursorImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    _foucsCursorImageView.alpha=1.0;
    [UIView animateWithDuration:1.0 animations:^{
        _foucsCursorImageView.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _foucsCursorImageView.alpha=0;
    }];
}

// 旋转处理，通过旋转bgView来做到画面相对手机静止不动
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        //        UIDeviceOrientation orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
        //        [self shouldRotateToOrientation:orientation];
        
        CGAffineTransform deltaTransform = coordinator.targetTransform;
        CGFloat deltaAngle = atan2f(deltaTransform.b, deltaTransform.a);
        
        CGFloat currentRotation = [[self.wxStreamerKit.preview.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
        // Adding a small value to the rotation angle forces the animation to occur in a the desired direction, preventing an issue where the view would appear to rotate 2PI radians during a rotation from LandscapeRight -> LandscapeLeft.
        currentRotation += -1 * deltaAngle + 0.0001;
        [self.wxStreamerKit.preview.layer setValue:@(currentRotation) forKeyPath:@"transform.rotation.z"];
        
        if(SYSTEM_VERSION_GE_TO(@"8.0")) {
            [self onViewRotate];
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Integralize the transform to undo the extra 0.0001 added to the rotation angle.
        CGAffineTransform currentTransform = self.wxStreamerKit.preview.transform;
        currentTransform.a = round(currentTransform.a);
        currentTransform.b = round(currentTransform.b);
        currentTransform.c = round(currentTransform.c);
        currentTransform.d = round(currentTransform.d);
        self.wxStreamerKit.preview.transform = currentTransform;
        //        if ([JHRotatoUtil isOrientationLandscape]) {
        //
        //        }
        //        else {
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.allowRotation = 0;
        appDelegate.settingModel.recording = NO;
        //}
        //        UITouch* touch;
        //        [self touchesBegan:touch withEvent:nil];
    }];
}

- (void)onViewRotate { //对UI旋转的响应
    
    CGFloat x = CGRectGetMidX(self.safeAreaView.bounds);
    CGFloat y = CGRectGetMidY(self.safeAreaView.bounds);
    self.wxStreamerKit.preview.center = CGPointMake(x,y);
    
    UIInterfaceOrientation orie = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self.wxStreamerKit rotatePreviewTo:orie];
    // 1. 旋转推流方向
    [self.wxStreamerKit rotateStreamTo:orie];
    // self.settingBool = YES;
}

//- (BOOL)shouldAutorotate {
//    if (self.settingBool) {
//         self.settingBool = YES;
//         return NO;
//    }
//    return YES;
//}
#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
/**
 监听推流状态的改变
 */
-(void)streamStateChange:(NSNotification*)notice{
    switch (_wxStreamerKit.streamerBase.streamState) {
        case KSYStreamStateIdle:
            NSLog(@"-----%@",@"空闲状态");
            break;
        case KSYStreamStateConnected:
            NSLog(@"----%@",@"连接中");
            break;
        case KSYStreamStateDisconnecting:
            NSLog(@"----%@",@"断开连接中");
        default:
           // NSLog(@"----%@",@"发生错误");
            break;
    }
}
// 监听美颜等参数的改变
- (void)streamSkinCareChangeState:(NSNotification*)notice {
    NSDictionary* dic =notice.userInfo;
    
    self.whiteSliderValue = [[dic valueForKey:@"美白"] floatValue];
    self.hongrunSliderValue = [[dic valueForKey:@"红润"] floatValue];
    self.exfoliatingSliderValue = [[dic valueForKey:@"磨皮"] floatValue];
    //默认一组美颜
    self.skinCareSelectIndex = 1;
    [self sliderChange:self.skinCareSelectIndex];
}
//监听音量、音调等滑块值的改变
- (void)streamVolumnOrVoiceChangeState:(NSNotification*)notice {
    //KSYWeakSelf;
    NSDictionary* dic =notice.userInfo;
    
    // 修改本地播放音量  观众音量请调节mixer的音量
    _wxStreamerKit.bgmPlayer.bgmVolume = [[dic valueForKey:@"音量"] floatValue];
    [_wxStreamerKit.aMixer  setMixVolume:[[dic valueForKey:@"音量"] floatValue] of: _wxStreamerKit.bgmTrack];
    
    // 同时修改本地和观众端的 音调 (推荐变调的取值范围为 -3 到 3的整数)
    _wxStreamerKit.bgmPlayer.bgmPitch = [[dic valueForKey:@"音调"] floatValue];
}

//监听配置改变的通知
- (void)streamConfigChange:(NSNotification*)notice {
    
    NSDictionary *dic =notice.userInfo;
    for (NSString *string in [dic allKeys]) {
    
         if ([string isEqualToString:@"滤镜"]){
            
            int number = [[dic valueForKey:string] intValue];
            if (number == 0) {
                _currentFilter = nil;
                [_wxStreamerKit setupFilter: _currentFilter];//取消滤镜只要将_filter置为nil就行
            }
            else {
                [self setUpFilterToView:number];
                
            }
        }
        else if ([string isEqualToString:@"美颜"]){
            int number = [[dic valueForKey:string] intValue];
            //记录美颜的索引
            self.skinCareSelectIndex = number;
            [self sliderChange:number];
        }
        
    }
}
/**
 直播界面上的按钮的响应方法
 */
- (void)buttonClickAction:(UIButton*)button {
    KSYWeakSelf;
    //相机翻转
    if (button.tag == 600) {
       [_wxStreamerKit switchCamera];
    }
    //闪光灯
    else if (button.tag == 601){
        button.selected = !button.selected;
        [_wxStreamerKit toggleTorch];
    }
    //美颜
    else if (button.tag == 602){
        //隐藏UI视图
        self.liveUIView.hidden = YES;
        
        [self addSkinCareView];
    }
    //镜像
    else if (button.tag == 603){
        weakSelf.mirrorState = !weakSelf.mirrorState;
        weakSelf.wxStreamerKit.streamerMirrored = weakSelf.mirrorState;
        weakSelf.wxStreamerKit.previewMirrored = weakSelf.mirrorState;
    }
    //音量
    else if (button.tag == 604){
        button.selected = !button.selected;
        weakSelf.muteState = !weakSelf.muteState;
        [weakSelf.wxStreamerKit.streamerBase muteStream:weakSelf.muteState];
    }
    //拉流地址
    else if (button.tag == 605){
    
        KSYQRCode *playUrlQRCodeVc = [[KSYQRCode alloc] init];
        //状态为直播视频
        //推流地址对应的拉流地址
        NSString * uuidStr =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *devCode  = [[uuidStr substringToIndex:3] lowercaseString];
        NSString *streamPlaySrv = @"rtmp://mobile.kscvbu.cn/live";
        //NSString *streamPlayPostfix = @".flv";
        UIDeviceOrientation orientation = (UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
            playUrlQRCodeVc.imageViewOrientation = KSYDeviceOrientationLandscape;
        }
        else{
            playUrlQRCodeVc.imageViewOrientation = KSYDeviceOrientationPortrait;
        }
        playUrlQRCodeVc.url = [ NSString stringWithFormat:@"%@/%@", streamPlaySrv, devCode];
        [weakSelf presentViewController:playUrlQRCodeVc animated:YES completion:nil];
    }
    else{
        
    }
}
/**
 滤镜
 
 @param index 滤镜的索引
 */
- (void)setUpFilterToView:(NSInteger)index {
    //滤镜
    if (index == 0){//原型
        _curEffectsFilter = nil;
    }else{ // filter graph : proFilter->builtInSpecialEffects
        if (_curEffectsFilter) {
            [_curEffectsFilter setSpecialEffectsIdx:index];
        }else{
            _curEffectsFilter = [[KSYBuildInSpecialEffects alloc] initWithIdx:index];
        }
    }
    [_wxStreamerKit setupFilter:[self setupFilterGroup]];
    
}
//滑块滑动
- (void)sliderChange:(NSInteger)index{
    //滤镜置为空
    if(index == 0 ){
        _currentFilter  = nil;
        [_wxStreamerKit setupFilter:_currentFilter];
    }
    else if (index == 1 || index == 2){
        //设置美颜滤镜
        KSYBeautifyProFilter * filter = [[KSYBeautifyProFilter alloc] initWithIdx:index];
        filter.grindRatio  = self.exfoliatingSliderValue;
        filter.whitenRatio = self.whiteSliderValue;
        filter.ruddyRatio  = self.hongrunSliderValue;
        _currentFilter = filter;
        [_wxStreamerKit setupFilter:[self setupFilterGroup]];
    }
    //设置白皙滤镜
    else{
        //拿到资源文件的路径
        NSString *imgPath=[self.gpuResourceDir stringByAppendingString:@"3_tianmeikeren.png"];
        UIImage *rubbyMat=[[UIImage alloc]initWithContentsOfFile:imgPath];
        
        KSYBeautifyFaceFilter *filter = [[KSYBeautifyFaceFilter alloc] initWithRubbyMaterial:rubbyMat];
        filter.grindRatio  = self.exfoliatingSliderValue;
        filter.whitenRatio = self.whiteSliderValue;
        filter.ruddyRatio  = self.hongrunSliderValue;
        _currentFilter = filter;
        [_wxStreamerKit setupFilter:[self setupFilterGroup]];
    }
}

/**
 设置滤镜组
 
 @return 设置滤镜
 */
- (GPUImageOutput<GPUImageInput>*)setupFilterGroup{
    GPUImageOutput<GPUImageInput>* filter = _currentFilter;
    if (_curEffectsFilter) {
        if (_currentFilter) {
            GPUImageFilterGroup *fg = [[GPUImageFilterGroup alloc] init];
            [_currentFilter removeAllTargets];
            [_currentFilter addTarget:_curEffectsFilter];
            [fg addFilter:_currentFilter];
            [fg addFilter:_curEffectsFilter];
            
            [fg setInitialFilters:@[_currentFilter]];
            [fg setTerminalFilter:_curEffectsFilter];
            
            filter = fg;
        }else{
            filter = _curEffectsFilter;
        }
    }
    return filter;
}

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
