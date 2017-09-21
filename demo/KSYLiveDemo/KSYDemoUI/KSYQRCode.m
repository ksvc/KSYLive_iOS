//
//  KSYPlayUrlAndQRCode.m
//  KSYLiveDemo
//
//  Created by zhengWei on 2017/5/25.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYQRCode.h"

@interface KSYQRCode ()

@end

@implementation KSYQRCode{
    UIButton *_buttonBack;//返回按钮
    UILabel *_labelPlayUrl;//显示二维码对应的地址
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _buttonBack = [self addButton:@"返回"];
    _labelPlayUrl = [self addLabelWithText:_url textColor:[UIColor blueColor]];
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    UIImageView *wechatImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 30, [UIScreen mainScreen].bounds.size.width - 80, [UIScreen mainScreen].bounds.size.width - 80)];
    //重绘二维码,使其显示清晰
    wechatImageView.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:200];
    [self.view addSubview:wechatImageView];
    
    CGFloat labelX = 0;
    CGFloat labelY = CGRectGetMaxY(wechatImageView.frame);
    CGFloat labelH = 30;
    CGFloat labelW = [UIScreen mainScreen].bounds.size.width;
    _labelPlayUrl.frame = CGRectMake(labelX, labelY, labelW, labelH);
    
    CGFloat buttonX = labelX;
    CGFloat buttonY = CGRectGetMaxY(_labelPlayUrl.frame);
    CGFloat buttonH = 30;
    CGFloat buttonW = [UIScreen mainScreen].bounds.size.width;
    _buttonBack.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
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
    label.text = text;
    label.textAlignment = NSTextAlignmentLeft;
    label.adjustsFontSizeToFitWidth = YES;
    label.layer.masksToBounds = YES;
    label.layer.borderWidth   = 1;
    label.layer.borderColor   = [UIColor blackColor].CGColor;
    label.layer.cornerRadius  = 2;
    [self.view addSubview:label];
    return label;
}
- (IBAction)onBtn:(id)sender{
    if (sender == _buttonBack) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
