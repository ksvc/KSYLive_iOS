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
    UIButton *selectFileBtn;
    UIButton *captureBtn;
    UIButton *streamBtn;
    UIButton *quitBtn;
    KSYUIView *ctrlView;
    BOOL _capFlag;
}

@property NSURL             *url;
@property UILabel           *streamState;

@end

@implementation KSYBgpStreamerVC
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
    _kit = [[KSYGPUBgpStreamerKit alloc] init];
    _kit.streamDimension = CGSizeMake(720, 1280);
    _kit.streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _kit.streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
    _kit.streamerBase.bwEstimateMode = KSYBWEstMode_Default;
    _kit.streamerBase.videoMinFPS = 10;
    _kit.streamerBase.videoMaxFPS = 25;
    _kit.videoFPS = 20;
    _kit.streamerBase.videoMaxBitrate = 1024;
    _kit.streamerBase.videoInitBitrate = _kit.streamerBase.videoMaxBitrate*6/10;
    _kit.streamerBase.videoMinBitrate  = 0;
    _kit.streamerBase.audiokBPS = 64;
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
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate methods
-(void)imagePickerController:(UIImagePickerController *)picker
       didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo {
    _streamState.hidden = NO;
    captureBtn.hidden = NO;
    streamBtn.hidden = NO;
    if (_kit.bgPic){
        [_kit.bgPic removeAllTargets];
        _kit.bgPic = nil;
    }
    _kit.gpuOutputPixelFormat = kCVPixelFormatType_32BGRA;
    //校正图片朝向
    _kit.previewDimension = image.size;
    _kit.bgPicRotate = [[_kit class] getRotationMode:image];
    _kit.bgPic  = [[GPUImagePicture alloc] initWithImage:image];
    image = nil;
    //推流过程中切换图片
    if (_capFlag == 0) {
        _capFlag = 1;
        [_kit startPreview:self.view];
    }
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
