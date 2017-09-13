//
//  KSYRecordVC.m
//
//  Created by zengfanping on 11/3/15.
//  Copyright (c) 2015 zengfanping. All rights reserved.
//

#import "KSYRecordVC.h"
#import <libksygpulive/KSYUIRecorderKit.h>
#import <libksygpulive/KSYWeakProxy.h>
#import <CommonCrypto/CommonDigest.h>
#import "KSYProgressView.h"
#import <GPUImage/GPUImage.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface KSYRecordVC () <UITextFieldDelegate>
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) KSYMoviePlayerController *player;
@property (strong, nonatomic) KSYUIRecorderKit* kit;

@end

@implementation KSYRecordVC{
    UILabel *stat;//状态
    UIView *videoView;
    UIButton *btnPlay;//播放
    UIButton *btnPause;//暂停
    UIButton *btnResume;//继续
    UIButton *btnStop;//停止
    UIButton *btnQuit;//返回
    //硬解码
    UILabel  *lableHWCodec;
    UISwitch  *switchHwCodec;
    //音量
    UILabel *labelVolume;
    UISlider *sliderVolume;
    //录屏方案
    UILabel *labelRecord;
    UISegmentedControl  *segRecord;
    
    UIButton *btnStartRecord;//开始录屏
    UIButton *btnStopRecord;//停止录屏
    
    NSString *recordFilePath;//保存路径
    
    dispatch_queue_t queue;
    CADisplayLink *_displayLink;
    
    NSInteger recordScheme;
}

- (instancetype)initWithURL:(NSURL *)url {
    if((self = [super init])) {
        self.url = url;
        recordScheme =  -1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
}

- (void) initUI {
    //初始化各个控件
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:videoView];

    btnPlay = [self addButtonWithTitle:@"播放" action:@selector(onPlayVideo:)];
    btnPause = [self addButtonWithTitle:@"暂停" action:@selector(onPauseVideo:)];
    btnResume = [self addButtonWithTitle:@"继续" action:@selector(onResumeVideo:)];
    btnStop = [self addButtonWithTitle:@"停止" action:@selector(onStopVideo:)];
    btnQuit = [self addButtonWithTitle:@"退出" action:@selector(onQuit:)];
    btnStartRecord = [self addButtonWithTitle:@"开始录屏" action:@selector(onStartRecordVideo:)];
    btnStopRecord =[self addButtonWithTitle:@"停止录屏" action:@selector(onStopRecordVideo:)];
    btnStartRecord.enabled = NO;
    btnStopRecord.enabled = NO;

	stat = [[UILabel alloc] init];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = -1;
    stat.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:stat];
    
    lableHWCodec = [[UILabel alloc] init];
    lableHWCodec.text = @"硬解码";
    lableHWCodec.textColor = [UIColor lightGrayColor];
    [self.view addSubview:lableHWCodec];
    
    labelVolume = [[UILabel alloc] init];
    labelVolume.text = @"音量";
    labelVolume.textColor = [UIColor lightGrayColor];
    [self.view addSubview:labelVolume];
    
    switchHwCodec = [[UISwitch alloc] init];
    [self.view  addSubview:switchHwCodec];
    switchHwCodec.on = YES;
    
    sliderVolume = [[UISlider alloc] init];
    sliderVolume.minimumValue = 0;
    sliderVolume.maximumValue = 100;
    sliderVolume.value = 100;
    [sliderVolume addTarget:self action:@selector(onVolumeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:sliderVolume];

    labelRecord = [[UILabel alloc] init];
    labelRecord.text = @"录屏方案";
    labelRecord.textColor = [UIColor lightGrayColor];
    [self.view addSubview:labelRecord];
    
    segRecord = [[UISegmentedControl alloc] initWithItems:@[@"关闭", @"图像混合", @"截屏"]];
    segRecord.selectedSegmentIndex = 0;
    segRecord.layer.cornerRadius = 5;
    segRecord.backgroundColor = [UIColor lightGrayColor];
    [segRecord addTarget:self action:@selector(onRecScheme:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segRecord];
    
    [self layoutUI];
    
    [self.view bringSubviewToFront:stat];
    stat.frame = [UIScreen mainScreen].bounds;

}
- (UIButton *)addButtonWithTitle:(NSString *)title action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds  = YES;
    button.layer.cornerRadius   = 5;
    button.layer.borderColor    = [UIColor blackColor].CGColor;
    button.layer.borderWidth    = 1;
    [self.view addSubview:button];
    return button;
}

