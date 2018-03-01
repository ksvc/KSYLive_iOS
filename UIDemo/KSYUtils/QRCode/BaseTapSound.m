//
//  BaseTapSound.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/13.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "BaseTapSound.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface BaseTapSound(){
    SystemSoundID soundID;
    SystemSoundID systemSoundID;
}

@end

@implementation BaseTapSound

- (void)dealloc{
    AudioServicesDisposeSystemSoundID(soundID);
}

static BaseTapSound *baseSound;
+(instancetype)shareTapSound{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        if (baseSound == nil) {
            baseSound=[[self alloc]init];
            baseSound.vibrate = YES;
        }
    });
    return baseSound;
}

- (void)playSoundFileName:(NSString *)soundName{
    NSURL *url=[[NSBundle mainBundle]URLForResource:soundName withExtension:nil];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    
}

- (void)playSound{
    if (self.vibrate) {
        AudioServicesPlayAlertSound(soundID);
    }else{
        AudioServicesPlaySystemSound(soundID);
    }
    
}

- (void)playSystemSound{
    //系统声音
    AudioServicesPlaySystemSound(1007);
    if (self.vibrate) {
        //震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

+ (BOOL)ifCanUseSystemCamera{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        return NO;
    }
    return YES;
}
/**
 * 是否有权限使用系统相册
 */
+ (BOOL)ifCanUseSystemPhoto {
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}


@end
