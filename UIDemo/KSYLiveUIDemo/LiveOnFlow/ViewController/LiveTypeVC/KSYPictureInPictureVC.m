//
//  KSYPictureInPictureVC.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/19.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYPictureInPictureVC.h"
#import "KSYStateLableView.h"
#import "KSYCustomCollectView.h"
#import "KSYHeadControl.h"
#import "KSYSettingModel.h"
#import <YYImage/YYImage.h>
#import "KSYDecalBGView.h"
#import "KSYCollectionView.h"
#import "KSYQRCode.h"
#import "KSYUIWindowVC.h"
#import "KSYLiveControlView.h"
#import "KSYRecordScreenView.h"
#import "UIView+Toast.h"

@interface KSYPictureInPictureVC (){
    //与logo相关的变量
    KSYGPUPicture         *_logoPicure; //静态图标
    UIImageOrientation     _logoOrientation; //图片的方向
    YYImageDecoder         *_animateDecoder;   //解码器
    NSLock                 *_dlLock;  //加锁
    NSTimeInterval         _dlTime;
    CADisplayLink          *_displayLink;  //跟屏幕刷新频率一样的定时器
    int                     _animateIdx;     //动画的索引
    UIImageView            *_foucsCursorImageView;//对焦框
    
}
@property (nonatomic,strong) KSYCustomCollectView *collectView; //功能视图的view
@property (nonatomic,strong) KSYSecondView *skinCareView; //美颜的二级视图的view
@property (nonatomic,readonly) KSYDecalBGView *decalBGView; //贴纸的视图
@property (nonatomic,readonly) KSYCollectionView *decalBgSuperView; //贴纸的父视图

@property (nonatomic,strong) UIView *topView; //界面顶部视图UI
@property (nonatomic,strong) KSYLiveControlView *liveUIView; //直播UI
@property (nonatomic,strong) KSYRecordScreenView *recordScreenView; //录屏UI
@property(nonatomic,strong)KSYStateLableView *infoLabel; //提示信息

@property (nonatomic,copy) NSString *byPassFilePath; //旁路录像文件的路径
@property (nonatomic,assign) BOOL mirrorState; //镜像状态
@property (nonatomic,assign) BOOL muteState; //静音状态

@property (nonatomic,assign) NSInteger skinCareSelectIndex; //美颜选中的索引
@property (nonatomic,assign) float exfoliatingSliderValue; //磨皮
@property (nonatomic,assign) float whiteSliderValue; //美白
@property (nonatomic,assign) float hongrunSliderValue; //红润

@property(nonatomic,copy)NSURL *videoUrl; //播放视频的url
@property(nonatomic,copy)NSURL *backgroundPicUrl; //背景图片的url

@end

@implementation KSYPictureInPictureVC
#pragma mark -
#pragma mark - life cycle 视图的生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setKitParameter];
    [self beginCapture];
    [self streamFunc];
    [self addTopSubView];
    [self addLiveUI];
    [self addStickerView];
    [self addRecordView];
    //[self addInfoLabel];
    [self addFoucsCursorgeImageView];
    [self addObserver];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //显示直播顶部UI视图
    self.topView.hidden = NO;
    //显示直播UI视图
    self.liveUIView.hidden = NO;
}

#pragma mark -
#pragma mark - private Methods 私有方法
/**
 设置kit的参数
 */
-(void)setKitParameter{
    
     self.view.backgroundColor = [UIColor blackColor];
    _dlLock = [[NSLock alloc]init];
    
    //资源路径
    NSURL *url=  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"RecordAv" ofType:@"mp4"]];
    self.videoUrl = url;
    
   NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"背景图片" ofType:@"png"];
    NSURL *bgUrl = [NSURL fileURLWithPath:imagePath];
    self.backgroundPicUrl = bgUrl;
    
    //[self downloadGPUResource];
    