- (void) layoutUI {
    //设置各个控件的fram
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    CGFloat gap =15;
    CGFloat btnWdt = ( (wdt-gap) / 5) - gap;
    CGFloat btnHgt = 30;
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    
    yPos = 2 * gap;
    xPos = gap;
    labelVolume.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += btnWdt * 1.4 + gap;
    sliderVolume.frame  = CGRectMake(xPos, yPos, wdt - 3 * gap - btnWdt * 1.4, btnHgt);
    yPos += btnHgt + gap;
    xPos = gap;
    lableHWCodec.frame =CGRectMake(xPos, yPos, btnWdt * 1.4, btnHgt);
    xPos += btnWdt * 1.4 + gap;
    switchHwCodec.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos = gap;
    yPos += btnHgt + gap;
    labelRecord.frame = CGRectMake(xPos, yPos, btnWdt * 1.4, btnHgt);
    xPos += btnWdt * 1.4 + gap;
    segRecord.frame = CGRectMake(xPos, yPos, btnWdt * 4, btnHgt);
    
    videoView.frame = CGRectMake(0, 0, wdt, hgt);
    
    xPos = gap;
    yPos = hgt - btnHgt - gap;
    btnPlay.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnPause.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnResume.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnStop.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += gap + btnWdt;
    btnQuit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    xPos = gap;
    yPos -= (btnHgt + gap);
    
    CGFloat newWidth = btnWdt*2;
    btnStartRecord.frame = CGRectMake(xPos, yPos, newWidth, btnHgt);
    xPos += gap + newWidth;
    btnStopRecord.frame = CGRectMake(xPos, yPos, newWidth, btnHgt);
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
}

-(void)onVolumeChanged:(UISlider *)slider
{
    if (_player){
        [_player setVolume:slider.value/100 rigthVolume:slider.value/100];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handlePlayerNotify:(NSNotification*)notify
{
    if (!_player) {
        return;
    }
    
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        int reason = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason ==  MPMovieFinishReasonPlaybackEnded) {
            stat.text = [NSString stringWithFormat:@"player finish"];
        }else if (reason == MPMovieFinishReasonPlaybackError){
            stat.text = [NSString stringWithFormat:@"player Error : %@", [[notify userInfo] valueForKey:@"error"]];
        }else if (reason == MPMovieFinishReasonUserExited){
            stat.text = [NSString stringWithFormat:@"player userExited"];
        }
    }
}

- (void) toast:(NSString*)message{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    
    double duration = 0.5; // duration in seconds
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

- (void)setupObservers
{
    //监听消息的改变
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlePlayerNotify:)
                                                name:(MPMoviePlayerPlaybackDidFinishNotification)
                                              object:_player];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(onStreamStateChange:)
                                                name:(KSYStreamStateDidChangeNotification)
                                              object:nil];
}

- (void)releaseObservers 
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:MPMoviePlayerPlaybackDidFinishNotification
                                                 object:_player];
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:KSYStreamStateDidChangeNotification
                                                 object:nil];
}

- (void)initPlayerWithURL:(NSURL *)aURL {
    if(recordScheme == KSYPlayerRecord_PicMix_Scheme)
    {
        //UI和视频一起录制
        self.player = [[KSYMoviePlayerController alloc] initWithContentURL:_url sharegroup:[[[GPUImageContext sharedImageProcessingContext] context] sharegroup]];
        @WeakObj(_kit);
        //player视频数据输入
        _player.textureBlock = ^(GLuint textureId, int width, int height, double pts){
            CGSize size = CGSizeMake(width, height);
            CMTime _pts = CMTimeMake((int64_t)(pts * 1000), 1000);
            if(_kitWeak)
                [_kitWeak processWithTextureId:textureId TextureSize:size Time:_pts];
        };
    }
    else
        self.player = [[KSYMoviePlayerController alloc] initWithContentURL:_url sharegroup:nil];
  
    @WeakObj(_kit);
    //player音频数据输入
    _player.audioDataBlock = ^(CMSampleBufferRef buf){
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(buf);
        if(pts.value < 0)
        {
            //无效音频帧丢掉
            NSLog(@"audio pts < 0");
            return;
        }
        if(_kitWeak)
            //接收音频帧
            [_kitWeak processAudioSampleBuffer:buf];
    };
    //获取解码方式
    _player.videoDecoderMode = switchHwCodec.isOn? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
    [_player.view setFrame: videoView.bounds];
    [videoView addSubview: _player.view];
    [videoView bringSubviewToFront:stat];
    
    [self setupObservers];
    //准备视频播放
    [_player prepareToPlay];
}

