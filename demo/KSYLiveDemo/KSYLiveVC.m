//
//  FirstViewController.m
//  QYLive
//
//  Created by yiqian on 11/3/15.
//  Copyright (c) 2015 kingsoft. All rights reserved.
//

#import "KSYLiveVC.h"
#import "QRViewController.h"
#import "KSYPlayerVC.h"
#import "KSYProberVC.h"
#import "KSYMonkeyTestVC.h"
#import "KSYNetTrackerVC.h"
#import "KSYVideoListVC.h"
#ifndef KSYPlayer_Demo
#import "KSYPresetCfgVC.h"
#import "KSYRecordVC.h"
#import "KSYSimplestStreamerVC.h"
#import "KSYHorScreenStreamerVC.h"
#import "KSYBrushStreamerVC.h"
#import "KSYBgpStreamerVC.h"
#endif

typedef NS_ENUM(NSInteger, KSYDemoMenuType){
    KSYDemoMenuType_PLAY = 0,                     //播放
    KSYDemoMenuType_STREAM,                       //推流
    KSYDemoMenuType_RECORD,                       //录制
    KSYDemoMenuType_TEST,                         //测试
};

@interface KSYLiveVC ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>{
    //扫描二维码按钮
    UIButton        *_buttonQR;
    //关于按钮
    UIButton        *_buttonAbout;
    CGFloat         _width;
    CGFloat         _height;
    //功能列表
    UIPickerView *_pickerMenu;
    //地址列表
    UIPickerView *_pickerAddress;
    //执行按钮
    UIButton *_buttonDone;
    //存放控制器栏的多个按钮的名称
    NSMutableArray *_controllers;
    //控制器的名称和创建方法的字典
    NSMutableDictionary * _vcNameDict;
    //存放多个推流地址的名称
    NSMutableArray *_arrayStreamAddress;
    //存放多个播放地址
    NSMutableArray *_arrayPlayAddress;
    //存放多个录制文件名
    NSMutableArray *_arrayRecordFileName;
    //功能列表标题
    UILabel *_labelMenu;
    //地址列表标题
    UILabel *_labelAddress;
    //当前所选功能类型
    KSYDemoMenuType _type;
    //当前选中的功能
    
    //当前选中的地址
    NSString *_currentSelectUrl;
    
}
@property NSInteger selectMenuRow;
@end

@implementation KSYLiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KSYDEMO";
    _labelMenu = [self addLabelWithText:@"Demo 功能列表" textColor:[UIColor blueColor]];
    _labelAddress = [self addLabelWithText:@"播放地址列表" textColor:[UIColor blueColor]];
    //添加开始按钮
    _buttonDone = [self addButton:@"开始"];
    self.view.backgroundColor = [UIColor whiteColor];
    NSString * uuidStr =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *devCode  = [[uuidStr substringToIndex:3] lowercaseString];
    //推流地址
    NSString *streamSrv  = @"rtmp://mobile.kscvbu.cn/live";
    NSString *streamUrl      = [ NSString stringWithFormat:@"%@/%@", streamSrv, devCode];
    _arrayStreamAddress = [NSMutableArray arrayWithObjects:streamUrl,nil];
    //推流地址对应的拉流地址
    NSString *streamPlaySrv = @"http://mobile.kscvbu.cn:8080/live";
    NSString *streamPlayPostfix = @".flv";
    NSString *streamPlayUrl = [ NSString stringWithFormat:@"%@/%@%@", streamPlaySrv, devCode,streamPlayPostfix];
    //拉流地址
    NSString *playUrl = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
    _arrayPlayAddress = [NSMutableArray array];
    [_arrayPlayAddress addObject:playUrl];
    [_arrayPlayAddress addObject:streamPlayUrl];
    [_arrayPlayAddress addObject:@"RecordAv.mp4"];
    //初始化时的默认Url
    _currentSelectUrl = _arrayPlayAddress[0];
    //录制文件名
    NSString *recordFile = @"RecordAv.mp4";
    _arrayRecordFileName = [NSMutableArray arrayWithObjects:recordFile,nil];
    [self initVariable];
    //布局UI
    [self initLiveVCUI];
    
}

//添加一个居中的Label
- (UILabel *)addLabelWithText:(NSString *)text textColor:(UIColor*)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = textColor;
    label.numberOfLines = -1;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.masksToBounds = YES;
    label.layer.borderWidth   = 1;
    label.layer.borderColor   = [UIColor blackColor].CGColor;
    label.layer.cornerRadius  = 2;
    [self.view addSubview:label];
    return label;
}

