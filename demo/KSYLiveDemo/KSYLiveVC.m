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
#import "KSYSQLite.h"
#import "KSYDBCreater.h"
#import "KSYPresetCfgVC.h"
#import "KSYRecordVC.h"
#import "KSYNetTrackerVC.h"
#import "KSYSimplestStreamerVC.h"
#import "KSYHorScreenStreamerVC.h"
#import "KSYBrushStreamerVC.h"
#import "KSYBgpStreamerVC.h"
#import "KSYVideoListVC.h"

typedef NS_ENUM(NSInteger, KSYDemoMenuType){
    KSYDemoMenuType_PLAY = 0,                       //播放
    KSYDemoMenuType_STREAM,                       //推流
    KSYDemoMenuType_RECORD,                       //录制
    KSYDemoMenuType_TEST,                              //测试
};

@interface KSYLiveVC ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>{
    //扫描二维码按钮
    UIButton        *_buttonQR;
    //帮助按钮
    UIButton        *_buttonHelp;
    CGFloat         _width;
    CGFloat         _height;
    //功能列表
    UIPickerView *_pickerMenu;
    //地址列表
    UIPickerView *_pickerAddress;
    //执行按钮
    UIButton *_buttonDone;
    //存放控制器栏的多个按钮的名称
    NSArray         *_controllers;
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
    NSInteger selectMenuRow;//初始状态为0
    //当前选中的地址
    NSString *_currentSelectUrl;
}

@end

