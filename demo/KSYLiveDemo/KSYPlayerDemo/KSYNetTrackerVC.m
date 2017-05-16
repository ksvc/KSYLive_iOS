//
//  KSYNetworkVC.m
//  KSYPlayerDemo
//
//  Created by 施雪梅 on 2017/1/4.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "KSYUIView.h"
#import "KSYNetTrackerVC.h"

#define ELEMENT_GAP  15

@interface KSYNetTrackerVC() <UITextViewDelegate>

@end

@implementation KSYNetTrackerVC{
    KSYUIView *ctrlView;
    
    UILabel *lbDomain;
    UITextField *tfDomain;
    UIView * tfDomainLine;
    
    UIButton *btnPing;
    UIButton *btnMTR;
    UIButton *btnQuit;
    
    UITextView *txtView_ret;
    
    KSYNetTracker *tracker;
    BOOL isRunning;
    
    KSY_NETTRACKER_ACTION action;
    NSString *infoLog;
    NSString  *stateStr;
    NSString *displayStr;
    NSMutableArray  *_registeredNotifications;
}

- (void)dealloc {
    [self unregisterObserver];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    
    [self initNetTracker];
    
    infoLog = @"";
    stateStr = @"";
    displayStr = @"";
}

- (void)setupUI {
    ctrlView = [[KSYUIView alloc] initWithFrame:self.view.bounds];
    ctrlView.backgroundColor = [UIColor whiteColor];
    ctrlView.gap = ELEMENT_GAP;
    
    @WeakObj(self);
    ctrlView.onBtnBlock = ^(id sender){
        [selfWeak  onBtn:sender];
    };
    
    btnPing = [ctrlView addButton:@"Ping"];
    [btnPing setTag:KSY_NETTRACKER_ACTION_PING];
    
    btnMTR = [ctrlView addButton:@"MTR"];
    [btnMTR setTag:KSY_NETTRACKER_ACTION_MTR];
    
    btnQuit = [ctrlView addButton:@"Quit"];

    lbDomain = [ctrlView addLable:@"请输入待探测地址："];
    lbDomain.backgroundColor = [UIColor whiteColor];
    
    tfDomain = [ctrlView addTextField:@"www.baidu.com"];
    tfDomain.borderStyle = UITextBorderStyleNone;
    tfDomain.returnKeyType = UIReturnKeyDone;
    tfDomain.delegate = self;
    
    tfDomainLine = [ctrlView addLable:nil];
    tfDomainLine.backgroundColor = [UIColor blackColor];
    
    txtView_ret = [[UITextView alloc] initWithFrame:CGRectZero];
    txtView_ret.layer.borderWidth = 1.0f;
    txtView_ret.layer.borderColor = [UIColor lightGrayColor].CGColor;
    txtView_ret.backgroundColor = [UIColor whiteColor];
    txtView_ret.font = [UIFont fontWithName:@"Courier New" size:12.0f];
    txtView_ret.textAlignment = NSTextAlignmentLeft;
    txtView_ret.scrollEnabled = YES;
    txtView_ret.editable = NO;
    [ctrlView addSubview:txtView_ret];
    
    [self layoutUI];
    
    [self.view addSubview: ctrlView];
}

- (void)layoutUI {
    CGFloat wdt = self.view.frame.size.width;
    CGFloat hgt = self.view.frame.size.height;
    int xPos = 0, yPos = 0;
    
    ctrlView.frame = self.view.frame;
    [ctrlView layoutUI];
    
    xPos = wdt / 8;
    yPos = hgt / 15;
    lbDomain.frame = CGRectMake(xPos, yPos, wdt * 4 / 5, ctrlView.btnH);
    
    xPos += 20;
    yPos += ctrlView.btnH + ELEMENT_GAP;
    tfDomain.frame = CGRectMake(xPos, yPos, wdt * 3 / 5, ctrlView.btnH);
    
    tfDomainLine.frame = CGRectMake(xPos ,  yPos + ctrlView.btnH, tfDomain.frame.size.width, 2);
    
    yPos += ctrlView.btnH + 2 * ELEMENT_GAP;
    ctrlView.yPos  = yPos;
    [ctrlView putRow:@[btnPing, btnMTR, btnQuit]];

    yPos += ctrlView.btnH + ELEMENT_GAP;
    txtView_ret.frame = CGRectMake(0, yPos, wdt, hgt - yPos);
}

