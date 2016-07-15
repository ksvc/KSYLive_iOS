//
//  UIView+Frames.m
//  KSYGPUStreamerDemo
//
//  Created by 孙健 on 16/6/21.
//  Copyright © 2016年 ksyun. All rights reserved.
//

#import "KSYUIView.h"

@implementation KSYUIView

- (CGFloat)x{
    return  self.frame.origin.x;
}
- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y{
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)width{
    return self.size.width;
}
- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height{
    return self.size.height;
}
- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGPoint)origin{
    return self.origin;
}
- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size{
    return self.frame.size;
}
- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
#pragma mark - init
- (id) initWithParent:(KSYUIView*)pView{
    self = [self init];
    if (pView){
        self.hidden = YES;
        [pView addSubview:self];
    }
    return self;
}
- (id) init {
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    self.gap = 4;
    self.btnH = 40;
    self.winWdt = self.width - self.gap*2;
    return self;
}

//
- (void) layoutUI {
    self.btnH = 40;
    self.winWdt = self.width - _gap*2;
    self.yPos =_gap;
}

- (void) putRow:(NSArray *) subV {
    NSInteger cnt = [subV count];
    if ( cnt < 1){
        return ;
    }
    CGFloat btnW = (self.width/cnt) - _gap*2;
    CGFloat xPos = _gap;
    CGFloat step = _gap*2+btnW;
    for (id item in subV) {
        if ([item isKindOfClass:[UIView class]]){
            UIView * v = item;
            v.frame = CGRectMake(xPos, _yPos, btnW, _btnH);
        }
        xPos += step;
    }
    _yPos += (_btnH + _gap);
}

- (void) putRow1:(UIView*)subV {
    subV.frame = CGRectMake(_gap, _yPos, _winWdt, _btnH);
    _yPos += (_btnH + _gap);
}

- (void) putRow2:(UIView*)subV0
             and:(UIView*)subV1{
    CGFloat btnW = (self.width/2) - _gap*2;
    subV0.frame = CGRectMake(_gap, _yPos, btnW, _btnH);
    subV1.frame = CGRectMake(_gap*3+btnW, _yPos, btnW, _btnH);
    _yPos += (_btnH + _gap);
}

- (void) putRow3:(UIView*)subV0
             and:(UIView*)subV1
             and:(UIView*)subV2 {
    CGFloat btnW = (self.width/3) - _gap*2;
    CGFloat xPos[3] = {_gap, _gap*3+btnW, _gap*5+btnW*2};
    if (subV0){
        subV0.frame = CGRectMake(xPos[0], _yPos, btnW, _btnH);
    }
    if (subV1) {
        subV1.frame = CGRectMake(xPos[1], _yPos, btnW, _btnH);
    }
    if (subV2) {
        subV2.frame = CGRectMake(xPos[2], _yPos, btnW, _btnH);
    }
    _yPos += (_btnH + _gap);
}

- (void) putLable:(UIView*)lbl
          andView:(UIView*)subV{
    [lbl sizeToFit];
    CGRect rect = lbl.frame;
    rect.origin = CGPointMake(_gap, _yPos);
    rect.size.height = _btnH;
    lbl.frame = rect;
    
    CGFloat btnW = (self.width) - _gap*3 - rect.size.width;
    CGFloat xPos = rect.origin.x + rect.size.width + _gap;
    subV.frame = CGRectMake( xPos, _yPos, btnW, _btnH);
    _yPos += (_btnH + _gap);
}

- (void)  putSlider:(UIView*)sl
          andSwitch:(UIView*)sw{
    [sw sizeToFit];
    CGRect rect = sw.frame;
    rect.size.height = _btnH;
    
    CGFloat slW = (self.width) - _gap*3 - rect.size.width;
    rect.origin = CGPointMake(slW+_gap, _yPos);
    sw.frame = rect;
    
    rect.origin = CGPointMake(_gap, _yPos);
    rect.size.width = slW;
    sl.frame = rect;
    _yPos += (_btnH + _gap);
}

#pragma mark - add UI elements

- (UITextField *)addTextField: (NSString*)text{
    UITextField * textF;
    textF = [[UITextField alloc] init];
    textF.text =  text;
    textF.borderStyle = UITextBorderStyleRoundedRect;
    [self addSubview:textF];
    return textF;
}

- (UIButton *)newButton: (NSString*)title{
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    button.alpha = 0.9;
    [self addSubview:button];
    return button;
}