- (UITextField *)addTextField{
    //添加文本框
    UITextField *text = [[UITextField alloc]init];
    text.delegate     = self;
    [self.view addSubview:text];
    text.layer.masksToBounds = YES;
    text.layer.borderWidth   = 1;
    text.layer.borderColor   = [UIColor blackColor].CGColor;
    text.layer.cornerRadius  = 2;
    return text;
}

-(UIPickerView *)addPickerView{
    //生成一个UIPickerView
    UIPickerView *picker = [[UIPickerView alloc]init];
    [self.view addSubview: picker];
    picker.hidden     = NO;
    picker.delegate   = self;
    picker.dataSource = self;
    picker.showsSelectionIndicator= YES;
    picker.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    picker.layer.masksToBounds = YES;
    picker.layer.borderWidth   = 1;
    picker.layer.borderColor   = [UIColor blackColor].CGColor;
    picker.layer.cornerRadius  = 2;
    return picker;
}

//指定pickerview有几个表盘
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//指定每个表盘上有几行数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger result = 0;
    if (pickerView == _pickerMenu) {
        result = _controllers.count;
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_STREAM){
        //推流状态
        result = _arrayStreamAddress.count;
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_PLAY){
        //拉流状态
        result = _arrayPlayAddress.count;
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_TEST){
        result = 0;
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_RECORD){
        result = _arrayRecordFileName.count;
    }
    return result;
}

//判断是哪个pickerview，返回相应的title
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = nil;
    if (pickerView == _pickerMenu){
        str = _controllers[row];
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_STREAM){
        str = _arrayStreamAddress[row];
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_PLAY){
        str = _arrayPlayAddress[row];
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_RECORD){
        str = _arrayRecordFileName[row];
    }
    return str;
}

//选中某行后回调的方法，获得选中结果
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == _pickerMenu)//功能列表
    {
        self.selectMenuRow = row;
        if (row >= 0 && row <= 3) {
            //类型为播放
            _type = KSYDemoMenuType_PLAY;
            _labelAddress.text = @"播放地址列表";
            _currentSelectUrl = _arrayPlayAddress[0];
        }else if(row >= 5 && row <= 9){
            //类型为推流
            _type = KSYDemoMenuType_STREAM;
            _labelAddress.text = @"推流地址列表";
            _currentSelectUrl = _arrayStreamAddress[0];
        }else if(row == 10){
            //类型为录制
            _type = KSYDemoMenuType_RECORD;
            _labelAddress.text = @"录制文件名";
            _currentSelectUrl = _arrayRecordFileName[0];
        }else if(row == 4 || row == 11){
            //类型为测试
            _type = KSYDemoMenuType_TEST;
        }
        [self UIAtType:_type];
        [_pickerAddress reloadAllComponents];
     //   [self initFrame];
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_STREAM){
        //当前选中的推流地址列表
        _currentSelectUrl = _arrayStreamAddress[row];
    }else if(pickerView == _pickerAddress && _type == KSYDemoMenuType_PLAY){
        //当前选中的拉流地址列表
        _currentSelectUrl = _arrayPlayAddress[row];
    }
}
//控件布局
-(void)UIAtType:(KSYDemoMenuType)type{
    if (type == KSYDemoMenuType_PLAY || type ==KSYDemoMenuType_STREAM || type == KSYDemoMenuType_RECORD) {
        _pickerAddress.hidden = NO;
        _buttonAbout.hidden = NO;
        _buttonQR.hidden = NO;
        _labelAddress.hidden = NO;
        _buttonDone.frame = CGRectMake(1, CGRectGetMaxY(_pickerAddress.frame), _width - 2, _height- CGRectGetMaxY(_pickerAddress.frame));
    }else{
        _pickerAddress.hidden = YES;
        _buttonAbout.hidden = YES;
        _buttonQR.hidden = YES;
        _labelAddress.hidden = YES;
        _buttonDone.frame = CGRectMake(1, CGRectGetMaxY(_pickerMenu.frame), _width - 2, _height - CGRectGetMaxY(_pickerMenu.frame));
    }
}
//自定义pickerView中的字体
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if (pickerView == _pickerAddress) {
        UILabel* pickerLabel = (UILabel*)view;
        if (!pickerLabel){
            pickerLabel = [[UILabel alloc] init];
            pickerLabel.adjustsFontSizeToFitWidth = YES;
            [pickerLabel setBackgroundColor:[UIColor clearColor]];
            [pickerLabel setFont:[UIFont systemFontOfSize:15]];
        }
        pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
        return pickerLabel;
    }else{
        UILabel* pickerLabel = (UILabel*)view;
        if (!pickerLabel){
            pickerLabel = [[UILabel alloc] init];
            pickerLabel.adjustsFontSizeToFitWidth = YES;
            [pickerLabel setBackgroundColor:[UIColor clearColor]];
            [pickerLabel setFont:[UIFont systemFontOfSize:20]];
        }
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
        return pickerLabel;
    }
}

