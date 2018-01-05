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

#define KSYSTREAMERENGINE_VER 3.0.0
#define KSYSTREAMERENGINE_ID  caf16988bcf804f5c830da1576e64074d4d5fd45