@implementation KSYLiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KSYDEMO";
    _labelMenu = [self addLabelWithText:@"Demo 功能列表" textColor:[UIColor blueColor]];
    _labelAddress = [self addLabelWithText:@"播放地址列表" textColor:[UIColor blueColor]];
    //添加开始按钮
    _buttonDone = [self addButton:@"开始"];
    selectMenuRow = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    NSString * uuidStr =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *devCode  = [[uuidStr substringToIndex:3] lowercaseString];
    //推流地址
    NSString *streamSrv  = @"rtmp://test.uplive.ks-cdn.com/live";
    NSString *streamUrl      = [ NSString stringWithFormat:@"%@/%@", streamSrv, devCode];
    _arrayStreamAddress = [NSMutableArray arrayWithObjects:streamUrl,nil];
    //推流地址对应的拉流地址
    NSString *streamPlaySrv = @"http://test.hdllive.ks-cdn.com/live";
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
    [KSYDBCreater initDatabase];
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
        selectMenuRow = row;
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
        _buttonHelp.hidden = NO;
        _buttonQR.hidden = NO;
        _labelAddress.hidden = NO;
        _buttonDone.frame = CGRectMake(1, CGRectGetMaxY(_pickerAddress.frame), _width - 2, _height- CGRectGetMaxY(_pickerAddress.frame));
    }else{
        _pickerAddress.hidden = YES;
        _buttonHelp.hidden = YES;
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

- (void)initVariable{
    _width  = self.view.frame.size.width;
    _height = self.view.frame.size.height;
    _controllers = [NSArray arrayWithObjects:
                    @"播放demo",
                    @"视频列表",
                    @"录制播放短视频",
                    @"文件格式探测",
                    @"播放自动化测试 ",
                    @"推流demo",
                    @"极简推流",
                    @"半屏推流",
                    @"画笔推流",
                    @"背景图片推流",
                    @"录制推流短视频",
                    @"网络探测",
                    nil];
}

- (void)initFrame{
    //设置各个空间的fram
    CGFloat textY   = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat btnH    = 30;
    CGFloat btnW   = 80;
    _buttonQR.frame = CGRectMake(20, textY + 5, btnW, btnH);
    _buttonHelp.frame = CGRectMake(_width - 20 - btnW, textY + 5, btnW, btnH);
    
    textY += (btnH+10);
    
    CGFloat textX   = 1;
    CGFloat textWdh = _width - 2;
    CGFloat textHgh = btnH;
    CGRect textRect = CGRectMake(textX, textY, textWdh, textHgh);
    _labelMenu.frame = textRect;
    
    //设置功能列表的picker的frame
    CGFloat adTaHgh = (_height  -  CGRectGetMaxY(_labelMenu.frame)) / 2 - textHgh;
   _pickerMenu.frame = CGRectMake(textX, CGRectGetMaxY(_labelMenu.frame), textWdh, adTaHgh);
    
    //设置播放地址的标题frame
    _labelAddress.frame = CGRectMake(textX,  CGRectGetMaxY(_pickerMenu.frame), textWdh, textHgh);
    
    //设置地址列表的picker的frame
    _pickerAddress.frame = CGRectMake(textX, CGRectGetMaxY(_labelAddress.frame), textWdh, adTaHgh);
    
    //设置开始按钮
    _buttonDone = [self addButton:@"开始"];
    _buttonDone.frame = CGRectMake(textX, CGRectGetMaxY(_pickerAddress.frame), textWdh,  btnH);
}

- (void)initLiveVCUI{
    //初始化UI控件
    //添加功能菜单和地址列表的picker
    _pickerMenu = [self addPickerView];
    _pickerAddress = [self addPickerView];
    _buttonQR     = [self addButton:@"扫描二维码"];
    _buttonHelp  = [self addButton:@"帮助"];
    [self initFrame];
}

- (IBAction)onBtn:(id)sender {
    if (sender == _buttonQR){
        //进入到扫描二维码的视图
        [self scanQR];
    }
    else if (sender == _buttonHelp){
        //进入帮助页面
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"金山云直播SDK网址" message:@"(iOS)https://github.com/ksvc/KSYLive_iOS\n(Android)https://github.com/ksvc/KSYLive_Android" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
   }else if(sender == _buttonDone){
        UIViewController* vc = nil;
        NSURL *url = [NSURL URLWithString:_currentSelectUrl];
        NSString *scheme = [url scheme];
        if(![scheme isEqualToString:@"rtmp"] &&
                ![scheme isEqualToString:@"http"] &&
                ![scheme isEqualToString:@"https"] &&
                ![scheme isEqualToString:@"rtsp"])
        {
            _currentSelectUrl = [NSString stringWithFormat:@"%@%s%@", NSHomeDirectory(), "/Documents/",_currentSelectUrl];
            url = [NSURL URLWithString:_currentSelectUrl];
        }

        if (selectMenuRow == 0) {
            //播放Demo
            vc = [[KSYPlayerCfgVC alloc]initWithURL:url fileList:nil];
        }else if (selectMenuRow == 1){
            //视频列表
            vc = [[KSYVideoListVC alloc] initWithUrl:_currentSelectUrl];
        }else if(selectMenuRow == 2){
            //录制播放短视频
            vc = [[KSYRecordVC alloc]initWithURL:url];
        }
        else if (selectMenuRow == 3){
            //文件格式探测
            vc = [[KSYProberVC alloc]initWithURL:url];
        }
        else if (selectMenuRow == 4){
            //自动化测试
            vc = [[KSYMonkeyTestVC alloc] init];
        }
        else if(selectMenuRow == 5){
            //推流Demo,传入推流地址及拉流地址
            vc = [[KSYPresetCfgVC alloc]initWithURL:_currentSelectUrl];
        }
        else if(selectMenuRow == 6){
            //极简推流
            vc  = [[KSYSimplestStreamerVC alloc] initWithUrl:_currentSelectUrl];
        }
        else if(selectMenuRow == 7){
            //半屏推流
            vc = [[KSYHorScreenStreamerVC alloc] initWithUrl:_currentSelectUrl];
        }
        else if(selectMenuRow == 8){
            //半屏推流
            vc = [[KSYBrushStreamerVC alloc] initWithUrl:_currentSelectUrl];
        }
        else if(selectMenuRow == 9){
            //背景图片推流
            vc = [[KSYBgpStreamerVC alloc] initWithUrl:_currentSelectUrl];
        }
        else if(selectMenuRow == 10){
            //录制推流短视频
            KSYPresetCfgVC *preVC = [[KSYPresetCfgVC alloc]initWithURL:_currentSelectUrl];
            [preVC.cfgView.btn0 setTitle:@"开始录制" forState:UIControlStateNormal];
            preVC.cfgView.btn1.enabled = NO;
            preVC.cfgView.btn3.enabled = NO;
            vc = preVC;
        }
        else if(selectMenuRow == 11){
            //网络连通性探测
            vc = [[KSYNetTrackerVC alloc]init];
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
@end
