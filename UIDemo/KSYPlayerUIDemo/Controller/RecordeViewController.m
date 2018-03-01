//
//  RecordeViewController.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/1.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "RecordeViewController.h"
#import "KSYAVWriter.h"
#import "AppDelegate.h"
#import "UIView+Toast.h"
#import "UIColor+Additions.h"

@interface RecordeViewController ()
@property (nonatomic, strong)    KSYAVWriter              *avWriter;
@property (nonatomic, weak)      KSYMoviePlayerController *player;
@property (nonatomic, assign)    BOOL                      isRecording;
@property (weak, nonatomic) IBOutlet UIButton *saveVideoButton;
@property (nonatomic, strong)    CALayer                  *recordeProgressLayer;
@property (nonatomic, strong)    NSTimer                  *recordeTimer;
@property (weak, nonatomic) IBOutlet UILabel *minRecordeTimeLab;
@property (weak, nonatomic) IBOutlet UILabel *recordeMarkLab;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (nonatomic, copy) void(^screenRecordeFinishedBlock)(void);
@end

@implementation RecordeViewController

#define kVarWidth (self.view.frame.size.width / (15.0 * 1000))

- (instancetype)initWithPlayer:(KSYMoviePlayerController *)player
    screenRecordeFinishedBlock:(void(^)(void))screenRecordeFinishedBlock {
    if (self = [super init]) {
        _player = player;
        _screenRecordeFinishedBlock = screenRecordeFinishedBlock;
        [self configePlayerDataBlock];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.recordeMarkLab.layer.cornerRadius = 5.0;
    self.recordeMarkLab.layer.masksToBounds = YES;
    [self setupRecordeLayer];
}

- (void)setupRecordeLayer {
    self.recordeProgressLayer = [CALayer layer];
    _recordeProgressLayer.backgroundColor = [UIColor colorWithHexString:@"FC3252"].CGColor;
    _recordeProgressLayer.frame = CGRectMake(0, 0, 0, 6);
    [self.view.layer addSublayer:_recordeProgressLayer];
}

- (NSTimer *)recordeTimer {
    if (!_recordeTimer) {
        __weak typeof(self) weakSelf = self;
        _recordeTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 repeats:YES block:^(NSTimer * _Nonnull timer) {
            typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.recordeProgressLayer.frame.size.width < self.view.frame.size.width) {
                CGRect frame = strongSelf.recordeProgressLayer.frame;
                frame.size.width += kVarWidth;
                strongSelf.recordeProgressLayer.frame = frame;
            } else {
                [strongSelf stopRecordeAction:nil];
            }
        }];
    }
    return _recordeTimer;
}

- (void)configePlayerDataBlock {
    __weak typeof(self) weakSelf = self;
    
    _player.videoDataBlock = ^(CMSampleBufferRef sampleBuffer){
        //写入视频sampleBuffer
        if(weakSelf && weakSelf.avWriter && weakSelf.isRecording)
            [weakSelf.avWriter processVideoSampleBuffer:sampleBuffer];
    };
    
    _player.audioDataBlock = ^(CMSampleBufferRef sampleBuffer){
        //写入音频sampleBuffer
        if(weakSelf && weakSelf.avWriter && weakSelf.isRecording)
            [weakSelf.avWriter processAudioSampleBuffer:sampleBuffer];
    };
}

- (void)startRecorde {
    if (!_isRecording &&_player.isPreparedToPlay) {
        [self rotateEnable:NO];
        [self recordeStateHandler:YES];
        self.stopButton.hidden = NO;
        self.isRecording = YES;
        //初始化KSYAVWriter类
        self.avWriter = [[KSYAVWriter alloc] initWithDefaultCfg];
        //设置待写入的文件名
        [self.avWriter setUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%s", NSHomeDirectory(), "/Documents/PlayerRec.mp4"]]];
        //开始写入
        [self.avWriter setMeta:[_player getMetadata:MPMovieMetaType_Audio] type:KSYAVWriter_MetaType_Audio];
        [self.avWriter setMeta:[_player getMetadata:MPMovieMetaType_Video] type:KSYAVWriter_MetaType_Video];
        [self.avWriter startRecordDeleteRecordedVideo:NO];
        [self.recordeTimer fire];
        [self recordeStateHandler:YES];
    }
}

- (IBAction)cancelRecordeAction:(id)sender {
    if (self.isRecording) {
        return;
    }
    [self rotateEnable:YES];
    [self.recordeTimer invalidate];
    self.recordeTimer = nil;
    [self.avWriter cancelRecorde];
    self.recordeProgressLayer.frame = CGRectMake(0, 0, 0, 6);
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if (self.screenRecordeFinishedBlock) {
        self.screenRecordeFinishedBlock();
    }
}

- (IBAction)saveRecordeAction:(id)sender {
    self.saveVideoButton.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    [_avWriter saveVideoToPhotosAlbumWithResultBlock:^(NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            
        } else {
            [self.view makeToast:@"小视频已保存至相册" duration:1 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf cancelRecordeAction:nil];
            });
        }
        strongSelf.saveVideoButton.userInteractionEnabled = YES;
    }];
}

- (IBAction)stopRecordeAction:(id)sender {
    if (_isRecording) {
        if (self.recordeProgressLayer.frame.size.width < self.view.frame.size.width / 3.0) {
            [self.view makeToast:@"至少录制3秒" duration:1 position:CSToastPositionCenter];
            return;
        }
        [_avWriter stopRecord];
        self.isRecording = NO;
        [self.recordeTimer invalidate];
        self.recordeTimer = nil;
        [self recordeStateHandler:NO];
        self.stopButton.hidden = YES;
    } else {
//        [self startRecorde];
    }
}

- (void)recordeStateHandler:(BOOL)recording {
    self.recordeMarkLab.hidden = !recording;
    self.minRecordeTimeLab.hidden = !recording;
    self.saveVideoButton.hidden = recording;
}

- (void)rotateEnable:(BOOL)enable {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.allowRotation = enable;
    delegate.settingModel.recording = !enable;
}

@end