- (UIButton*)addButton:(NSString*)title{
    //添加一个按钮
    UIButton * button;
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle: title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:button];
    [button addTarget:self
               action:@selector(onBtn:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}
- (void) addMenu:(NSString*)name withBlk:(id) blk {
    [_controllers addObject:name];
    [_vcNameDict setValue:blk forKey:name];
}
- (void)initVariable{
    _vcNameDict = [[NSMutableDictionary alloc] init];
    _controllers = [[NSMutableArray alloc] init];
    [self addMenu:@"播放demo"     withBlk:^(NSURL* url){return [[KSYPlayerCfgVC alloc]initWithURL:url fileList:nil];} ];
    [self addMenu:@"视频列表"      withBlk:^(NSURL* url){return [[KSYVideoListVC alloc] initWithUrl:url];} ];
    [self addMenu:@"文件格式探测"   withBlk:^(NSURL* url){return [[KSYProberVC alloc]initWithURL:url];} ];
    [self addMenu:@"播放自动化测试" withBlk:^(NSURL* url){return [[KSYMonkeyTestVC alloc] init];} ];
#ifndef KSYPlayer_Demo
    [self addMenu:@"录制播放短视频" withBlk:^(NSURL* url){return [[KSYRecordVC alloc]initWithURL:url];} ];
    [self addMenu:@"推流demo"     withBlk:^(NSURL* url){return [[KSYPresetCfgVC alloc]initWithURL:url];} ];
    [self addMenu:@"极简推流"      withBlk:^(NSURL* url){return [[KSYSimplestStreamerVC alloc] initWithUrl:url];} ];
    [self addMenu:@"半屏推流"      withBlk:^(NSURL* url){return [[KSYHorScreenStreamerVC alloc] initWithUrl:url];} ];
    [self addMenu:@"画笔推流"      withBlk:^(NSURL* url){return [[KSYBrushStreamerVC alloc] initWithUrl:url];} ];
    [self addMenu:@"背景图片推流"   withBlk:^(NSURL* url){return [[KSYBgpStreamerVC alloc] initWithUrl:url];} ];
    [self addMenu:@"录制推流短视频" withBlk:^(NSURL* url){
        KSYPresetCfgVC *preVC = [[KSYPresetCfgVC alloc]initWithURL:url];
        [preVC.cfgView.btn0 setTitle:@"开始录制" forState:UIControlStateNormal];
        preVC.cfgView.btn1.enabled = NO;
        preVC.cfgView.btn3.enabled = NO;
        return preVC;}];
#endif
    [self addMenu: @"网络探测" withBlk:^(NSURL* url){return [[KSYNetTrackerVC alloc]init];}];
}

- (void)initFrame{
    _width  = self.view.frame.size.width;
    _height = self.view.frame.size.height;
    //设置各个空间的fram
    CGFloat textY   = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat btnH    = 30;
    CGFloat btnW   = 80;
    
    _buttonQR.frame = CGRectMake(20, textY + 5, btnW, btnH);
    _buttonAbout.frame = CGRectMake(_width - 20 - btnW, textY + 5, btnW, btnH);
    textY += (btnH+10);
    UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL bLandscape = UIInterfaceOrientationIsLandscape(ori);
    CGFloat textX   = 1;
    CGFloat textWdh = bLandscape ? (_width-4)/2: _width - 2;
    CGRect textRect = CGRectMake(textX, textY, textWdh, btnH);
    _labelMenu.frame = textRect;
    textY += btnH;
    //设置功能列表的picker的frame
    CGFloat adTaHgh = 216.0;
   _pickerMenu.frame = CGRectMake(textX, textY, textWdh, adTaHgh);
    textY += adTaHgh;
    if (bLandscape) {
        textY =_labelMenu.frame.origin.y;
        textX = textWdh+2;
    }
    //设置播放地址的标题frame
    _labelAddress.frame = CGRectMake(textX,  textY, textWdh, btnH);
    textY += btnH;
    //设置地址列表的picker的frame
    _pickerAddress.frame = CGRectMake(textX, textY, textWdh, adTaHgh);
    textY += adTaHgh;
    textY = _pickerAddress.isHidden ? CGRectGetMaxY(_pickerMenu.frame) : textY;
    btnH = _height - textY;
    //设置开始按钮
    _buttonDone.frame = CGRectMake(1, textY, _width,  btnH);
}

- (void)initLiveVCUI{
    //初始化UI控件
    //添加功能菜单和地址列表的picker
    _pickerMenu = [self addPickerView];
    _pickerAddress = [self addPickerView];
    _buttonQR     = [self addButton:@"扫描二维码"];
    _buttonAbout  = [self addButton:@"关于"];
    [self initFrame];
    // reload last choise
    _selectMenuRow = [self loadSelectMenuRow];
    [_pickerMenu selectRow:_selectMenuRow inComponent:0 animated:YES];
    [self pickerView:_pickerMenu didSelectRow:_selectMenuRow inComponent:0];
}

- (IBAction)onBtn:(id)sender {
    if (sender == _buttonQR){
        //进入到扫描二维码的视图
        [self scanQR];
    }
    else if (sender == _buttonAbout){
        NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        //进入帮助页面
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"金山云直播SDK" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        NSString * fmt = @"版本: %@\n"
        @"QQ群: 574179720 \n"
        @"(iOS)https://github.com/ksvc/KSYLive_iOS \n"
        @"(Android)https://github.com/ksvc/KSYLive_Android";
        alert.message = [NSString stringWithFormat:fmt, build];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
    else if(sender == _buttonDone){
        UIViewController* vc = nil;
        NSURL *url = [NSURL URLWithString:_currentSelectUrl];
        NSString *scheme = [url scheme];
        if( ![scheme isEqualToString:@"rtmp"] &&
            ![scheme isEqualToString:@"http"] &&
            ![scheme isEqualToString:@"https"] &&
            ![scheme isEqualToString:@"rtsp"]) {
            NSString * urlStr = [NSString stringWithFormat:@"%@%s%@", NSHomeDirectory(), "/Documents/",_currentSelectUrl];
            url = [NSURL URLWithString:urlStr];
        }
        if (_selectMenuRow >= 0 && _selectMenuRow < _controllers.count) {
            NSString * vcName = _controllers[_selectMenuRow];
            UIViewController* (^creatVCblk)(NSURL* url) = _vcNameDict[vcName];
            vc = creatVCblk( url);
        }
        else {
            NSLog(@"menu error!!");
        }
        if (vc){
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}
- (void)scanQR{
    //扫描二维码
    __weak __typeof(self)wself = self;
    QRViewController *QRview = [[QRViewController alloc]init];
    QRview.getQrCode = ^(NSString *stringQR){
        //扫描完成后显示地址
        NSString *QRUrl = stringQR;
        //得到二维码扫描的地址添加到播放地址的数组中
        if (_type == KSYDemoMenuType_PLAY) {
            [_arrayPlayAddress insertObject:QRUrl atIndex:0];
            _currentSelectUrl = _arrayPlayAddress[0];
        }else if(_type == KSYDemoMenuType_STREAM){
            [_arrayStreamAddress insertObject:QRUrl atIndex:0];
            _currentSelectUrl = _arrayStreamAddress[0];
        }else if(_type == KSYDemoMenuType_RECORD){
            [_arrayRecordFileName insertObject:QRUrl atIndex:0];
            _currentSelectUrl = _arrayRecordFileName[0];
        }
        [_pickerAddress reloadAllComponents];
        [wself dismissViewControllerAnimated:FALSE completion:nil];
    };
    [self presentViewController:QRview animated:YES completion:nil];
}

- (BOOL) shouldAutorotate {
    return YES;
}
#pragma mark - ui rotate
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self initFrame];
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - User default
@synthesize selectMenuRow = _selectMenuRow;
- (void) setSelectMenuRow:(NSInteger)selectMenuRow {
    _selectMenuRow = selectMenuRow;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:selectMenuRow forKey:@"selectMenuRow"];
    [defaults synchronize];
}
- (NSInteger)selectMenuRow {
    return _selectMenuRow;
}
- (NSInteger) loadSelectMenuRow {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _selectMenuRow = [defaults integerForKey:@"selectMenuRow"];
    return _selectMenuRow;
}
@end