- (IBAction)onPlayVideo:(id)sender {
    if(recordScheme != KSYPlayerRecord_ScreenShot_Scheme && recordScheme != KSYPlayerRecord_PicMix_Scheme)
    {
        //没有设置录屏模式
        NSString *message = @"请先选择录制类型!";
        [self toast:message];
        return ;
    }
    
    if(nil == _player)
    {
        [self initPlayerWithURL:_url];
        btnStartRecord.enabled = YES;
        btnStopRecord.enabled = NO;
    } else {
        [_player setUrl:[NSURL URLWithString:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"]];
        [_player prepareToPlay];
    }
}
- (IBAction)onPauseVideo:(id)sender {
    if (_player) {
        //暂停
        [_player pause];
    }
}

- (IBAction)onResumeVideo:(id)sender {
    if (_player) {
        [_player play];
    }
}

- (IBAction)onStopVideo:(id)sender {
    if (_player) {
        //从Runloop中删除之前绑定的target
        [self stopTimer];
        //停止写入文件
        [_kit stopRecord];
        btnStartRecord.enabled = YES;
        btnStopRecord.enabled = NO;
        //停止视频播放
        [_player stop];
        [self releaseObservers];
        [_player.view removeFromSuperview];
        self.player = nil;
    }
}

- (IBAction)onQuit:(id)sender {
    [self onStopVideo:nil];
    [self dismissViewControllerAnimated:FALSE completion:nil];
    stat.text = nil;
}


#pragma record kit setup
-(void)addUIToKit{
    [_kit.contentView addSubview:labelVolume];
    [_kit.contentView addSubview:sliderVolume];
    [_kit.contentView addSubview:lableHWCodec];
    [_kit.contentView addSubview:switchHwCodec];
    [_kit.contentView addSubview:labelRecord];
    [_kit.contentView addSubview:segRecord];
    [_kit.contentView addSubview:btnPlay];
    [_kit.contentView addSubview:btnPause];
    [_kit.contentView addSubview:btnResume];
    [_kit.contentView addSubview:btnStop];
    [_kit.contentView addSubview:btnQuit];
    [_kit.contentView addSubview:btnStartRecord];
    [_kit.contentView addSubview:btnStopRecord];
    [_kit.contentView addSubview:stat];
    
    [self.view addSubview:_kit.contentView];
    [_kit.contentView sendSubviewToBack:videoView];
}

- (IBAction)onRecScheme:(id)sender {
    if(1 == segRecord.selectedSegmentIndex)
    {
        //录屏模式为UI和视频混合
        recordScheme = KSYPlayerRecord_PicMix_Scheme;
        _kit = [[KSYUIRecorderKit alloc]init];
        [self addUIToKit];
    }
    else if(2 == segRecord.selectedSegmentIndex)
    {
        //录屏模式为截屏
        recordScheme = KSYPlayerRecord_ScreenShot_Scheme;
        _kit = [[KSYUIRecorderKit alloc]initWithScheme:KSYPlayerRecord_ScreenShot_Scheme];
        queue = dispatch_queue_create("com.ksyun.playerRecord", DISPATCH_QUEUE_SERIAL);
    }
    //文件保存路径
    recordFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/RecordAv.mp4"];
    segRecord.enabled = NO;
}

#pragma wite file
-(IBAction)onStartRecordVideo:(id)sender{
    //开始写入前删除掉旧的文件
    [self deleteFile:recordFilePath];
    NSURL * path =[[NSURL alloc] initWithString:recordFilePath];
    if(_kit)
    {
        if(recordScheme == KSYPlayerRecord_ScreenShot_Scheme)
            [self setupTimer];
        //开始写入文件
        [_kit startRecord:path];
    }
    
    btnStartRecord.enabled = NO;
    btnStopRecord.enabled = YES;
}

-(IBAction)onStopRecordVideo:(id)sender{
    if(_kit)
    {
        //停止写入文件
        [_kit stopRecord];
        //从Runloop中删除之前绑定的target
        [self stopTimer];
    }
    btnStartRecord.enabled = YES;
    btnStopRecord.enabled = NO;
}

- (void) onStreamError:(KSYStreamErrorCode) errCode{
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK) {
        // 网络连接中断，进行重连
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_AV_SYNC_ERROR) {
        //音视频同步失败
        NSLog(@"audio video is not synced, please check timestamp");
        [self tryReconnect];
    }
    else if (errCode == KSYStreamErrorCode_CODEC_OPEN_FAILED) {
        //无法打开CODEC
        NSLog(@"video codec open failed, try software codec");
        _kit.writer.videoCodec = KSYVideoCodec_X264;
        [self tryReconnect];
    }
}
- (void) tryReconnect {
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        NSLog(@"try again");
        NSURL * path =[[NSURL alloc] initWithString:recordFilePath];
        [_kit startRecord:path];
    });
}

