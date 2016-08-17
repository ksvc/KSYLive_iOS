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
#import "KSYSQLite.h"
#import "KSYDBCreater.h"
#import "KSYPresetCfgVC.h"
@interface KSYLiveVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    UITextField     *_textFiled;
    UIButton        *_buttonQR;
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
    NSString *devCode  = [ [[[UIDevice currentDevice] identifierForVendor] UUIDString] substringToIndex:3];
    NSString *streamSrv  = @"rtmp://test.uplive.ksyun.com/live";
    NSString *playSrv  = @"rtmp://test.rtmplive.ks-cdn.com/live";
    NSString *streamUrl      = [ NSString stringWithFormat:@"%@/%@", streamSrv, devCode];
    NSString *playUrl      = [ NSString stringWithFormat:@"%@/%@", playSrv, devCode];
    [_addressMulArray addObject:streamUrl];
    [_addressMulArray addObject:playUrl];
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
- (UITableView *)addAddressTable{
    UITableView *table      = [self addTableView];
    return table;
}
- (UIBarButtonItem *)addBarButtonItemWithTitle:(NSString *)title action:(SEL)action{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, 30)];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.layer.masksToBounds = YES;
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.borderColor   = [UIColor blackColor].CGColor;
    button.layer.borderWidth   = 1;
    button.layer.cornerRadius  = 5;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc]initWithCustomView:button];
    return barButton;
}
- (void)addLeftNavigationBarButton{
    self.navigationItem.leftBarButtonItem = [self addBarButtonItemWithTitle:@"关闭键盘" action:@selector(closeKeyBoard)];
}
- (void)addRightNavigationBarButton{
    
    self.navigationItem.rightBarButtonItem = [self addBarButtonItemWithTitle:@"扫描二维码" action:@selector(scanQR)];
    
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
- (void)initVariable{
    _width  = self.view.frame.size.width;
    _height = self.view.frame.size.height;
    _controllers = [NSArray arrayWithObjects:@"KSYPlayerVC",@"推流demo", @"文件格式探测", nil];
}


- (void)initFrame{
    
    CGFloat textX   = 1;
    CGFloat textY   = CGRectGetMaxY(self.navigationController.navigationBar.frame);
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
    _addressTable = [self addAddressTable];
    _ctrTableView = [self addTableView];
    [self addLeftNavigationBarButton];
    [self addRightNavigationBarButton];
    [self initFrame];
    //    [self myReloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _ctrTableView) {
        return 1;
    }else if(tableView == _addressTable){
        return 2;
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
            NSURL *url = [NSURL URLWithString:_textFiled.text];
            UIViewController* vc = nil;
            if (indexPath.row == 0) {
                vc = [[KSYPlayerVC alloc]initWithURL:url];
            }else if (indexPath.row == 1){
                vc = [[KSYPresetCfgVC alloc]initWithURL:_textFiled.text];
            }else if (indexPath.row == 2){
                vc = [[KSYProberVC alloc]initWithURL:url];
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
        }
        
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (void)closeKeyBoard{
    [_textFiled resignFirstResponder];
    //    [[KSYSQLite sharedInstance] insertAddress:_textFiled.text];
}
- (void)scanQR{
    
    __weak __typeof(self)wself = self;
    
    QRViewController *QRview = [[QRViewController alloc]init];
    QRview.getQrCode = ^(NSString *stringQR){
        [wself showAddress:stringQR];
    };
    
    [self.navigationController pushViewController:QRview animated:YES];
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
