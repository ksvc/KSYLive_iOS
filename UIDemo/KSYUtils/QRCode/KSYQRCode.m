//
//  KSYPlayUrlAndQRCode.m
//  KSYLiveDemo
//
//  Created by zhengWei on 2017/5/25.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYQRCode.h"
#import "AppDelegate.h"
@interface KSYQRCode ()

@end

@implementation KSYQRCode{
    UIButton *_buttonBack;//返回按钮
    UILabel *_labelPlayUrl;//显示二维码对应的地址
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addButton];
    [self drawQrCode];
}


#pragma mark -
#pragma mark - private methods 私有方法
- (void)addButton {
   // self.title = @"拉流地址";
    _labelPlayUrl = [self addLabelWithText:_url textColor:[UIColor whiteColor]];

    //设置导航栏的按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"直播页面返回"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
//    //设置按钮
//    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [settingButton setImage:[UIImage imageNamed:@"直播页面设置"] forState:UIControlStateNormal];
//    [settingButton addTarget:self action:@selector(jumpSetting) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:settingButton];
    UILabel * titleLabel = [[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.text = @"拉流地址";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
         make.top.equalTo(self.view).offset(SafeAreaStatusBarTopHeight);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(SafeAreaStatusBarTopHeight);
        make.size.mas_equalTo(CGSizeMake(100, 44));
    }];
    
    self.view.backgroundColor = [UIColor blackColor];
}

/**
 绘制二维码
 */
- (void)drawQrCode {
    // 1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2. 恢复滤镜的默认属性
    [filter setDefaults];
    // 3. 将字符串转换成NSData
    NSString *urlStr = _url;
    NSData *data = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
    // 4. 通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    // 5. 获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    CGFloat labelX = 20;
    //CGFloat labelY = CGRectGetMaxY(wechatImageView.frame);
    CGFloat labelY = SafeAreaStatusBarTopHeight +44;
    CGFloat labelH = 30;
    CGFloat labelW = [UIScreen mainScreen].bounds.size.width;
    _labelPlayUrl.frame = CGRectMake(labelX, labelY, labelW-40, labelH);
    
    UIImageView *wechatImageView;
    if (self.imageViewOrientation == KSYDeviceOrientationLandscape) {
       wechatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, CGRectGetMaxY(_labelPlayUrl.frame)+10, [UIScreen mainScreen].bounds.size.width - 400, [UIScreen mainScreen].bounds.size.width - 400)];
    }
    else {
       wechatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(_labelPlayUrl.frame)+10, [UIScreen mainScreen].bounds.size.width - 80, [UIScreen mainScreen].bounds.size.width - 80)];
    }
    //重绘二维码,使其显示清晰
    wechatImageView.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
    [self.view addSubview:wechatImageView];
}
/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGColorSpaceRelease(cs);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage * img = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return img;
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
//添加一个左对齐的Label
- (UILabel *)addLabelWithText:(NSString *)text textColor:(UIColor*)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = textColor;
    label.numberOfLines = -1;
    label.text = [NSString stringWithFormat:@" %@",text];
    label.textAlignment = NSTextAlignmentLeft;
    label.adjustsFontSizeToFitWidth = YES;
    label.layer.masksToBounds = YES;
    label.layer.borderWidth   = 1;
    label.layer.borderColor   = [UIColor whiteColor].CGColor;
    label.layer.cornerRadius  = 15;
    [self.view addSubview:label];
    return label;
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等
- (void)onBtn:(id)sender {
    if (sender == _buttonBack) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = 0;
}

#pragma mark -
#pragma mark - life cycle 视图的生命周期

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