- (void)onBtn:(UIButton *)btn{
    if (btn == btnPing || btn == btnMTR) {
        [self startNetDiagnosis: btn];
    }else if (btn == btnQuit){
        [self onQuit];
    }
}

- (void) initNetTracker {
    tracker =  [[KSYNetTracker alloc] init];
    if(tracker == nil)
        NSLog(@"init tracker failed\n");
    [self setupObserver];
}

- (void) setupObserver {
    _registeredNotifications = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleTrackerNotify:)
                                                name:(KSYNetTrackerOnceDoneNotification)
                                              object:tracker];
    [_registeredNotifications addObject:KSYNetTrackerOnceDoneNotification];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleTrackerNotify:)
                                                name:(KSYNetTrackerFinishedNotification)
                                              object:tracker];
    [_registeredNotifications addObject:KSYNetTrackerFinishedNotification];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handleTrackerNotify:)
                                                name:(KSYNetTrackerErrorNotification)
                                              object:tracker];
    [_registeredNotifications addObject:KSYNetTrackerErrorNotification];
}

- (void) unregisterObserver {
    for (NSString *name in _registeredNotifications) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:name
                                                      object:tracker];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onQuit {
    displayStr = @"";
    [self displayInfo];
    [self stopNetDiagnosis];
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

- (void)startNetDiagnosis:(UIButton *)button
{
    if(!isRunning){
        displayStr = @"";

        action = button.tag;
        tracker.action = action;
        
        if([tracker start:tfDomain.text])
        {
            displayStr = @"启动探测失败，请检查网络或待探测地址!";
            [self displayInfo];
            return ;
        }
        [button setTitle:@"stop" forState:UIControlStateNormal];

        if(action == KSY_NETTRACKER_ACTION_PING)
            btnMTR.enabled = NO;
        else
            btnPing.enabled = NO;
        
        isRunning = !isRunning;
        displayStr  = stateStr = @"开始探测......\n\n";
        [self displayInfo];
    }
    else
    {
        [self stopNetDiagnosis];
        if(action == KSY_NETTRACKER_ACTION_PING)
            displayStr = [displayStr stringByAppendingString:[self getPingRetStr]];
        else
        {
            displayStr = stateStr = @"停止探测，已统计结果如下：\n";
            displayStr = [displayStr stringByAppendingString:infoLog];
        }
        [self displayInfo];
    }
}

- (void) stopNetDiagnosis
{
    [btnPing setTitle:@"Ping" forState:UIControlStateNormal];
    [btnMTR setTitle:@"MTR" forState:UIControlStateNormal];
    btnMTR.enabled = YES;
    btnPing.enabled = YES;
    
    [tracker stop];
    isRunning = NO;
}

- (void)handleTrackerNotify:(NSNotification*)notify
{
    if(tracker == nil)
        return ;
    
    if(KSYNetTrackerOnceDoneNotification == notify.name)
    {
        if(action == KSY_NETTRACKER_ACTION_PING)
        {
            float rtt = [[[notify userInfo] valueForKey:@"rtt"] floatValue];
            NSInteger count = [[[notify userInfo] valueForKey:@"count"] integerValue];
            if(rtt < 0.00000001)
                displayStr = [displayStr stringByAppendingFormat:@"Request timeout for icmp_seq %ld\n", count];
            else
            {
                KSYNetRouterInfo  *pingRet = tracker.routerInfo[0];
                displayStr = [displayStr stringByAppendingFormat:@"ping %@ icmp_seq %ld time=%0.3f ms\n", pingRet.ips[0], count, rtt];
            }
        }
        else
        {
            [self getRouterInfo];
            displayStr = @"";
            displayStr = [displayStr stringByAppendingString:stateStr];
            displayStr = [displayStr stringByAppendingString:infoLog];
        }
    }
    else if(KSYNetTrackerFinishedNotification == notify.name)
    {
        if(action == KSY_NETTRACKER_ACTION_PING)
            displayStr = [displayStr stringByAppendingString:[self getPingRetStr]];
        else
        {
            stateStr = @"探测完成，结果如下：\n\n";
            displayStr = @"";
            displayStr = [displayStr stringByAppendingString:stateStr];
            displayStr = [displayStr stringByAppendingString:infoLog];
        }
        
        [btnPing setTitle:@"Ping" forState:UIControlStateNormal];
        [btnMTR setTitle:@"MTR" forState:UIControlStateNormal];
        btnMTR.enabled = YES;
        btnPing.enabled = YES;
        isRunning = NO;
        [tracker stop];
    }
    else if(KSYNetTrackerErrorNotification == notify.name)
    {
        
    }
    
    [self displayInfo];
}

- (void) displayInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        txtView_ret.text = displayStr;
    });
}

