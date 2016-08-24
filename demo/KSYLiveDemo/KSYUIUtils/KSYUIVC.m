//
//  KSYUIVC.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import "KSYUIVC.h"
#import <mach/mach.h>
#import "KSYReachability.h"

@interface KSYUIVC() {
    KSYReachability *_reach;
    NetworkStatus   _preStatue;
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
               name:kReachabilityChangedNotification
             object:nil];
    _reach = [KSYReachability reachabilityWithHostName:@"http://www.kingsoft.com"];
    [_reach startNotifier];
}
- (void)netWorkChange{
    NetworkStatus currentStatus = [_reach currentReachabilityStatus];
    if (currentStatus == _preStatue) {
        return;
    }
    _preStatue = currentStatus;
    switch (currentStatus) {
        case NotReachable:
            _networkStatus = @"无网络";
            break;
        case ReachableViaWWAN:
            _networkStatus = @"移动网络";
            break;
        case ReachableViaWiFi:
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
- (void)viewDidAppear:(BOOL)animated {
    [self layoutUI];
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
}

- (void)onTimer:(NSTimer *)theTimer{
    
}

#pragma mark - string format
- (NSString*) sizeFormatted : (int )KB {
    if ( KB > 1000 ) {
        double MB   =  KB / 1000.0;
        return [NSString stringWithFormat:@" %4.2f MB", MB];
    }
    else {
        return [NSString stringWithFormat:@" %d KB", KB];
    }
}

- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void) toast:(NSString*)message{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    double duration = 0.3; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

-(float) cpu_usage
{
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

@end
