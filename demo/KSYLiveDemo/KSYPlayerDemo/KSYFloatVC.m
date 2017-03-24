//
//  KSYFloatVC.m
//  KSYPlayerDemo
//
//  Created by 施雪梅 on 2017/3/10.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSYFloatVC.h"

static NSString *backgroudText1 = {@"    金山视频云依托业界领先的编解码技术与强大的分发服务，立足于金山云顶级的IaaS基础设施，提供一站式云直、点播服务。"};
static NSString *backgroudText2 = {@"    金山视频云提供内容生产及观看的工具，即推流播放SDK，凭借其完善的功能、卓越的兼容性及性能，满足客户不断涌现的业务需求，再通过金山魔方系统与第三方平台共同实现视频生态链的繁荣。"};
static NSString *backgroudText3 = {@"    金山视频云提供内容生产及观看的工具，即推流播放SDK，凭借其完善的功能、卓越的兼容性及性能，满足客户不断涌现的业务需求，再通过金山魔方系统与第三方平台共同实现视频生态链的繁荣。"};
static NSString *backgroudText4 = {@"    金山云推流SDK支持H.264/H.265编码、软硬编，支持多种美颜滤镜特效、连麦，音频模块也在不断强化：美声、升降调、变声、混音等，弱网优化模块也颇有建树：码率自适应、网络主动探测、动态帧率等。"};

@implementation KSYFloatVC {
    UILabel *bgText;
    UIView *videoView;
    UIButton *btnQuit;
    UIButton *btnStop;
    BOOL isMoving;
}

- (void) initUI {
    CGFloat boundWidth = self.view.bounds.size.width;
    CGFloat boundHeight = self.view.bounds.size.height;
    
    CGFloat btnWidth = 60;
    CGFloat btnHeight = 30;
    CGFloat elemGap =15;
    
    CGFloat xPos = elemGap;
    CGFloat yPos = boundHeight - elemGap - btnHeight;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //add UIView for player
    videoView = [[UIView alloc] init];
    videoView.backgroundColor = [UIColor clearColor];
    videoView.frame = CGRectMake(boundWidth / 2,  boundHeight / 4, boundWidth / 3 , boundHeight / 3);
    [self.view addSubview:videoView];
    
    bgText = [[UILabel alloc] init];
    bgText.backgroundColor = [UIColor clearColor];
    bgText.textColor = [UIColor lightGrayColor];
    bgText.font = [UIFont fontWithName:@"楷体"  size:(22.0)];
    bgText.numberOfLines = -1;
    bgText.textAlignment = NSTextAlignmentLeft;
    bgText.frame =  CGRectMake(boundWidth / 20, boundHeight / 20, boundWidth * 9 / 10 , boundHeight * 9 / 10);
    bgText.text = [NSString stringWithFormat:@"%@\n\n%@\n\n%@\n\n%@", backgroudText1, backgroudText2, backgroudText3, backgroudText4];
    [self.view addSubview:bgText];
    [self.view sendSubviewToBack:bgText];

    btnQuit = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnQuit.frame = CGRectMake(xPos, yPos, btnWidth, btnHeight);
    btnQuit.layer.masksToBounds  = YES;
    btnQuit.layer.cornerRadius   = 5;
    btnQuit.layer.borderColor    = [UIColor blackColor].CGColor;
    btnQuit.layer.borderWidth    = 1;
    [btnQuit setBackgroundColor:[UIColor lightGrayColor]];
    [btnQuit setTitle:@"返回" forState:UIControlStateNormal];
    [btnQuit addTarget:self
                action:@selector(onQuit:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnQuit];
    
    xPos += elemGap + btnWidth;
    btnStop = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnStop.frame = CGRectMake(xPos, yPos, btnWidth, btnHeight);
    btnStop.layer.masksToBounds  = YES;
    btnStop.layer.cornerRadius   = 5;
    btnStop.layer.borderColor    = [UIColor blackColor].CGColor;
    btnStop.layer.borderWidth    = 1;
    [btnStop setBackgroundColor:[UIColor lightGrayColor]];
    [btnStop setTitle:@"停止" forState:UIControlStateNormal];
    [btnStop addTarget:self
                action:@selector(onStop:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnStop];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)viewDidAppear:(BOOL)animated {
    if(_playerVC && _playerVC.player)
    {
        [_playerVC.player.view setFrame: videoView.bounds];
        [videoView addSubview: _playerVC.player.view];
    }
}

- (IBAction)onQuit:(id)sender {
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (IBAction)onStop:(id)sender {
    if(_playerVC && _playerVC.player)
    {
        [_playerVC.player stop];
        
        [_playerVC.player removeObserver:_playerVC forKeyPath:@"currentPlaybackTime" context:nil];
        [_playerVC.player removeObserver:_playerVC forKeyPath:@"clientIP" context:nil];
        [_playerVC.player removeObserver:_playerVC forKeyPath:@"localDNSIP" context:nil];
        
        [_playerVC.player.view removeFromSuperview];
        _playerVC.player = nil;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.view];
    
    CALayer *touchedLayer = [self.view.layer hitTest:point];
    
    if(touchedLayer == _playerVC.player.view.layer){
        isMoving = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if(!isMoving){
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint current = [touch locationInView:self.view];
    CGPoint previous = [touch previousLocationInView:self.view];
    
    CGPoint center = videoView.center;
    
    CGPoint offset = CGPointMake(current.x - previous.x, current.y - previous.y);
    
    videoView.center = CGPointMake(center.x + offset.x, center.y + offset.y);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    isMoving = NO;
}

@end
