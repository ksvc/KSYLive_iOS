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
#import "KSYBgpStreamerVC.h"
#import "KSYVideoListVC.h"

@interface KSYLiveVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UITextField     *_textFiled;
    UIButton        *_buttonQR;
    UIButton        *_buttonClose;
    UITableView     *_ctrTableView;
    UITableView     *_addressTable;
    NSArray         *_controllers;
    CGFloat         _width;
    CGFloat         _height;
    NSMutableArray  *_addressMulArray;
}

@end

@implementation KSYLiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KSYDEMO";
    self.view.backgroundColor = [UIColor whiteColor];
    _addressMulArray = [NSMutableArray new];
    NSString * uuidStr =[[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *devCode  = [[uuidStr substringToIndex:3] lowercaseString];
    NSString *streamSrv  = @"rtmp://test.uplive.ks-cdn.com/live";
    NSString *streamUrl      = [ NSString stringWithFormat:@"%@/%@", streamSrv, devCode];
    NSString *playUrl  = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
    NSString *recordFile = @"RecordAv.mp4";
    [_addressMulArray addObject:streamUrl];
    [_addressMulArray addObject:playUrl];
    [_addressMulArray addObject:recordFile];
    [self initVariable];
    [self initLiveVCUI];
    [KSYDBCreater initDatabase];
}

- (UITextField *)addTextField{
    UITextField *text = [[UITextField alloc]init];
    text.delegate     = self;
    [self.view addSubview:text];
    text.layer.masksToBounds = YES;
    text.layer.borderWidth   = 1;
    text.layer.borderColor   = [UIColor blackColor].CGColor;
    text.layer.cornerRadius  = 2;
    return text;
}

- (UITableView *)addTableView{
    UITableView *teble = [[UITableView alloc]init];
    teble.layer.masksToBounds = YES;
    teble.layer.borderColor   = [UIColor blackColor].CGColor;
    teble.layer.borderWidth   = 1;
    teble.delegate   = self;
    teble.dataSource = self;
    [self.view addSubview:teble];
    return teble;
}

- (UIButton*)addButton:(NSString*)title{
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
                    @"文件格式探测",
                    @"播放自动化测试 ",
                    @"网络探测",
                    @"录制推流短视频",
                    @"录制播放短视频",
                    @"推流demo",
                    @"极简推流",
                    @"半屏推流",
                    @"背景图片推流",
                    @"视频列表",
                    nil];
}


- (void)initFrame{
    CGFloat textY   = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat btnH    = 30;
    CGFloat btnW    = 80;
    _buttonQR.frame = CGRectMake(20, textY+5, btnW, btnH);
    _buttonClose.frame = CGRectMake(_width-20-btnW, textY+5, btnW, btnH);
    
    textY += (btnH+10);
    
    CGFloat textX   = 1;
    CGFloat textWdh = _width-2;
    CGFloat textHgh = 30;
    CGRect textRect = CGRectMake(textX, textY, textWdh, textHgh);
    _textFiled.frame = textRect;
    
    CGFloat adTaY   = textY + textHgh;
    CGFloat adTaHgh = _height / 2 - adTaY;
    CGRect addressTableRect = CGRectMake(textX, adTaY, textWdh, adTaHgh);
    _addressTable.frame = addressTableRect;
    
    CGFloat tableX   = 1;
    CGFloat tableY   = _height / 2;
    CGFloat tableWdh = _width  - 2;
    CGFloat tableHgh = _height / 2;
    CGRect tableRect = CGRectMake(tableX, tableY, tableWdh, tableHgh);
    _ctrTableView.frame = tableRect;
}
- (void)initLiveVCUI{
    _textFiled    = [self addTextField];
    _addressTable = [self addTableView];
    _ctrTableView = [self addTableView];
    _buttonQR     = [self addButton:@"扫描二维码"];
    _buttonClose  = [self addButton:@"关闭键盘"];
    [self initFrame];
}

