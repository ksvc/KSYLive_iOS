//
//  KSYUIBaseViewController.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>
//文件选择器
#import "KSYFileSelector.h"
#import "ZipArchive.h"

@interface KSYUIBaseViewController : UIViewController

@property (nonatomic,strong) UIView *safeAreaView; //适配iphoneX
@property (nonatomic,copy) NSURL *rtmpUrl; //推流地址
@property (nonatomic,strong) NSDictionary *modelSenderDic; //参数配置
@property (nonatomic,strong) KSYFileSelector *fileDownLoadTool; //视频资源下载工具
@property (nonatomic,strong) KSYFileSelector *logoFileDownLoadTool; //logo图片下载
@property (nonatomic,copy) NSString *gpuResourceDir; //GPUResource资源的存储路径
@property (nonatomic,strong) NSArray *filePathArray; //图片的数组
//@property (nonatomic,strong) NSArray *sourceArray; //资源图片数组
@property (nonatomic,strong) NSArray *pictrueNameArray; //静态logo图片

// 将UIImage保存到path对应的文件
+ (void)saveImage:(UIImage *)image to:(NSString*)path;
+ (void)saveImageToPhotosAlbum:(UIImage *)image;
//删除文件,保证保存到相册里面的视频时间是最新的
+ (void)deleteFile:(NSString *)file;

//初始化推流地址
- (id)initWithUrl:(NSURL *)rtmpUrl;
//下载滤镜资源
- (void)downloadGPUResource;
//保存视频到对应的位置
- (void)saveVideoToAlbum: (NSString*) path;
//预览视图的尺寸
- (CGRect)calcPreviewRect:(CGFloat)ratio;

@end