- (void) onStreamStateChange :(NSNotification *)notification{
    if (_kit.writer){
        //显示推流状态
        NSLog(@"stream State %@", [_kit.writer getCurStreamStateName]);
    }
    //状态为KSYStreamStateIdle且_bRecord为ture时，录制视频到相薄
    if (_kit.writer.streamState == KSYStreamStateIdle && _kit.bPlayRecord == NO){
        [self saveVideoToAlbum: recordFilePath];
    }
    
    if (_kit.writer.streamState == KSYStreamStateError){
        //推流出错
        [self onStreamError:_kit.writer.streamErrorCode];
    }
}

//保存视频到相簿
- (void) saveVideoToAlbum: (NSString*) path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                //能够保存到相册
                SEL onDone = @selector(video:didFinishSavingWithError:contextInfo:);
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, onDone, nil);
            }
    });
}
//保存mp4文件完成时的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSString *message;
    if (!error) {
        message = @"Save album success!";
    }
    else {
        message = @"Failed to save the album!";
    }
    [self toast:message];
}

//删除文件,保证保存到相册里面的视频时间是最新的
-(void)deleteFile:(NSString *)file{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:file]) {
        [fileManager removeItemAtPath:file error:nil];
    }
}

#pragma screeshot
//UIImage->CVPixelBufferRef
- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    CVPixelBufferRef pixelBuffer = NULL;
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    CVReturn status = kCVReturnError;
    
    if(!image)
        return nil;
    
    NSMutableDictionary *options = [[NSMutableDictionary alloc]init];
    //设置要输出的CVPixelBufferRef的参数
    [options setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCVPixelBufferCGImageCompatibilityKey];
    [options setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey];
    if(SYSTEM_VERSION_LESS_THAN(@"9.0"))
        [options setObject:@{} forKey:(NSString *)kCVPixelBufferIOSurfacePropertiesKey];
    
    imageWidth = CGImageGetWidth(image);
    imageHeight = CGImageGetHeight(image);
    //按指定参数创建一个单一的PixelBuffer
    status = CVPixelBufferCreate(kCFAllocatorDefault,
                                 imageWidth,
                                 imageHeight,
                                 kCVPixelFormatType_32BGRA,
                                 (__bridge CFDictionaryRef) options,
                                 &pixelBuffer);
    
    if(status != kCVReturnSuccess || !pixelBuffer)
        return nil;
    //锁定pixelBuffer的基地址
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    // 得到pixelBuffer的基地址
    void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
    //创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    //用抽样缓存的数据创建一个位图格式的图形上下文对象
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 imageWidth,
                                                 imageHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pixelBuffer),
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little);
    
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image);
    //释放上下文和颜色空间
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    //解锁基地址
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}

//截图指定UI
- (void)captureScreen:(CADisplayLink *)displayLink
{
    dispatch_sync(queue, ^
                  {
                      CVPixelBufferRef buffer = NULL;
                      UIImage *screenshot = NULL;
                      UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
                      [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
                      screenshot = UIGraphicsGetImageFromCurrentImageContext();
                      UIGraphicsEndImageContext();
                      if(screenshot)
                      {
                          buffer = [self pixelBufferFromCGImage:screenshot.CGImage];
                          [_kit processVideoSampleBuffer:buffer timeInfo:kCMTimeInvalid];
                          CVPixelBufferRelease(buffer);
                      }
                  });
}

- (void)setupTimer
{
    if(!_displayLink)
    {
        //调用截图方法
        KSYWeakProxy *proxy = [KSYWeakProxy proxyWithTarget:self];
        _displayLink = [CADisplayLink displayLinkWithTarget:proxy selector:@selector(captureScreen:)];
        if(SYSTEM_VERSION_LESS_THAN(@"1.0")) {//如果系统版本小于10.0
            //设置间隔多少帧调用一次selector 方法
            _displayLink.frameInterval = 4;
        }
        else {
            //设定回调速率
            _displayLink.preferredFramesPerSecond = 15;
        }
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer
{
    [_displayLink invalidate];
    _displayLink = nil;
}
@end
