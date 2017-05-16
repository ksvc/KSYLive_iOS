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
    self.btnH = 35;
    self.winWdt = self.width;
    return self;
}

#pragma mark - UI elements layout
// 每次布局前,设置默认值
- (void) layoutUI {
    self.btnH = 30;
    self.winWdt = self.width;
    self.yPos = [[UIApplication sharedApplication] statusBarFrame].size.height;
}
- (CGFloat) getXStart {
    CGFloat xPos = _gap;
    if (_yPos > self.height){
        xPos += _winWdt;
    }
    return xPos;
}

- (void) putRow:(NSArray *) subV {
    NSInteger cnt = [subV count];
    if ( cnt < 1){
        return ;
    }
    CGFloat btnW = (_winWdt/cnt) - _gap*2;
    CGFloat xPos = [self getXStart];
    CGFloat step = _gap*2+btnW;
    CGFloat yPos = _yPos > self.height ? _yPos - self.height : _yPos;
    for (id item in subV) {
        if ([item isKindOfClass:[UIView class]]){
            UIView * v = item;
            v.frame = CGRectMake(xPos, yPos, btnW, _btnH);
        }
        xPos += step;
    }
    _yPos += (_btnH + _gap);
}
- (void) putRowFit:(NSArray *) subV {
    NSInteger cnt = [subV count];
    if ( cnt < 1){
        return ;
    }
    CGFloat xPos = [self getXStart];
    CGFloat step = 0;
    CGFloat yPos = _yPos > self.height ? _yPos - self.height : _yPos;
    for (id item in subV) {
        if ([item isKindOfClass:[UIView class]]){
            UIView * v = item;
            [v sizeToFit];
            step = v.frame.size.width;
            v.frame = CGRectMake(xPos, yPos, step, _btnH);
            xPos += step;
        }
        else {
            xPos += 5;
        }
    }
    _yPos += (_btnH + _gap);
}

- (void) putRow1:(UIView*)subV {
    CGFloat yPos = _yPos > self.height ? _yPos - self.height : _yPos;
    subV.frame = CGRectMake([self getXStart], yPos, _winWdt - _gap*2, _btnH);
    _yPos += (_btnH + _gap);
}

- (void) putRow2:(UIView*)subV0
             and:(UIView*)subV1{
    CGFloat btnW = (_winWdt/2) - _gap*2;
    CGFloat y = _yPos > self.height ? _yPos - self.height : _yPos;
    CGFloat x = [self getXStart];
    subV0.frame = CGRectMake(x, y, btnW, _btnH);
    subV1.frame = CGRectMake(x+_gap*2+btnW, y, btnW, _btnH);
    _yPos += (_btnH + _gap);
}

- (void) putRow3:(UIView*)subV0
             and:(UIView*)subV1
             and:(UIView*)subV2 {
    CGFloat btnW = (_winWdt/3) - _gap*2;
    
    CGFloat x = [self getXStart];
    CGFloat y = _yPos > self.height ? _yPos - self.height : _yPos;
    CGFloat xPos[3] = {x, x+_gap*2+btnW, x+_gap*4+btnW*2};
    if (subV0){
        subV0.frame = CGRectMake(xPos[0], y, btnW, _btnH);
    }
    if (subV1) {
        subV1.frame = CGRectMake(xPos[1], y, btnW, _btnH);
    }
    if (subV2) {
        subV2.frame = CGRectMake(xPos[2], y, btnW, _btnH);
    }
    _yPos += (_btnH + _gap);
}


//(firstV 使用内容宽度, 剩余宽度全部分配给secondV)
- (void) putNarrow:(UIView*)firstV
           andWide:(UIView*)secondV {
    CGFloat x = [self getXStart];
    CGFloat y = _yPos > self.height ? _yPos - self.height : _yPos;
    [firstV sizeToFit];
    CGRect rect = firstV.frame;
    rect.origin = CGPointMake(x, y);
    rect.size.height = _btnH;
    firstV.frame = rect;
    
    CGFloat btnW = (_winWdt) - _gap*3 - rect.size.width;
    CGFloat xPos = rect.origin.x + rect.size.width + _gap;
    secondV.frame = CGRectMake( xPos, y, btnW, _btnH);
    _yPos += (_btnH + _gap);
}
//(secondV 使用内容宽度, 剩余宽度全部分配给firstV)
- (void) putWide:(UIView*)firstV
       andNarrow:(UIView*)secondV {
    CGFloat x = [self getXStart];
    CGFloat y = _yPos > self.height ? _yPos - self.height : _yPos;
    
    [secondV sizeToFit];
    CGRect rect = secondV.frame;
    rect.size.height = _btnH;
    
    CGFloat slW = (_winWdt) - _gap*3 - rect.size.width;
    rect.origin = CGPointMake(slW+x, y);
    secondV.frame = rect;
    
    rect.origin = CGPointMake(x, y);
    rect.size.width = slW;
    firstV.frame = rect;
    _yPos += (_btnH + _gap);
}

- (void) putLable:(UIView*)lbl
          andView:(UIView*)subV{
    [self putNarrow:lbl andWide:subV];
}

- (void)  putSlider:(UIView*)sl
          andSwitch:(UIView*)sw{
    [self putWide:sl andNarrow:sw];
}

#pragma mark - new and add UI elements

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
    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
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
    segC.layer.cornerRadius = 5;
    segC.backgroundColor = [UIColor lightGrayColor];
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
    lbl.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3]; 
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
    if (iniV <2){
        sl.precision = 2;
    }
    [sl.slider addTarget:self
                  action:@selector(onSlider:)
        forControlEvents:UIControlEventValueChanged ];
    weakObj(self);
    sl.onSliderBlock = ^(id sender){
        [selfWeak onSlider:sender];
    };
    return sl;
}

#pragma mark - UI respond

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
    return [[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString];
}
@end