//    //添加左滑手势
//    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//    [self.safeAreaView addGestureRecognizer:leftRecognizer];
//    //添加左滑手势：
//    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//    [rightRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [self.safeAreaView addGestureRecognizer:rightRecognizer];
    
    
    if (!_wxStreamerKit) {
        _wxStreamerKit = [[KSYGPUPipStreamerKit alloc]init];
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
    
    //旁路录制会回调该block
    self.byPassFilePath =[NSHomeDirectory() stringByAppendingString:@"/Library/Caches/rec.mp4"];
    weakObj(self);
    _wxStreamerKit.streamerBase.bypassRecordStateChange = ^(KSYRecordState recordState) {
        [selfWeak onBypassRecordStateChange:recordState];
    };
    
    //设置美颜滑块的默认值
    self.exfoliatingSliderValue = 0.5;
    self.whiteSliderValue = 0.5;
    self.hongrunSliderValue = 0.5;
    
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
        
        _wxStreamerKit.videoOrientation = UIInterfaceOrientationPortrait;
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
-(void)addTopSubView{
    
    self.topView = [[UIView alloc]init];
    [self.safeAreaView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.safeAreaView);
        make.top.equalTo(self.safeAreaView).offset(20);
        make.width.equalTo(self.safeAreaView);
        make.height.mas_equalTo(@45);
    }];
    
    KSYHeadControl *control = [[KSYHeadControl alloc]init];
    [self.topView addSubview:control];
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(10);
        make.top.equalTo(self.topView);
        make.width.mas_equalTo(@120);
        make.height.mas_equalTo(@45);
    }];
    
    UIButton* closeBtn = [[UIButton alloc]initButtonWithTitle:@"" titleColor:[UIColor whiteColor] font:KSYUIFont(14) backGroundColor:KSYRGB(112,87,78)  callBack:^(UIButton *sender) {
        NSLog(@"%@",@"关闭");
        //从父视图中移除
        [self.collectView removeFromSuperview];
        //移除美颜的二级视图
        [self.skinCareView removeFromSuperview];
        
        [self closePictureInPictureLive];
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
    KSYLiveControlView *liveUIView = [[KSYLiveControlView alloc]init];
    [liveUIView setUpButtonView:@"竖屏"];
    [liveUIView.floatWindowButton  setBackgroundImage:[UIImage imageNamed:@"开启画中画"] forState:UIControlStateNormal];
    [liveUIView.floatWindowButton  setBackgroundImage:[UIImage imageNamed:@"关闭画中画"] forState:UIControlStateSelected];
    
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

/**
 添加贴纸图层
 */
-(void)addStickerView{
    KSYWeakSelf;
    //贴纸页面(贴纸列表view在贴纸页面创建的时候就会添加到这个图层上)
    _decalBgSuperView = [[KSYCollectionView alloc]init];
    _decalBgSuperView.DEBlock = ^(NSString *imgName){
        [weakSelf genDecalViewWithImgName:imgName];
    };
    //贴纸回调事件
    _decalBgSuperView.onBtnBlock=^(id sender){
        
        weakSelf.topView.hidden = NO;
        weakSelf.liveUIView.hidden = NO;
        weakSelf.decalBgSuperView.hidden = YES;
        
        if(weakSelf.decalBGView){
            [weakSelf.decalBGView removeFromSuperview];
            [weakSelf.safeAreaView insertSubview:weakSelf.decalBGView belowSubview:weakSelf.decalBgSuperView];
            weakSelf.decalBGView.interactionEnabled = NO;
        }
        [weakSelf updateAePicView];
        
    };
    [self.safeAreaView addSubview:_decalBgSuperView];
    
    _decalBGView = [[KSYDecalBGView alloc] init];
    [self.decalBgSuperView addSubview:_decalBGView];
    [self.decalBgSuperView sendSubviewToBack:_decalBGView];
    [_decalBgSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.safeAreaView).offset(0);
        make.bottom.equalTo(self.safeAreaView).offset(0);
        make.width.equalTo(self.safeAreaView);
        make.height.mas_equalTo(KSYScreenHeight);
    }];
    
    CGRect previewRect = [self calcPreviewRect:16.0/9.0];
    if (_decalBGView){
        _decalBGView.frame = previewRect;
        [self updateAePicView];
    }
    //隐藏贴纸视图
    self.decalBgSuperView.hidden = YES;
    //点击贴纸完成按钮
    self.decalBgSuperView.completeBlock = ^(UIButton *button) {
        //显示界面上面的控件
        weakSelf.topView.hidden = NO;
        weakSelf.liveUIView.hidden = NO;
        weakSelf.decalBgSuperView.hidden = YES;
        
        [weakSelf.collectView removeFromSuperview];
        [weakSelf.skinCareView removeFromSuperview];
        
        if(weakSelf.decalBGView){
            [weakSelf.decalBGView removeFromSuperview];
            [weakSelf.safeAreaView insertSubview:weakSelf.decalBGView belowSubview:weakSelf.decalBgSuperView];
            weakSelf.decalBGView.interactionEnabled = NO;
        }
        [weakSelf updateAePicView];
    };
    
}
// 添加录屏的视图
-(void)addRecordView{
    
    KSYWeakSelf;
    //录屏的view
    self.recordScreenView = [[KSYRecordScreenView alloc]init];
    self.recordScreenView.cancelOrSaveBlock = ^(UIButton *button) {
        //取消
        if (button.tag == 400) {
            
            weakSelf.liveUIView.hidden = NO;
            weakSelf.topView.hidden = NO;
            weakSelf.recordScreenView.hidden  = YES;
            [weakSelf.recordScreenView clearViewContent];
            //关闭旁路录制
            [weakSelf onBypassRecord:NO];
            
        }
        //保存
        else if (button.tag == 401){
            //保存视频
            [weakSelf.recordScreenView clearViewContent];
            [weakSelf saveVideoToAlbum:weakSelf.byPassFilePath];
            weakSelf.liveUIView.hidden = NO;
            weakSelf.topView.hidden = NO;
            weakSelf.recordScreenView.hidden  = YES;
        }
        //录制
        else if (button.tag == 402){
            
            if (button.selected) {
                [weakSelf onBypassRecord:YES];
            }
            else{
                button.hidden = YES;
                weakSelf.recordScreenView.saveButton.hidden = NO;
                [weakSelf onBypassRecord:NO];
            }
        }
    };
    [self.safeAreaView addSubview:self.recordScreenView];
    [self.recordScreenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.safeAreaView);
    }];
    self.recordScreenView.hidden = YES;
}

