//
//  KSYBgpStreamerVC.m
//  KSYLiveDemo
//
//  Created by 江东 on 17/4/21.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYBgpStreamerVC.h"
#import "KSYUIView.h"
@interface KSYBgpStreamerVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIButton *selectFileBtn;//选择背景图片
    UIButton *captureBtn;//预览按钮
    UIButton *streamBtn;//推流按钮
    UIButton *quitBtn;//返回按钮
    KSYUIView *ctrlView;
    BOOL _capFlag;
}

@property NSURL             *url;
@property UILabel           *streamState;//推流状态

@end

@implementation KSYBgpStreamerVC
- (id)initWithUrl:(NSURL *)rtmpUrl{
    if (self = [super init]) {
        _url = rtmpUrl;
        [self addObserver];
    }
    return self;
}
- (void)addObserver{
    //监听推流状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamStateChanged) name:KSYStreamStateDidChangeNotification object:nil];
}
- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)streamStateChanged{
    //显示当前推流状态
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
    _kit = [[KSYGPUBgpStreamerKit alloc] init];
    //推流分辨率
    _kit.streamDimension = CGSizeMake(720, 1280);
    //视频编码器
    _kit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
    //音频编码器
    _kit.streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
    //带宽估计模式（网络自适应）
    _kit.streamerBase.bwEstimateMode = KSYBWEstMode_Default;
    //视频帧率最小值
    _kit.streamerBase.videoMinFPS = 10;
    //视频帧率最大值
    _kit.streamerBase.videoMaxFPS = 25;
    //视频的帧率
    _kit.videoFPS = 20;
    //视频编码最高码率
    _kit.streamerBase.videoMaxBitrate = 1024;
    //视频编码起始码率
    _kit.streamerBase.videoInitBitrate = _kit.streamerBase.videoMaxBitrate*6/10;
    //视频编码最低码率
    _kit.streamerBase.videoMinBitrate  = 0;
    //音频编码码率
    _kit.streamerBase.audiokBPS = 64;
    //最大重连次数
    _kit.maxAutoRetry = 3;
    _capFlag = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)setupUI{
    ctrlView = [[KSYUIView alloc] initWithFrame:self.view.bounds];
    @WeakObj(self);
    ctrlView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
    
    // top view
    selectFileBtn = [ctrlView addButton:@"选择背景图片"];
    quitBtn = [ctrlView addButton:@"退出"];
    _streamState = [ctrlView addLable:@"空闲状态"];
    _streamState.textColor = [UIColor redColor];
    _streamState.textAlignment = NSTextAlignmentCenter;
    
    // bottom view
    captureBtn = [ctrlView addButton:@"开始预览"];
    streamBtn = [ctrlView addButton:@"开始推流"];
    
    _streamState.hidden = YES;
    captureBtn.hidden = YES;
    streamBtn.hidden = YES;

    [self.view addSubview:ctrlView];
    
    [self layoutUI];
}

- (void)layoutUI{
    ctrlView.frame = self.view.frame;
    [ctrlView layoutUI];
    [ctrlView putRow:@[selectFileBtn, [UIView new], quitBtn]];
    
    ctrlView.yPos = self.view.frame.size.height - 30;
    [ctrlView putRow:@[captureBtn, _streamState, streamBtn]];
}

- (void)onBtn:(UIButton *)btn{
    if (btn == selectFileBtn){
        [self onSelectFile];
    }else if (btn == captureBtn) {
        [self onCapture];
    }else if (btn == streamBtn){
        [self onStream];
    }else if (btn == quitBtn){
        [self onQuit];
    }
}

- (void)onSelectFile{
    //从相册获取照片
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate methods
-(void)imagePickerController:(UIImagePickerController *)picker
       didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo {
    if(image == nil) {
        [picker dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    _streamState.hidden = NO;
    captureBtn.hidden = NO;
    streamBtn.hidden = NO;
    if (_kit.bgPic){
        [_kit.bgPic removeAllTargets];
        _kit.bgPic = nil;
    }
    //设置输出图像的像素格式
    _kit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    _kit.bgPicRotate = [[_kit class] getRotationMode:image];
    //校正图片朝向
    _kit.bgPic  = [[GPUImagePicture alloc] initWithImage:image];
    if (image.imageOrientation == UIImageOrientationLeft || image.imageOrientation == UIImageOrientationRight){
        _kit.previewDimension = CGSizeMake(_kit.bgPic.outputImageSize.height, _kit.bgPic.outputImageSize.width);
    }else{
        _kit.previewDimension = _kit.bgPic.outputImageSize;
    }
    //推流过程中切换图片
    if (_capFlag == 0) {
        _capFlag = 1;
        //开始预览（启动推流前必须开始预览）
        [_kit startPreview:self.view];
    }
    //开启视频配置和采集
    [_kit startVideoCap];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)onCapture{
    if (!_capFlag){
        _capFlag = 1;
        [_kit startPreview:self.view];
    }
    else {
        _capFlag = 0;
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
    [self removeObserver];
    [_kit stopPreview];
    _kit = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