- (IBAction)onBtn:(id)sender {
    if (sender == _buttonQR){
        [self scanQR];
    }
    else if (sender == _buttonClose){
        [self closeKeyBoard];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _ctrTableView) {
        return 1;
    }else if(tableView == _addressTable){
        return 3;
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _ctrTableView) {
        return _controllers.count;
    }else if(tableView == _addressTable){
        return 1;
    }else{
        return 0;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identify"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"identify"];
    }
    if (tableView == _ctrTableView) {
        cell.textLabel.text = _controllers[indexPath.row];
    }else if(tableView == _addressTable){
        if (indexPath.section == 0) {
            cell.textLabel.text = _addressMulArray[indexPath.section];
        }
        else if (indexPath.section == 1){
            cell.textLabel.text = _addressMulArray[indexPath.section];
        }
        else if (indexPath.section == 2){
            cell.textLabel.text = _addressMulArray[indexPath.section];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        UIView *cellView = [[UIView alloc]initWithFrame:cell.frame];
        cellView.backgroundColor = [UIColor grayColor];
        cell.backgroundView = cellView;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _ctrTableView) {
        if (_textFiled.text.length > 0) {
            NSLog(@"url:%@",_textFiled.text);
            NSString *dir;
            NSURL *url = [NSURL URLWithString:_textFiled.text];
            NSString *scheme = [url scheme];
            if(![scheme isEqualToString:@"rtmp"] &&
                ![scheme isEqualToString:@"http"] &&
                ![scheme isEqualToString:@"https"] &&
                ![scheme isEqualToString:@"rtsp"]){
                dir = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
                url = [NSURL URLWithString:[dir stringByAppendingPathComponent:_textFiled.text]];
            }
            UIViewController* vc = nil;
            if (indexPath.row == 0) {
                vc = [[KSYPlayerCfgVC alloc]initWithURL:url fileList:nil];
            }else if (indexPath.row == 1){
                vc = [[KSYProberVC alloc]initWithURL:url];
            }else if(indexPath.row == 2){
                vc = [[KSYMonkeyTestVC alloc] init];
            }
            else if (indexPath.row == 3){
                vc = [[KSYNetTrackerVC alloc]init];
            }
            else if (indexPath.row == 4){
                KSYPresetCfgVC *preVC = [[KSYPresetCfgVC alloc]initWithURL:[dir stringByAppendingPathComponent:_textFiled.text]];
                [preVC.cfgView.btn0 setTitle:@"开始录制" forState:UIControlStateNormal];
                preVC.cfgView.btn1.enabled = NO;
                preVC.cfgView.btn3.enabled = NO;
                vc = preVC;
            }
            else if(indexPath.row == 5){
                vc = [[KSYRecordVC alloc]initWithURL:url];
            }
            else if(indexPath.row == 6){
                vc = [[KSYPresetCfgVC alloc]initWithURL:_textFiled.text];
            }
            else if(indexPath.row == 7){
                vc = [[KSYSimplestStreamerVC alloc] initWithUrl:_textFiled.text];
            }
            else if(indexPath.row == 8){
                vc = [[KSYHorScreenStreamerVC alloc] initWithUrl:_textFiled.text];
            }
            else if(indexPath.row == 9){
                vc = [[KSYBgpStreamerVC alloc] initWithUrl:_textFiled.text];
            }
            else if(indexPath.row == 10){
                vc = [[KSYVideoListVC alloc] init];
            }
            if (vc){
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
    }else if(tableView == _addressTable){
        if (indexPath.section == 0) {
            _textFiled.text = _addressMulArray[indexPath.section];
        }
        else if (indexPath.section == 1){
            _textFiled.text = _addressMulArray[indexPath.section];
        }
        else if (indexPath.section == 2){
            _textFiled.text = _addressMulArray[indexPath.section];
        }
        [_textFiled resignFirstResponder];
    }
}
#pragma mark 返回每组头标题名称
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView == _ctrTableView) {
        return @"控制器栏";
    }else if (tableView == _addressTable){
        if (section == 0) {
            return @"推流地址";
        }else if (section == 1){
            return @"拉流地址";
        }else if (section == 2){
            return @"录制文件";
        }
        
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (void)closeKeyBoard{
    [_textFiled resignFirstResponder];
}
- (void)scanQR{
    __weak __typeof(self)wself = self;
    QRViewController *QRview = [[QRViewController alloc]init];
    QRview.getQrCode = ^(NSString *stringQR){
        [wself showAddress:stringQR];
    };
    [self presentViewController:QRview animated:YES completion:nil];
}

- (void)showAddress:(NSString *)str{
    _textFiled.text = str;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_textFiled resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //    [self myReloadData];
}

- (void)myReloadData{
    NSArray *addressArray = [[KSYSQLite sharedInstance] getAddress];
    for(NSDictionary *dic in addressArray){
        NSString *address = [dic objectForKey:@"address"];
        [_addressMulArray addObject:address];
    }
    [_addressTable reloadData];
}

@end
