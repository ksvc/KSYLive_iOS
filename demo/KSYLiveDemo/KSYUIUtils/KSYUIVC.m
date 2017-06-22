//
//  KSYUIVC.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import "KSYUIVC.h"
#import <mach/mach.h>
#import <libksygpulive/KSYReachability.h>
#import "KSYUIView.h"

@interface KSYUIVC() {
    KSYReachability *_reach;
    KSYNetworkStatus   _preStatue;
}

@end

@implementation KSYUIVC

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObservers];
    _networkStatus = @" ";
}

- (void) addObservers {
    // statistics update every seconds
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(onTimer:)
                                             userInfo:nil
                                              repeats:YES];
    NSNotificationCenter * dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(netWorkChange)
               name:kKSYReachabilityChangedNotification
             object:nil];
    _reach = [KSYReachability reachabilityWithHostName:@"http://www.kingsoft.com"];
    [_reach startNotifier];
}

- (void)netWorkChange{
    KSYNetworkStatus currentStatus = [_reach currentReachabilityStatus];
    if (currentStatus == _preStatue) {
        return;
    }
    _preStatue = currentStatus;
    switch (currentStatus) {
        case KSYNotReachable:
            _networkStatus = @"无网络";
            break;
        case KSYReachableViaWWAN:
            _networkStatus = @"移动网络";
            break;
        case KSYReachableViaWiFi:
            _networkStatus = @"WIFI";
            break;
        default:
            return;
    }
    if( _onNetworkChange ){
        _onNetworkChange(_networkStatus);
    }
}
- (void) rmObservers {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [UIApplication sharedApplication].idleTimerDisabled=NO;
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return [super shouldAutorotate];
}
- (void) dealloc {
    NSLog(@"dealloc");
    if (_timer) {
        [self rmObservers];
    }
    _reach = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) layoutUI {
    if(_layoutView){
        _layoutView.frame = self.view.frame;
        [_layoutView layoutUI];
    }
}

- (void)onTimer:(NSTimer *)theTimer{
    
}

#pragma mark - ui rotate
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if(SYSTEM_VERSION_GE_TO(@"8.0")) {
            [self onViewRotate];
        }
    }completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if(SYSTEM_VERSION_GE_TO(@"8.0")) {
        return;
    }
    [self onViewRotate];
}
- (void) onViewRotate {
    // 子类 重写该方法来响应屏幕旋转
}

#pragma mark - string format
+ (NSString*) sizeFormatted : (int )KB {
    if ( KB > 1000 ) {
        double MB   =  KB / 1000.0;
        return [NSString stringWithFormat:@" %4.2f MB", MB];
    }
    else {
        return [NSString stringWithFormat:@" %d KB", KB];
    }
}

+ (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

+ (void) toast:(NSString*)message
          time:(double)duration
{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [toast show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

+ (float) cpu_usage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

+ (float)memory_usage {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if(kernReturn != KERN_SUCCESS) {
        return 0.0;
    }
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

+ (int)getCurrentBatteryLevel{
    //拿到当前设备
    UIDevice * device = [UIDevice currentDevice];
    //是否允许监测电池
    //要想获取电池电量信息和监控电池电量 必须允许
    device.batteryMonitoringEnabled = true;
    float level = device.batteryLevel;
    //换算为百分比
    int result = level * 100;
    return result;
}

#pragma mark - save Image
// 将UIImage 保存到path对应的文件
+ (void)saveImage: (UIImage *)image
               to: (NSString*)path {
    NSString * dir = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
    NSString * file = [dir stringByAppendingPathComponent:path];
    NSData *imageData = UIImagePNGRepresentation(image);
    BOOL ret = [imageData writeToFile:file atomically:YES];
    NSLog(@"write %@ %@", file, ret ? @"OK":@"failed");
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error == nil) {
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"O(∩_∩)O~~"
                                                        message:@"图像已保存至手机相册"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [toast show];
        
    }else{
        
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"￣へ￣"
                                                        message:@"图像保存手机相册失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [toast show];
    }
}

+ (void)saveImageToPhotosAlbum:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
@end
