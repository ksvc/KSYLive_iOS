//
//  KSYPlayerConfigureVC.m
//  KSYPlayerDemo
//
//  Created by mayudong on 2017/3/3.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "KSYPlayerConfigureVC.h"

@interface KSYPlayerConfigureVC ()
@property (nonatomic) PlayerConfigure config;
@property(nonatomic,copy) ConfirmBlock confirm;
@property(nonatomic,copy) CancelBlock cancel;
@end

@implementation KSYPlayerConfigureVC{
    UIButton* btnConfirm;
    UIButton* btnCancel;
    
    UILabel  *lableHWCodec;
    UISwitch  *switchHwCodec;
    
    UILabel  *lableDeinterlace;
    UISwitch  *switchDeinterlace;
    
    UILabel  *lableAudioInterrupt;
    UISwitch  *switchAudioInterrupt;
    
    UILabel  *lableLoop;
    UISwitch  *switchLoop;
    
    UILabel  *lableConnectTimeout;
    UITextField *textConnectTimeout;
    UILabel  *lableConnectTimeout_unit;
    
    UILabel  *lableReadTimeout;
    UITextField *textReadTimeout;
    UILabel  *lableReadTimeout_unit;
    
    UILabel  *lableBufferTimeMax;
    UITextField *textBufferTimeMax;
    UILabel  *lableBufferTimeMax_unit;
    
    UILabel  *lableBufferSizeMax;
    UITextField *textBufferSizeMax;
    UILabel  *lableBufferSizeMax_unit;
    
}

-(instancetype)initWithConfig:(PlayerConfigure)config confirm:(ConfirmBlock)confirm{
    if((self = [super init])) {
        self.config = config;
        self.confirm = confirm;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initUI];
}

- (UIButton *)addButtonWithTitle:(NSString *)title action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds  = YES;
    button.layer.cornerRadius   = 5;
    button.layer.borderColor    = [UIColor blackColor].CGColor;
    button.layer.borderWidth    = 1;
    [self.view addSubview:button];
    return button;
}
- (UITextField *)addTextField{
    UITextField *text = [[UITextField alloc]init];
//    text.delegate     = self;
    [self.view addSubview:text];
    text.layer.masksToBounds = YES;
    text.layer.borderWidth   = 1;
    text.layer.borderColor   = [UIColor blackColor].CGColor;
    text.layer.cornerRadius  = 2;
    text.keyboardType = UIKeyboardTypeDecimalPad;
    return text;
}

- (UILabel*)addLabel:(NSString*)text{
    UILabel* label = [[UILabel alloc]init];
    label.text = text;
    label.textColor = [UIColor lightGrayColor];
    [self.view addSubview:label];
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
}

-(void)initUI{
    btnConfirm = [self addButtonWithTitle:@"确定" action:@selector(onConfirm)];
    btnCancel = [self addButtonWithTitle:@"取消" action:@selector(onCancel)];
    
    lableHWCodec = [self addLabel:@"硬解码"];
    switchHwCodec = [[UISwitch alloc] init];
    [self.view  addSubview:switchHwCodec];
    switchHwCodec.on = _config.decodeMode == MPMovieVideoDecoderMode_Hardware ? YES : NO;
    
    lableDeinterlace = [self addLabel:@"反交错处理"];
    switchDeinterlace = [[UISwitch alloc] init];
    [self.view  addSubview:switchDeinterlace];
    switchDeinterlace.on = _config.deinterlaceMode == MPMovieVideoDeinterlaceMode_Auto ? YES : NO;
    
    lableAudioInterrupt = [self addLabel:@"音频打断"];
    switchAudioInterrupt = [[UISwitch alloc] init];
    [self.view  addSubview:switchAudioInterrupt];
    switchAudioInterrupt.on = _config.bAudioInterrupt;
    
    lableLoop = [self addLabel:@"循环播放"];
    switchLoop = [[UISwitch alloc] init];
    [self.view  addSubview:switchLoop];
    switchLoop.on = _config.bLoop;
    
    lableConnectTimeout = [self addLabel:@"连接超时"];
    lableConnectTimeout_unit = [self addLabel:@"秒"];
    textConnectTimeout = [self addTextField];
    textConnectTimeout.text = [NSString stringWithFormat:@"%d", _config.connectTimeout];
    
    lableReadTimeout = [self addLabel:@"读超时"];
    lableReadTimeout_unit = [self addLabel:@"秒"];
    textReadTimeout = [self addTextField];
    textReadTimeout.text = [NSString stringWithFormat:@"%d", _config.readTimeout];
    
    lableBufferTimeMax = [self addLabel:@"bufferTimeMax"];
    lableBufferTimeMax_unit = [self addLabel:@"秒"];
    textBufferTimeMax = [self addTextField];
    if(_config.bufferTimeMax == -1){
        textBufferTimeMax.placeholder = @"未设置";
        textBufferTimeMax.text = @"";
    }else{
        textBufferTimeMax.text = [NSString stringWithFormat:@"%.1f", _config.bufferTimeMax];
    }
    
    lableBufferSizeMax = [self addLabel:@"bufferSizeMax"];
    lableBufferSizeMax_unit = [self addLabel:@"MB"];
    textBufferSizeMax = [self addTextField];
    if(_config.bufferSizeMax == -1){
        textBufferSizeMax.placeholder = @"未设置";
        textBufferSizeMax.text = @"";
    }else{
        textBufferSizeMax.text = [NSString stringWithFormat:@"%d", _config.bufferSizeMax];
    }
    
    [self layoutUI];

}

