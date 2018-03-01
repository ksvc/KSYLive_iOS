//
//  KSYBackgroundPushVC.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/17.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYBackgroundPushVC.h"
#import "KSYUIStreamerVC.h"
#import "KSYCustomCollectView.h"
#import "KSYHeadControl.h"
#import "KSYSettingModel.h"
#import "KSYQRCode.h"
#import "KSYLiveControlView.h"
#import "UIView+Toast.h"
#import "KSYQRCode.h"

@interface KSYBackgroundPushVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) KSYCustomCollectView *collectView; //功能视图的view
@property (nonatomic,strong) UIView *topView; //界面顶部视图UI
@property (nonatomic,strong) KSYLiveControlView *liveUIView; //直播UI
@property (nonatomic,strong) UIView* backGroundView; //背景图视图
@property (nonatomic,strong) UIView* controlView; //控制视图

@property(nonatomic,assign)BOOL muteState; //静音状态

@end

@implementation KSYBackgroundPushVC
#pragma mark -
#pragma mark - life cycle 视图的生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setKitParameter];
    [self beginCapture];
    [self streamFunc];
    [self addTopSubView];
    [self addLiveUI];
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //显示直播顶部UI视图
    self.topView.hidden = NO;
    //显示直播UI视图
    self.liveUIView.hidden = NO;
}

#pragma mark -
#pragma mark - 私有方法
/**
 设置kit的参数
 */
- (void)setKitParameter {
    
    self.backGroundView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.safeAreaView addSubview:self.backGroundView];
    
    self.controlView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.safeAreaView addSubview:self.controlView];
    
    self.view.backgroundColor = [UIColor blackColor];
    if (!_wxStreamerKit) {
        _wxStreamerKit = [[KSYGPUStreamerKit alloc]init];
    }
    KSYSettingModel *model = [KSYSettingModel modelWithDictionary:self.modelSenderDic];
    //音频编码器类型
    _wxStreamerKit.streamerBase.audioCodec = model.audioCodecType;
    //视频编码器类型
    _wxStreamerKit.streamerBase.videoCodec = model.videoCodecTpye;
    //推流分辨率
    //_wxStreamerKit.previewDimension = model.strResolutionSize;
    //背景图片设置参数
    CGSize streamSize = model.strResolutionSize;
    _wxStreamerKit.streamDimension =  CGSizeMake(streamSize.height, streamSize.width);
    //性能模式
    _wxStreamerKit.streamerBase.videoEncodePerf = model.performanceModel;
    //直播场景
    _wxStreamerKit.streamerBase.liveScene = model.liveSence;
    
    //videoFPS (测试)
    _wxStreamerKit.streamerBase.videoFPS = 20;
    
    //视频输出格式
    _wxStreamerKit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    
    //视频编码
    _wxStreamerKit.streamerBase.videoInitBitrate =  800;
    _wxStreamerKit.streamerBase.videoMaxBitrate  = 1000;
    _wxStreamerKit.streamerBase.videoMinBitrate  =    0;
    _wxStreamerKit.streamerBase.audiokBPS        =   48;
    // 设置编码码率控制
    _wxStreamerKit.streamerBase.recScene = KSYRecScene_ConstantQuality;
    //旁路录制会回调该block
    UIImage *image = [UIImage imageNamed:@"背景图"];
    if (!self.wxStreamerKit.bgPic) {
        if (image) {
            [self.wxStreamerKit updateBgpImage:image];
        }
    }
    if (image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight){
        _wxStreamerKit.previewDimension = CGSizeMake(_wxStreamerKit.bgPic.outputImageSize.height, _wxStreamerKit.bgPic.outputImageSize.width);
    }else{
        _wxStreamerKit.previewDimension = _wxStreamerKit.bgPic.outputImageSize;
    }
    //静音状态
    self.muteState = NO;
}

/**
 开始预览
 */
- (void)beginCapture {
    //启动预览
     [self.wxStreamerKit startBgpPreview:self.backGroundView];
   
}
/**
 开始推流
 */