////添加提示信息
//-(void)addInfoLabel{
//    self.infoLabel = [[KSYStateLableView alloc]init];
//    self.infoLabel.frame = CGRectMake(0, 80, KSYScreenWidth, 400);
//    [self.safeAreaView addSubview:self.infoLabel];
//}
//添加对焦控件
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
    
    //定时器
    KSYWeakProxy *proxy = [KSYWeakProxy proxyWithTarget:self];
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:proxy
                                                 selector:@selector(onTimer:)
                                                 userInfo:nil
                                                  repeats:YES];
    
    //监听音调、音乐参数的改变
    [notification addObserver:self selector:@selector(streamVolumnOrVoiceChangeState:) name:KSYStreamVoiceOrVolumnNotice object:nil];
    //监听美颜参数的改变
    [notification addObserver:self selector:@selector(streamSkinCareChangeState:) name:KSYSkinCareChangeNotice object:nil];
}
/**
 移除观察者
 */
-(void)removeObserver{
    [[NSNotificationCenter defaultCenter]removeObserver: self];
}
/**
 @abstract 将UI的坐标转换成相机坐标
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
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

//- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
//    
//    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
//        NSLog(@"swipe left");
//        self.infoLabel.alpha = 0;
//    }
//    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
//        NSLog(@"swipe right");
//        self.infoLabel.alpha = 1;
//    }
//}

#pragma mark -
#pragma mark - public methods 公有方法
//timer respond per second
- (void)onTimer:(NSTimer *)theTimer{
    if (_wxStreamerKit.streamerBase.streamState == KSYStreamStateConnected ) {
        [self.infoLabel updateState: _wxStreamerKit.streamerBase];
    }
    
}
#pragma mark -
#pragma mark - Override 复写方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //判断当前视图是不是录屏视图
    if (self.recordScreenView.hidden == NO) {
    }
    //判断当前视图是不是贴纸视图
    else if(self.decalBgSuperView.hidden == NO){
    }
    else{
        [self.collectView removeFromSuperview];
        [self.skinCareView removeFromSuperview];
        //显示直播顶部UI视图
        self.topView.hidden = NO;
        //显示直播UI视图
        self.liveUIView.hidden = NO;
        //隐藏录制视图
        self.recordScreenView.hidden = YES;
        
    }
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

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等

//开启画中画直播
-(void)beginPictureInPictureLive{
    [_wxStreamerKit startPipWithPlayerUrl:self.videoUrl
                                    bgPic:self.backgroundPicUrl];
    [_wxStreamerKit.player play];
    
}
//关闭画中画直播
-(void)closePictureInPictureLive{
    //[_wxStreamerKit.player stop];
    [_wxStreamerKit stopPip];
    
}
/**
 直播界面上的按钮的响应方法
 */
