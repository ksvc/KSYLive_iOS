//
//  FirstViewController.m
//  QYLive
//
//  Created by yiqian on 11/3/15.
//  Copyright (c) 2015 kingsoft. All rights reserved.
//

#import "KSYLiveVC.h"
#import "KSYStreamerVC.h"
#import "KSYStreamerKitVC.h"
#import "KSYPlayerVC.h"
#import "KSYGPUStreamerVC.h"


@interface KSYLiveVC () {
    UIButton * _btn[3];
}

@property KSYPlayerVC    * playerVC;
@property KSYStreamerKitVC  * streamerKitVC;
@property KSYGPUStreamerVC  * streamerVC;
@end

@implementation KSYLiveVC

- (UIButton *)addButton:(NSString*)title
                 action:(SEL)action {
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void) initUI {
    _btn[0] = [self addButton:@"playerDemo" action:@selector(onPlayer:)];
    _btn[1] = [self addButton:@"KSYGPUStreamerKit" action:@selector(onStreamer:)];
    _btn[2] = [self addButton:@"KSYGPUStreamer" action:@selector(onGPUStreamer:)];
    [self layoutUI];
}

- (void) layoutUI {
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    CGFloat gap = 40;
    CGFloat btnWdt = wdt - gap*2;
    CGFloat btnHgt = (hgt-gap)/4;
    CGFloat yPos    = gap;
    CGFloat xLeft   = gap;
    
    // bottom left
    _btn[0].frame = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    yPos += (btnHgt+gap);
    _btn[1].frame = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    yPos += (btnHgt+gap);
    _btn[2].frame = CGRectMake(xLeft,   yPos, btnWdt, btnHgt);
    yPos += (btnHgt+gap);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    
}
- (void) viewDidAppear:(BOOL)animated{
    if (_streamerKitVC){
        [_streamerKitVC rmObservers];
    }
    if (_streamerVC){
        [_streamerVC rmObservers];
    }
    
    _playerVC   = [[KSYPlayerVC alloc] init];
    _streamerKitVC = [[KSYStreamerKitVC alloc] init];
    _streamerVC = [[KSYGPUStreamerVC alloc] init];
}

- (IBAction)onPlayer:(id)sender {
    [self presentViewController:_playerVC animated:true completion:nil];
}

- (IBAction)onStreamer:(id)sender {
    [self presentViewController:_streamerKitVC animated:true completion:nil];
}

- (IBAction)onGPUStreamer:(id)sender {
    [self presentViewController:_streamerVC animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
