//
//  libksystreamerengine.h
//  libksystreamerengine.h
//
//  Copyright (c) 2016 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GPUImage/GPUImage.h>

// sources (player & capture)
#import "KSYGPUPicInput.h"
#import "KSYGPUCamera.h"
#import "AVAudioSession+KSY.h"
#import "KSYAVAudioSession.h"
#import "KSYBgmPlayer.h"
#import "KSYBgmReader.h"
#import "KSYAQPlayer.h"
#import "KSYAUAudioCapture.h"
#import "KSYDummyAudioSource.h"
#import "KSYAVFCapture.h"
#import "KSYGPUViewCapture.h"
// mixer
#import "KSYGPUPicMixer.h"
#import "KSYAudioMixer.h"
#import "KSYAudioFilter.h"

// streamer
#import "KSYGPUPicOutput.h"
#import "KSYGPUView.h"

// utils
#import "KSYWeakProxy.h"

#define KSYSTREAMERENGINE_VER 2.9.5
#define KSYSTREAMERENGINE_ID  a5aeeaa7cbd82c1c4eb9ba47538e0404a8e80b6f