// add to default respond
- (UIButton *)addButton:(NSString*)title{
    UIButton * button = [self newButton: title];
    [button addTarget:self
               action:@selector(onBtn:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIButton *)addButton:(NSString*)title
                 action:(SEL)action {
    UIButton * button = [self newButton: title];
    [button addTarget:self
               action:action
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UISegmentedControl *)addSegCtrlWithItems: (NSArray *) items {
    UISegmentedControl * segC;
    segC = [[UISegmentedControl alloc] initWithItems:items];
    segC.selectedSegmentIndex = 0;
    [segC addTarget:self
               action:@selector(onSegCtrl:)
     forControlEvents:UIControlEventValueChanged];
    [self addSubview:segC];
    return segC;
}

- (UILabel *)addLable:(NSString*)title{
    UILabel *  lbl = [[UILabel alloc] init];
    lbl.text = title;
    [self addSubview:lbl];
    return lbl;
}

- (UISwitch *)newSwitch:(BOOL) on{
    UISwitch *sw = [[UISwitch alloc] init];
    [self addSubview:sw];
    sw.on = on;
    return sw;
}

- (UISwitch *)addSwitch:(BOOL) on{
    UISwitch *switcher = [self newSwitch:on];
    [switcher addTarget:self
                 action:@selector(onSwitch:)
       forControlEvents:UIControlEventValueChanged ];
    return switcher;
}

- (UISlider *)newSliderFrom: (float) minV
                         To: (float) maxV
                       Init: (float) iniV {
    UISlider *sl = [[UISlider alloc] init];
    [self addSubview:sl];
    sl.minimumValue = minV;
    sl.maximumValue = maxV;
    sl.value = iniV;
    sl.continuous = NO;
    return sl;
}

- (UISlider *)addSliderFrom: (float) minV
                         To: (float) maxV
                       Init: (float) iniV {
    UISlider *slider = [self newSliderFrom:minV To:maxV Init:iniV];
    [slider addTarget:self
               action:@selector(onSlider:)
     forControlEvents:UIControlEventValueChanged];
    return slider;
}

- (UISlider *)addSliderFrom: (float) minV
                         To: (float) maxV
                       Init: (float) iniV
                     action: (SEL)action {
    UISlider *slider = [self newSliderFrom:minV To:maxV Init:iniV];
    [ slider addTarget:self
                action:action
      forControlEvents:UIControlEventValueChanged ];
    return slider;
}


- (KSYNameSlider *)addSliderName: (NSString*) name
                            From: (float) minV
                              To: (float) maxV
                            Init: (float) iniV {
    KSYNameSlider *sl = [[KSYNameSlider alloc] init];
    [self addSubview:sl];
    sl.slider.minimumValue = minV;
    sl.slider.maximumValue = maxV;
    sl.slider.value = iniV;
    sl.nameL.text = name;
    sl.normalValue = (iniV -minV)/maxV;
    sl.valueL.text = [NSString stringWithFormat:@"%d", (int)iniV];
    [sl.slider addTarget:self
                  action:@selector(onSlider:)
        forControlEvents:UIControlEventValueChanged ];
    __weak KSYUIView * view = self;
    sl.onSliderBlock = ^(id sender){
        [view onSlider:sender];
    };
    return sl;
}

//UIControlEventTouchUpInside
- (IBAction)onBtn:(id)sender {
    if (_onBtnBlock) {
        _onBtnBlock(sender);
    }
    if ([self.superview isKindOfClass:[KSYUIView class]]){
        KSYUIView * v = (KSYUIView *)self.superview;
        [v onBtn:sender];
    }
}
//UIControlEventValueChanged
- (IBAction)onSwitch:(id)sender {
    if (_onSwitchBlock){
        _onSwitchBlock(sender);
    }
    if ([self.superview isKindOfClass:[KSYUIView class]]){
        KSYUIView * v = (KSYUIView *)self.superview;
        [v onSwitch:sender];
    }
}
//UIControlEventValueChanged
- (IBAction)onSlider:(id)sender {
    if (_onSliderBlock){
        _onSliderBlock(sender);
    }
    if ([self.superview isKindOfClass:[KSYUIView class]]){
        KSYUIView * v = (KSYUIView *)self.superview;
        [v onSlider:sender];
    }
}

//UIControlEventValueChanged
- (IBAction)onSegCtrl:(id)sender {
    if (_onSegCtrlBlock){
        _onSegCtrlBlock(sender);
    }
    if ([self.superview isKindOfClass:[KSYUIView class]]){
        KSYUIView * v = (KSYUIView *)self.superview;
        [v onSegCtrl:sender];
    }
}

// 获取设备的UUID
+ (NSString *) getUuid{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}
@end