-(void)buttonClickAction:(UIButton*)button{
    KSYWeakSelf;
    //美颜
    if (button.tag == 200) {
        //隐藏UI视图
        self.liveUIView.hidden = YES;
        
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
    //截屏
    else if (button.tag == 201){
        GPUImageOutput * filter = _wxStreamerKit.vPreviewMixer;
        if (filter){
            [filter useNextFrameForImageCapture];
            UIImage * img =  filter.imageFromCurrentFramebuffer;
            [KSYUIBaseViewController saveImage: img
                                            to: @"snap2.png" ];
            UIImageWriteToSavedPhotosAlbum(img,nil,nil,nil);
            
            [self.view makeToast:@"截图已保存至手机相册" duration:0.5 position:CSToastPositionCenter];
            
            
        }
    }
    //录屏
    else if (button.tag == 202){
        self.recordScreenView.hidden = NO;
        self.topView.hidden = YES;
        self.liveUIView.hidden = YES;
    }
    //悬浮窗  变成画中画
    else if (button.tag == 203){
        button.selected = !button.selected;
        if (button.selected) {
            [self beginPictureInPictureLive];
        }
        else{
            [self closePictureInPictureLive];
        }
    }
    //相机翻转
    else if (button.tag == 204){
        [_wxStreamerKit switchCamera];
    }
    //闪光灯
    else if (button.tag == 205){
        button.selected = !button.selected;
        [_wxStreamerKit toggleTorch];
    }
    //功能
    else if (button.tag == 206){
        
        self.liveUIView.hidden = YES;
        
        self.collectView = [[KSYCustomCollectView alloc]init];
        //设置每次设置的参数
        self.collectView.volumnSliderValue = _wxStreamerKit.bgmPlayer.bgmVolume;
        self.collectView.voiceSliderValue = _wxStreamerKit.bgmPlayer.bgmPitch;
        self.collectView.muteState = self.muteState;
        self.collectView.mirrorState = self.mirrorState;
        
        self.collectView.titleBlock = ^(NSString *title,BOOL muteState) {
            if ([title isEqualToString:@"镜像"]) {
                weakSelf.mirrorState = muteState;
                //                weakSelf.mirrorState = !weakSelf.mirrorState;
                weakSelf.wxStreamerKit.streamerMirrored = weakSelf.mirrorState;
                weakSelf.wxStreamerKit.previewMirrored = weakSelf.mirrorState;
            }
            else if ([title isEqualToString:@"闪光灯"]){
                
            }
            else if([title isEqualToString:@"静音"]){
                weakSelf.muteState = muteState;
                [weakSelf.wxStreamerKit.streamerBase muteStream:weakSelf.muteState];
            }
            else if ([title isEqualToString:@"背景音乐"]){
                
            }
            else if ([title isEqualToString:@"拉流地址"]){
                
                [weakSelf.collectView removeFromSuperview];
                KSYQRCode *playUrlQRCodeVc = [[KSYQRCode alloc] init];
                //状态为直播视频
                //推流地址对应的拉流地址
                NSString * uuidStr =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
                NSString *devCode  = [[uuidStr substringToIndex:3] lowercaseString];
                NSString *streamPlaySrv = @"rtmp://mobile.kscvbu.cn/live";
                //NSString *streamPlayPostfix = @".flv";
                playUrlQRCodeVc.url = [ NSString stringWithFormat:@"%@/%@", streamPlaySrv, devCode];
               [weakSelf presentViewController:playUrlQRCodeVc animated:YES completion:nil];
            }
            
            
        };
        
        self.collectView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
        [self.collectView showView];
    }
    //贴纸
    else if (button.tag == 207){
        
        _topView.hidden = YES;
        _liveUIView.hidden = YES;
        _decalBgSuperView.hidden = NO;
        
        if(_decalBGView){
            [_decalBGView removeFromSuperview];
            [_decalBgSuperView addSubview:_decalBGView];
            [_decalBgSuperView sendSubviewToBack:_decalBGView];
            _decalBGView.interactionEnabled = YES;
        }
    }
    else{
        
    }
}

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
            //NSLog(@"----%@",@"发生错误");
            break;
    }
}