- (NSString *) getPingRetStr{
    NSString *pingRetStr= @"";
    KSYNetRouterInfo  *pingRet = tracker.routerInfo[0];
    pingRetStr = [pingRetStr stringByAppendingFormat:@"\n ------ping statics-----\n"];
    pingRetStr = [pingRetStr stringByAppendingFormat:@"%d packets transmitted, %d packets received,  %0.3f packet loss\n",
                  pingRet.number, (int)(pingRet.number * (1 - pingRet.loss)), pingRet.loss];
    
    pingRetStr = [pingRetStr stringByAppendingFormat:@"round-trip min/avg/max/stdev = %0.3f/%0.3f/%0.3f/%0.3fms\n",
                  pingRet.tmin, pingRet.tavg, pingRet.tmax, pingRet.tdev];
    return pingRetStr;
}

- (NSString *) getInfoHeader{
    NSString *header = @"";
    header = [header stringByAppendingFormat:@"%-8s", "idx"];
    header = [header stringByAppendingFormat:@"%-10s", "ip"];
    header = [header stringByAppendingFormat:@"%-8s", "number"];
    header = [header stringByAppendingFormat:@"%-7s", "max"];
    header = [header stringByAppendingFormat:@"%-7s", "min"];
    header = [header stringByAppendingFormat:@"%-6s", "avg"];
    header = [header stringByAppendingFormat:@"%-6s", "stdev"];
    header = [header stringByAppendingFormat:@"%-4s\n", "loss"];
    return header;
}

- (void)getRouterInfo{
    infoLog = [self getInfoHeader];
    int i = 1, j = 0;
    for(KSYNetRouterInfo  *netInfo in tracker.routerInfo)
    {
        if(netInfo.ips)
        {
            j = 0;
            for(NSString *ip in netInfo.ips)
            {
                if(j == 0)
                {
                    infoLog = [infoLog stringByAppendingFormat:@"%-3d", i];
                    infoLog = [infoLog stringByAppendingFormat:@"%-16s", [ip UTF8String]];
                    infoLog = [infoLog stringByAppendingFormat:@"%-4d", netInfo.number];
                    infoLog = [infoLog stringByAppendingFormat:@"%5.1fms", netInfo.tmax];
                    infoLog = [infoLog stringByAppendingFormat:@"%5.1fms", netInfo.tmin];
                    infoLog = [infoLog stringByAppendingFormat:@"%5.1fms", netInfo.tavg];
                    infoLog = [infoLog stringByAppendingFormat:@"  %-6.1f", netInfo.tdev];
                    infoLog = [infoLog stringByAppendingFormat:@"%-4.1f\n", netInfo.loss];
                }
                else
                    infoLog = [infoLog stringByAppendingFormat:@"    %-16s\n", [ip UTF8String]];
                j++;
            }
        }
        else
        {
            infoLog = [infoLog stringByAppendingFormat:@"%-3d", i];
            infoLog = [infoLog stringByAppendingFormat:@"%-16s", "--"];
            infoLog = [infoLog stringByAppendingFormat:@"%-4s", "--"];
            infoLog = [infoLog stringByAppendingFormat:@"%-7s", "--"];
            infoLog = [infoLog stringByAppendingFormat:@"%-7s", "--"];
            infoLog = [infoLog stringByAppendingFormat:@"%-7s", "--"];
            infoLog = [infoLog stringByAppendingFormat:@"%-6s", "--"];
            infoLog = [infoLog stringByAppendingFormat:@"%-4s\n\n", "--"];
        }
        i++;
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
