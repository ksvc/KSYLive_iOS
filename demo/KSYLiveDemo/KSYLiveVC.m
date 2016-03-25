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


@interface KSYLiveVC ()

@property KSYPlayerVC    * playerVC;
@property KSYStreamerKitVC  * streamerKitVC;

@end

@implementation KSYLiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    
    CGFloat btnWdt = wdt * 0.6;
    CGFloat btnHgt = 40;
    CGFloat xPos = (wdt - btnWdt) / 2;
    CGFloat yPos = (hgt - btnHgt*3) / 2;
    
    CGRect frame2 = CGRectMake( xPos, yPos, btnWdt, btnHgt);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame2;
    [button setTitle:@"播放demo" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];

    [button addTarget:self action:@selector(onPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    yPos += btnHgt*2;
    frame2 = CGRectMake( xPos, yPos, btnWdt, btnHgt);
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame2;
    [button setTitle:@"推流demo" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(onStreamer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    yPos += btnHgt*2;
    frame2 = CGRectMake( xPos, yPos, btnWdt, btnHgt);
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame2;
    [button setTitle:@"KSYGPUStreamer" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:@selector(onGPUStreamer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _playerVC   = [[KSYPlayerVC alloc] init];
    _streamerKitVC = [[KSYStreamerKitVC alloc] init];

}

- (IBAction)onPlayer:(id)sender {
    [self presentViewController:_playerVC animated:true completion:nil];
}


- (IBAction)onStreamer:(id)sender {
    [self presentViewController:_streamerKitVC animated:true completion:nil];
}

- (IBAction)onGPUStreamer:(id)sender {
    KSYGPUStreamerVC    * vc = [[KSYGPUStreamerVC alloc] init];
    [self presentViewController:vc animated:true completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
