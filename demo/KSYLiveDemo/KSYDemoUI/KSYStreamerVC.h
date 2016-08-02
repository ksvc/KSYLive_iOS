//
//  KSYStreamerVC.h
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 qyvideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIView.h"
#import "KSYUIVC.h"
#import "KSYPresetCfgView.h"
#import "KSYCtrlView.h"
#import "KSYStreamerVC.h"
#import "KSYMenuView.h"
#import "KSYFilterView.h"
#import "KSYBgmView.h"
#import "KSYPipView.h"
#import "KSYAudioMixerView.h"
#import "KSYReverbView.h"
#import "KSYMiscView.h"
#if USING_DYNAMIC_FRAMEWORK
#import <libksygpulivedylib/libksygpulivedylib.h>
#import <libksygpulivedylib/libksygpuimage.h>
#else
#import <libksygpulive/libksygpulive.h>
#import <libksygpulive/libksygpuimage.h>
#endif

typedef struct _StreamState {
    double    timeSecond;   // 更新时间
    int       uploadKByte;  // 上传的字节数(KB)
    int       encodedFrames;// 编码的视频帧数
    int       droppedVFrames; // 丢弃的视频帧数
} StreamState;


@interface KSYStreamerVC : KSYUIVC

// 切到当前VC后， 界面自动开启推流
@property BOOL  bAutoStart;

- (id) initWithCfg:(KSYPresetCfgView*)presetCfgView;

// sub views
@property (nonatomic, readonly) KSYCtrlView   * ctrlView;
@property (nonatomic, readonly) KSYMenuView   * ksyMenuView;
@property (nonatomic, readonly) KSYFilterView * ksyFilterView;
@property (nonatomic, readonly) KSYBgmView    * ksyBgmView;
@property (nonatomic, readonly) KSYPipView    * ksyPipView;
@property (nonatomic, readonly) KSYAudioMixerView * audioMixerView;
@property (nonatomic, readonly) KSYReverbView *reverbView;
@property (nonatomic, readonly) KSYMiscView   *miscView;

// submodules
@property (nonatomic, retain) KSYStreamerBase*   streamerBase;
@property (nonatomic, retain) KSYGPUCamera*      capDev;
@property (nonatomic, retain) GPUImageFilter*    filter;
@property (nonatomic, retain) KSYBgmPlayer*      bgmPlayer;
@property (nonatomic, retain) KSYAudioReverb*    reverb;
@property (nonatomic, retain) KSYMicMonitor*     micMonitor;

// 画中画
@property (nonatomic, retain) KSYGPUYUVInput           *yuvInput;
@property (nonatomic, retain) KSYGPUPipBlendFilter     *pipFilter;
@property(nonatomic, retain)  GPUImagePicture          *bgPic;



@property (nonatomic, retain) KSYAudioMixer*     aMixer;
@property (nonatomic, assign) int     micTrack;
@property (nonatomic, assign) int     bgmTrack;
@property (nonatomic, assign) int     pipTrack;

// presetCfgs
@property (nonatomic, retain) KSYPresetCfgView * presetCfgView;

// 推流地址 完整的URL
@property NSURL * hostURL;

// 采集的参数设置
- (void) setCaptureCfg;
// 推流的参数设置
- (void) setStreamerCfg;

// 一秒前的数据
@property StreamState *lastState;

- (void) addObservers;
- (void) rmObservers;

#pragma mark - state change monitor
- (void) onCaptureStateChange:(NSNotification *)notification;
- (void) onNetStateEvent     :(NSNotification *)notification;
- (void) onStreamStateChange :(NSNotification *)notification;
- (void) onBgmPlayerStateChange:(NSNotification*)notify;

#pragma mark - UI respond
- (void) onFlash;
- (void) onCameraToggle;
- (void) onQuit;
- (void) onCapture;
- (void) onStream;
// gpu filter
- (void) onFilterChange:(id)sender;
// audio mixer
- (void)onAMixerSwitch:(UISwitch *)sw;
- (void)onAMixerSlider:(KSYNameSlider *)slider;
// 选择混响类型
- (void)onReverbType:(UISegmentedControl *)seg;
//pip
- (void)onPipStop;
//pure audio stream
- (void)onMiscSwitch:(UISwitch *)sw;
@end
