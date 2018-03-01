//
//  SettingViewController.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/12/4.
//  Copyright © 2017年 王旭. All rights reserved.
//


#import "SettingViewController.h"
#import "SettingModel.h"
#import "AppDelegate.h"

@interface SettingViewController ()



@property (weak, nonatomic) IBOutlet UITextField *bufferTimeTextFieldUI;
@property (weak, nonatomic) IBOutlet UITextField *bufferSizeTextFieldUI;
@property (weak, nonatomic) IBOutlet UITextField *prepareTimeoutTextFieldUI;
@property (weak, nonatomic) IBOutlet UITextField *readTimeoutTextFieldUI;
@property (weak, nonatomic) IBOutlet UISwitch *loopPlaySwitchUI;
@property (weak, nonatomic) IBOutlet UISwitch *showDebugLogSwitchUI;
@property (weak, nonatomic) IBOutlet UIButton *confirmConfigeButtonUI;
@property (weak, nonatomic) IBOutlet UIButton *hardDecodeButtonUI;
@property (weak, nonatomic) IBOutlet UIButton *softDecodeButtonUI;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.confirmConfigeButtonUI.layer.cornerRadius = 20;
    [self defaultSettingHandler];
}

- (void)defaultSettingHandler {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    SettingModel *model = delegate.settingModel;
    
    self.bufferTimeTextFieldUI.text = [NSString stringWithFormat:@"%zd", model.bufferTimeMax];
    self.bufferSizeTextFieldUI.text = [NSString stringWithFormat:@"%zd", model.bufferSizeMax];
    self.prepareTimeoutTextFieldUI.text = [NSString stringWithFormat:@"%zd", model.preparetimeOut];
    self.readTimeoutTextFieldUI.text = [NSString stringWithFormat:@"%zd", model.readtimeOut];
    self.loopPlaySwitchUI.on = model.shouldLoop;
    self.showDebugLogSwitchUI.on = model.showDebugLog;
    self.hardDecodeButtonUI.selected = (model.videoDecoderMode == MPMovieVideoDecoderMode_Hardware);
    self.softDecodeButtonUI.selected = (model.videoDecoderMode == MPMovieVideoDecoderMode_Software);
}

//- (IBAction)popBackAction:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (IBAction)confirmButtonAction:(id)sender {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    SettingModel *model = delegate.settingModel;
    model.videoDecoderMode = self.hardDecodeButtonUI.selected ? MPMovieVideoDecoderMode_Hardware : MPMovieVideoDecoderMode_Software;
    model.bufferTimeMax = [[self.bufferTimeTextFieldUI.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] doubleValue];
    model.bufferSizeMax = [[self.bufferSizeTextFieldUI.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] doubleValue];
    model.preparetimeOut = [[self.prepareTimeoutTextFieldUI.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] integerValue];
    model.readtimeOut = [[self.readTimeoutTextFieldUI.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] integerValue];
    model.shouldLoop = self.loopPlaySwitchUI.on;
    model.showDebugLog = self.showDebugLogSwitchUI.on;
    
    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)hardDecodeButtonAction:(id)sender {
    self.hardDecodeButtonUI.selected = YES;
    self.softDecodeButtonUI.selected = NO;
}
- (IBAction)softDecodeButtonAction:(id)sender {
    self.hardDecodeButtonUI.selected = NO;
    self.softDecodeButtonUI.selected = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self hideKeyboard];
}

- (void)hideKeyboard {
    [self.bufferTimeTextFieldUI endEditing:YES];
    [self.bufferSizeTextFieldUI endEditing:YES];
    [self.prepareTimeoutTextFieldUI endEditing:YES];
    [self.readTimeoutTextFieldUI endEditing:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideKeyboard];
}

@end
