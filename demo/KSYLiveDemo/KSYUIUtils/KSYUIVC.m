//
//  KSYUIVC.m
//  KSYStreamerVC
//
//  Created by yiqian on 10/15/15.
//  Copyright (c) 2015 ksyun. All rights reserved.
//

#import "KSYUIVC.h"

@interface KSYUIVC() {
    
}

@end

@implementation KSYUIVC

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObservers];
}

- (void) addObservers {
    // statistics update every seconds
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(onTimer:)
                                             userInfo:nil
                                              repeats:YES];
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


@end
