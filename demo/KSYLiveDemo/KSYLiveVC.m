//
//  FirstViewController.m
//  QYLive
//
//  Created by yiqian on 11/3/15.
//  Copyright (c) 2015 kingsoft. All rights reserved.
//

#import "KSYLiveVC.h"
#import "KSYStreamerVC.h"
#import "KSYPlayerVC.h"

@interface KSYLiveVC ()

@property KSYPlayerVC    * playerVC;
@property KSYStreamerVC  * streamerVC;

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
    button.tag = 2001;
    [button addTarget:self action:@selector(onPlayer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    yPos += btnHgt*2;
    frame2 = CGRectMake( xPos, yPos, btnWdt, btnHgt);
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = frame2;
    [button setTitle:@"推流demo" forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    button.tag = 2002;
    [button addTarget:self action:@selector(onStreamer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _playerVC   = [[KSYPlayerVC alloc] init];
    _streamerVC = [[KSYStreamerVC alloc] init];

}

- (IBAction)onPlayer:(id)sender {
    [self presentViewController:_playerVC animated:true completion:nil];
}


- (IBAction)onStreamer:(id)sender {
    [self presentViewController:_streamerVC animated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