- (void) layoutUI {
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    CGFloat gap =15;
    CGFloat btnWdt = ( (wdt-gap) / 4) - gap;
    CGFloat btnHgt = 30;
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    
    yPos = 2 * gap;
    xPos = gap;
    lableHWCodec.frame = CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt*2 + gap;
    switchHwCodec.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    yPos += btnHgt + gap;
    xPos = gap;
    lableDeinterlace.frame = CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt*2 + gap;
    switchDeinterlace.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    yPos += btnHgt + gap;
    xPos = gap;
    lableAudioInterrupt.frame = CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt*2 + gap;
    switchAudioInterrupt.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    yPos += btnHgt + gap;
    xPos = gap;
    lableLoop.frame = CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt*2 + gap;
    switchLoop.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    yPos += btnHgt + gap;
    xPos = gap;
    lableConnectTimeout.frame = CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt*2 + gap;
    textConnectTimeout.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += btnWdt;
    lableConnectTimeout_unit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    yPos += btnHgt + gap;
    xPos = gap;
    lableReadTimeout.frame = CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt*2 + gap;
    textReadTimeout.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += btnWdt;
    lableReadTimeout_unit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    yPos += btnHgt + gap;
    xPos = gap;
    lableBufferTimeMax.frame = CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt*2 + gap;
    textBufferTimeMax.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += btnWdt;
    lableBufferTimeMax_unit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    yPos += btnHgt + gap;
    xPos = gap;
    lableBufferSizeMax.frame = CGRectMake(xPos, yPos, btnWdt * 2, btnHgt);
    xPos += btnWdt*2 + gap;
    textBufferSizeMax.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos += btnWdt;
    lableBufferSizeMax_unit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    
    xPos = gap;
    yPos = hgt - btnHgt - gap;
    btnConfirm.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    xPos = wdt - gap - btnWdt;
    btnCancel.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
}

-(void)onConfirm{
    
    _config.decodeMode = switchHwCodec.isOn ? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
    _config.deinterlaceMode = switchDeinterlace.isOn ? MPMovieVideoDeinterlaceMode_Auto : MPMovieVideoDeinterlaceMode_None;
    _config.bAudioInterrupt = switchAudioInterrupt.isOn ? YES : NO;
    _config.bLoop = switchLoop.isOn ? YES : NO;
    _config.connectTimeout = [textConnectTimeout.text intValue];
    _config.readTimeout = [textReadTimeout.text intValue];
    if([textBufferTimeMax.text isEqualToString:@""]){
        _config.bufferTimeMax = -1;
    }else{
        _config.bufferTimeMax = [textBufferTimeMax.text doubleValue];
    }
    if([textBufferSizeMax.text isEqualToString:@""]){
        _config.bufferSizeMax = -1;
    }else{
        _config.bufferSizeMax = [textBufferSizeMax.text intValue];
    }
    
    if(_confirm){
        _confirm(_config);
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)onCancel{
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (![textConnectTimeout isExclusiveTouch]) {
        [textConnectTimeout resignFirstResponder];
    }
    if (![textReadTimeout isExclusiveTouch]) {
        [textReadTimeout resignFirstResponder];
    }
    if (![textBufferTimeMax isExclusiveTouch]) {
        [textBufferTimeMax resignFirstResponder];
    }
    if (![textBufferSizeMax isExclusiveTouch]) {
        [textBufferSizeMax resignFirstResponder];
    }
}

@end