/**
 监听美颜等参数的改变
 
 @param notice notice
 */
-(void)streamSkinCareChangeState:(NSNotification*)notice{
    NSDictionary* dic =notice.userInfo;
    
    self.whiteSliderValue = [[dic valueForKey:@"美白"] floatValue];
    self.hongrunSliderValue = [[dic valueForKey:@"红润"] floatValue];
    self.exfoliatingSliderValue = [[dic valueForKey:@"磨皮"] floatValue];
    [self sliderChange:self.skinCareSelectIndex];
}
/**
 监听音量、音调等滑块值的改变
 @param notice 通知信息
 */
- (void)streamVolumnOrVoiceChangeState:(NSNotification*)notice {
    //KSYWeakSelf;
    NSDictionary* dic =notice.userInfo;
    
    // 修改本地播放音量  观众音量请调节mixer的音量
    _wxStreamerKit.bgmPlayer.bgmVolume = [[dic valueForKey:@"音量"] floatValue];
    [_wxStreamerKit.aMixer  setMixVolume:[[dic valueForKey:@"音量"] floatValue] of: _wxStreamerKit.bgmTrack];
    
    // 同时修改本地和观众端的 音调 (推荐变调的取值范围为 -3 到 3的整数)
    _wxStreamerKit.bgmPlayer.bgmPitch = [[dic valueForKey:@"音调"] floatValue];
}
#pragma mark - 监听配置改变的通知
-(void)streamConfigChange:(NSNotification*)notice{
    
    NSDictionary* dic =notice.userInfo;
    for (NSString* string in [dic allKeys]) {
        //混响设置
        if ([string isEqualToString:@"混响"]) {
            int  number = [[dic valueForKey:string] intValue];
            _wxStreamerKit.aCapDev.reverbType = number;
        }
        //变声设置
        else if ([string isEqualToString:@"变声"]){
            int number = [[dic valueForKey:string] intValue];
            _wxStreamerKit.aCapDev.effectType = number;
        }
        //背景音乐设置
        else if ([string isEqualToString:@"背景音乐"]){
            self.filePathArray = self.fileDownLoadTool.fileList;
            int number = [[dic valueForKey:string] intValue];
            //停止播放背景音乐
            [_wxStreamerKit.bgmPlayer stopPlayBgm];
            if (number == 0) {
                return;
            }
            if (self.filePathArray.count<3) {
                return;
            }
            NSString* path = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/bgms/%@",self.filePathArray[number-1]]];
            
            if (!path) {
                return;
            }
            [_wxStreamerKit.bgmPlayer startPlayBgm:path isLoop:NO];
            
        }
        //logo设置
        else if ([string isEqualToString:@"LOGO"]){
            int number = [[dic valueForKey:string] intValue];
            if (number == 0) {
                //清除logo
                [_dlLock lock];
                _animateDecoder = nil;
                _wxStreamerKit.logoPic = nil;
                [_wxStreamerKit setLogoOrientaion:_logoOrientation];
                [_dlLock unlock];
            }
            else if (number == 1 || number == 2){
                //设置静态logo
                [_dlLock lock];
                _animateDecoder = nil;
                [_wxStreamerKit setLogoOrientaion:_logoOrientation];
                [_dlLock unlock];
                [self setUpLogo:self.pictrueNameArray[number-1]];
            }
            else{
                [self setupAnimateLogo:self.logoFileDownLoadTool.filePath];
                
            }
        }
        else if ([string isEqualToString:@"滤镜"]){
            
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
//设置动态logo 或者设置静态logo
- (void)setUpLogo:(NSString*)pictureTitle {
    
    CGFloat yPos = 0.15;
    // 预览视图的scale
    CGFloat scale = MAX(self.safeAreaView.frame.size.width, self.safeAreaView.frame.size.height) / self.safeAreaView.frame.size.height;
    CGFloat hgt  = 0.1 * scale; // logo图片的高度是预览画面的十分之一
    UIImage * logoImg = [UIImage imageNamed:@"ksvc"];
    _logoPicure   =  [[KSYGPUPicture alloc] initWithImage:logoImg];
    _wxStreamerKit.logoPic  = _logoPicure;
    _logoOrientation = logoImg.imageOrientation;
    [_wxStreamerKit setLogoOrientaion: _logoOrientation];
    //设置大小
    _wxStreamerKit.logoRect = CGRectMake(0.05, yPos, 0, hgt);
    //设置透明度
    _wxStreamerKit.logoAlpha= 0.5;
}

//贴纸相关的方法
- (void)genDecalViewWithImgName:(NSString *)imgName {
    [_decalBGView genDecalViewWithImgName:imgName];
}

- (void)setupAnimateLogo:(NSString*)path {
    CGFloat yPos = 0.15;
    // 预览视图的scale
    CGFloat scale = MAX(self.safeAreaView.frame.size.width, self.safeAreaView.frame.size.height) / self.safeAreaView.frame.size.height;
    CGFloat hgt  = 0.1 * scale; // logo图片的高度是预览画面的十分之一
    //设置大小
    _wxStreamerKit.logoRect = CGRectMake(0.05, yPos, 0, hgt);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    [_dlLock lock];
    _animateDecoder = [YYImageDecoder decoderWithData:data scale: [[UIScreen mainScreen] scale]];
    [_wxStreamerKit setLogoOrientaion:UIImageOrientationUp];
    [_dlLock unlock];
    _animateIdx = 0;
    _dlTime = 0;
    if(!_displayLink){
        KSYWeakProxy *proxy = [KSYWeakProxy proxyWithTarget:self];
        SEL dpCB = @selector(displayLinkCallBack:);
        _displayLink = [CADisplayLink displayLinkWithTarget:proxy
                                                   selector:dpCB];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
    }
}

- (void) updateAnimateLogo {
    if (_animateDecoder==nil) {
        return;
    }
    [_dlLock lock];
    YYImageFrame* frame = [_animateDecoder frameAtIndex:_animateIdx
                                       decodeForDisplay:NO];
    if (frame.image) {
        _wxStreamerKit.logoPic = [[GPUImagePicture alloc] initWithImage:frame.image];
    }
    _animateIdx = (_animateIdx+1)%_animateDecoder.frameCount;
    [_dlLock unlock];
}

- (void)displayLinkCallBack:(CADisplayLink *)link {
    dispatch_async( dispatch_get_global_queue(0, 0), ^(){
        if (_animateDecoder) {
            _dlTime += link.duration;
            // 读取 图像的 duration 来决定下一帧的刷新时间
            // 也可以固定设置为一个值来调整动画的快慢程度
            NSTimeInterval delay = [_animateDecoder frameDurationAtIndex:_animateIdx];
            if (delay < 0.04) {
                delay = 0.04;
            }
            if (_dlTime < delay) return;
            _dlTime -= delay;
            [self updateAnimateLogo];
        }
    });
}
//刷新贴纸view
- (void) updateAePicView{
    if (_decalBGView){
        _wxStreamerKit.aePic = [[GPUImageUIElement alloc] initWithView:_decalBGView];
        [_wxStreamerKit.streamerBase startStream:self.rtmpUrl];
    }
}

//旁路录制状态的改变
- (void) onBypassRecordStateChange: (KSYRecordState) newState {
    if (newState == KSYRecordStateRecording){
        NSLog(@"start bypass record");
    }
    else if (newState == KSYRecordStateStopped) {
        NSLog(@"stop bypass record");
        
    }
    else if (newState == KSYRecordStateError) {
        NSLog(@"bypass record error %@", _wxStreamerKit.streamerBase.bypassRecordErrorName);
    }
}
// bypass record & record
-(void) onBypassRecord:(BOOL)selectState{
    BOOL bRec = _wxStreamerKit.streamerBase.bypassRecordState == KSYRecordStateRecording;
    if (selectState){
        if ( _wxStreamerKit.streamerBase.isStreaming && !bRec){
            // 如果启动录像时使用和上次相同的路径,则会覆盖掉上一次录像的文件内容
            [KSYUIStreamerVC deleteFile:_byPassFilePath];
            NSURL *url =[[NSURL alloc] initFileURLWithPath:self.byPassFilePath];
            [_wxStreamerKit.streamerBase startBypassRecord:url];
        }
        else {
            NSString * msg = @"推流过程中才能旁路录像";
            [self.view makeToast:msg duration:1 position:CSToastPositionCenter];
        }
    }
    else{
        [_wxStreamerKit.streamerBase stopBypassRecord];
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
-(void)sliderChange:(NSInteger)index{
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