- (void)streamFunc {
    if (_wxStreamerKit.streamerBase.streamState == KSYStreamStateIdle || _wxStreamerKit.streamerBase.streamState == KSYStreamStateError) {
        //启动推流
        [_wxStreamerKit startBgpStream:self.rtmpUrl];
    }
    else{
        [_wxStreamerKit stopBgpStream];
    }
}
/**
 添加顶部的按钮
 */
- (void)addTopSubView {
    
    self.topView = [[UIView alloc]init];
    [self.controlView addSubview:self.topView];
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
        //从父视图中移除
        [self.collectView removeFromSuperview];
        //移除监听者
        [self removeObserver];
        //关闭预览视图
        [_wxStreamerKit stopPreview];
        //将kit置空
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
/**
 添加直播界面
 */
- (void)addLiveUI {
    KSYLiveControlView* liveUIView = [[KSYLiveControlView alloc]init];
    [liveUIView setUpButtonView:@"竖屏"];
    //隐藏按钮
    liveUIView.recordButton.hidden = YES;
    liveUIView.screenShotButton.hidden = YES;
    liveUIView.flashButton.hidden = YES;
    liveUIView.skinCareButton.hidden = YES;
    liveUIView.stickerButton.hidden = YES;
    
    //更换按钮的图片
    [liveUIView.cameraButton setBackgroundImage:[UIImage imageNamed:@"切换背景图"] forState: UIControlStateNormal];
    [liveUIView.functionButton setBackgroundImage:[UIImage imageNamed:@"拉流地址"] forState: UIControlStateNormal];
    [liveUIView.floatWindowButton setBackgroundImage:[UIImage imageNamed:@"静音未开"] forState: UIControlStateNormal];
    [liveUIView.floatWindowButton setBackgroundImage:[UIImage imageNamed:@"静音开"] forState: UIControlStateSelected];
    
    KSYWeakSelf;
    liveUIView.buttonBlock = ^(UIButton *sender) {
        //按钮响应回传。开始在congtroller里面进行设置
        [weakSelf buttonClickAction:sender];
    };
    [self.controlView addSubview:liveUIView];
    [liveUIView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.safeAreaView);
        make.top.equalTo(self.topView.mas_bottom);
        make.width.equalTo(self.safeAreaView);
        make.bottom.equalTo(self.safeAreaView);
    }];
    self.liveUIView = liveUIView;
}
/**
 添加观察者,监听推流状态改变的通知
 */
- (void)addObserver {
    //监听推流状态
    NSNotificationCenter* notification = [NSNotificationCenter defaultCenter];
    
    [notification addObserver:self selector:@selector(streamStateChange:) name:KSYStreamStateDidChangeNotification object:nil];
    
}
/**
 移除观察者
 */
- (void)removeObserver {
    [[NSNotificationCenter defaultCenter]removeObserver: self];
}
#pragma mark -
#pragma mark - overivde 复用方法

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.collectView removeFromSuperview];
    //显示直播顶部UI视图
    self.topView.hidden = NO;
    //显示直播UI视图
    self.liveUIView.hidden = NO;
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //原始图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if(image != nil) {
        [self.wxStreamerKit updateBgpImage:image];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
//监听推流状态的改变
- (void)streamStateChange:(NSNotification*)notice {
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
 直播界面上的按钮的响应方法
 */
-(void)buttonClickAction:(UIButton*)button{
    
    KSYWeakSelf;
    //选择图片
    if (button.tag == 200) {
        [self selectPictureToView];
    }
    //悬浮窗
    else if (button.tag == 203){
        button.selected = !button.selected;
        weakSelf.muteState = !weakSelf.muteState;
        [weakSelf.wxStreamerKit.streamerBase muteStream:weakSelf.muteState];
    }
    //相机翻转
    else if (button.tag == 204){
        [self selectPictureToView];
    }
    //拉流地址
    else if (button.tag == 206){
        
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
    else{
    }
}

/**
 推流过程中切换图片
 */
- (void)selectPictureToView {
    UIImagePickerController* picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


