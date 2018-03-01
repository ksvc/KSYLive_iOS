//
//  KSYUIBaseViewController.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYUIBaseViewController.h"
#import "KSYPictureAndLabelModel.h"
//toast
#import "UIView+Toast.h"

#define floatEq(f0,f1) ((f0 - f1 < 0.001)&& (f0 - f1 > -0.001))

@interface KSYUIBaseViewController ()<UIImagePickerControllerDelegate>

@property(nonatomic,strong)NSDictionary *allModelDic;

@end

@implementation KSYUIBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭悬浮窗的通知
    [[NSNotificationCenter defaultCenter]postNotificationName:closeSuspensionBox object:nil];
    [self initWithSafeView];
    [self initCacheData];
    [self DownLoadPictureAndMusic];
    [self downloadGPUResource];
    // Do any additional setup after loading the view.
}
#pragma mark -
#pragma mark - private methods 私有方法
- (void)initWithSafeView {
    self.safeAreaView = [[UIView alloc]init];
    [self.view addSubview:self.safeAreaView];
    
    //适配iphoneX
    [self.safeAreaView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if ([[KSYGetDeviceName getDeviceName] isEqual:@"iPhoneX"]) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
                make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            make.edges.equalTo(self.view);
        }
    }];

}
/**
 加载数据
 */
-(void)initCacheData{
    //初始化模型数据
    YYCache *cache = [YYCache cacheWithName:@"mydb"];
    NSArray* dataArray ;
    KSYPictureAndLabelModel* model;
    
    dataArray = [self.allModelDic valueForKey:@"混响"];
    model= [KSYPictureAndLabelModel modelWithDictionary:dataArray[0]];
    [cache setObject:model forKey:@"混响"];
    
    dataArray = [self.allModelDic valueForKey:@"变声"];
    model = [KSYPictureAndLabelModel modelWithDictionary:dataArray[0]];
    [cache setObject:model forKey:@"变声"];
    
    dataArray = [self.allModelDic valueForKey:@"LOGO"];
    model = [KSYPictureAndLabelModel modelWithDictionary:dataArray[0]];
    [cache setObject:model forKey:@"LOGO"];
    
    dataArray = [self.allModelDic valueForKey:@"背景音乐"];
    model = [KSYPictureAndLabelModel modelWithDictionary:dataArray[0]];
    [cache setObject:model forKey:@"背景音乐"];
    
    dataArray = [self.allModelDic valueForKey:@"美颜"];
    model = [KSYPictureAndLabelModel modelWithDictionary:dataArray[0]];
    [cache setObject:model forKey:@"美颜"];
    
    dataArray = [self.allModelDic valueForKey:@"滤镜"];
    model = [KSYPictureAndLabelModel modelWithDictionary:dataArray[0]];
    [cache setObject:model forKey:@"滤镜"];
    
    dataArray = [self.allModelDic valueForKey:@"贴纸"];
    model = [KSYPictureAndLabelModel modelWithDictionary:dataArray[0]];
    [cache setObject:model forKey:@"贴纸"];
}
/**
 下载背景音乐和图片
 */
- (void)DownLoadPictureAndMusic {
    NSArray *bgmPatternArray  = @[@".mp3", @".m4a", @".aac"];
    _fileDownLoadTool  = [[KSYFileSelector alloc]initWithDir:@"/Documents/bgms/"
                                                   andSuffix:bgmPatternArray];
    //下载背景音乐
    
    self.filePathArray = _fileDownLoadTool.fileList;
    NSLog(@"%@",self.filePathArray);
    if (self.filePathArray.count == 0) {
        NSString *urlStr = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/bgm.aac";
        [_fileDownLoadTool downloadFile:urlStr name:@"bgm.aac" ];
        urlStr = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/test1.mp3";
        [_fileDownLoadTool downloadFile:urlStr name:@"test1.mp3"];
        [_fileDownLoadTool downloadFile:urlStr name:@"test2.mp3"];
        [_fileDownLoadTool downloadFile:urlStr name:@"test3.mp3"];
        
        //self.filePathArray = _fileDownLoadTool.fileList;
        // self.filePathArray = _fileDownLoadTool.fileList;
    }
    
    //下载logo图片
    _logoFileDownLoadTool = [[KSYFileSelector alloc]initWithDir:@"/Documents/logo/"
                                                      andSuffix:@[@".gif", @".png", @".apng"]];
    if (_logoFileDownLoadTool.fileList.count < 1) {
        NSArray *names = @[@"horse.gif"];
        for (NSString *name in names ) {
            NSString *host = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/picture/animateLogo/";
            NSString *url = [host stringByAppendingString:name];
            [_logoFileDownLoadTool downloadFile:url name:name];
        }
    }
}
/**
 下载滤镜资源文件
 */
-(void)downloadGPUResource{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    _gpuResourceDir=[NSHomeDirectory() stringByAppendingString:@"/Documents/GPUResource/"];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:_gpuResourceDir]) {
        [fileManager createDirectoryAtPath:_gpuResourceDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    NSString *zipPath = [_gpuResourceDir stringByAppendingString:@"KSYGPUResource.zip"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        return; // already downloaded
    }
    NSString *zipUrl = @"https://ks3-cn-beijing.ksyun.com/ksy.vcloud.sdk/Ios/KSYLive_iOS_Resource/KSYGPUResource.zip";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSURL *url =[NSURL URLWithString:zipUrl];
        NSData *data =[NSData dataWithContentsOfURL:url];
        [data writeToFile:zipPath atomically:YES];
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        [zipArchive UnzipOpenFile:zipPath ];
        [zipArchive UnzipFileTo:_gpuResourceDir overWrite:YES];
        [zipArchive UnzipCloseFile];
    });
}

- (CGRect) calcPreviewRect:(CGFloat) ratio {
    CGRect previewRect = self.view.frame;
    CGSize sz = previewRect.size;
    CGSize screenSz = [[UIScreen mainScreen] bounds].size;
    CGFloat hgt = MAX(screenSz.height, screenSz.width);
    if (!floatEq(hgt, 812)){
        return previewRect; // not iphoneX
    }
    if (sz.width < sz.height ) { // 竖屏
        previewRect.size.height = sz.width*ratio;
        previewRect.origin.y += (sz.height -previewRect.size.height)/2;
    }
    else { // 横屏
        previewRect.size.width = sz.height*ratio;
        previewRect.origin.x += (sz.width -previewRect.size.width)/2;
    }
    return previewRect;
}

#pragma mark -
#pragma mark - public methods 公有方法

- (id)initWithUrl:(NSURL *)rtmpUrl {
    if (self = [super init]) {
        self.rtmpUrl = rtmpUrl;
    }
    return self;
}

#pragma mark -
#pragma mark - Override 复写方法

#pragma mark -
#pragma mark - getters and setters 设置器和访问器

- (NSArray*)pictrueNameArray {
    if (!_pictrueNameArray) {
        _pictrueNameArray = [[NSArray alloc]initWithObjects:@"ksvc",@"ksvc1",nil];
    }
    return _pictrueNameArray;
}

- (NSDictionary*)allModelDic {
    if (!_allModelDic) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"ArrayResourceList.plist" ofType:nil];
        _allModelDic = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:path]];
    }
    return _allModelDic;
}

//-(NSArray*)sourceArray{
//    if (!_sourceArray) {
//        _sourceArray = @[@"",@"1_xiaoqingxin.png",@"2_liangli.png",@"3_tianmeikeren.png",@"4_huaijiu.png",@"5_landiao.png",@"6_laozhaop.png",@"7_yinghua.png",@"8_yinghua_night.png",@"9_hongrun_night.png",@"10_yangguang_night.png",@"11_hongrun.png",@"12_yangguang.png",@"13_ziran.png"];
//    }
//    return _sourceArray;
//}

/* model 配置直播界面
 * resolutionGroup 对应推流分辨率  liveGroup 对应直播场景、performanceGroup 对应性能模式 collectGroup 对应采集分辨率 videoGroup 对应 视频编码器 audioGroup 对应音频编码器
 */
- (NSDictionary*)modelSenderDic {
    if (!_modelSenderDic) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _modelSenderDic = [NSDictionary dictionaryWithObjectsAndKeys:[defaults objectForKey:@"resolutionGroup"],@"resolutionGroup",[defaults objectForKey:@"liveGroup"],@"liveGroup",[defaults objectForKey:@"performanceGroup"],@"performanceGroup",[defaults objectForKey:@"collectGroup"],@"collectGroup",[defaults objectForKey:@"videoGroup"],@"videoGroup",[defaults objectForKey:@"audioGroup"],@"audioGroup",nil];
    }
    return _modelSenderDic;
}
#pragma mark -
#pragma mark - UITableViewDelegate

#pragma mark -
#pragma mark - CustomDelegate 自定义的代理
// 保存图片的回调事件
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    if (error == nil) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"O(∩_∩)O~~" message:@"图像已保存至手机相册" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"￣へ￣" message:@"图像保存手机相册失败！" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
//保存mp4文件完成时的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo {
    NSString *message;
    if (!error) {
        message = @"Save album Success!";
    }
    else {
        message = @"Failed to Save the Album!";
    }
    [self.view makeToast:message duration:1 position:CSToastPositionCenter];
    // [self toast:message time:3];
}

#pragma mark -
#pragma mark - event response 所有触发的事件响应 按钮、通知、分段控件等

+ (void)saveImage:(UIImage *)image to:(NSString*)path {
    NSString *dir = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
    NSString *file = [dir stringByAppendingPathComponent:path];
    NSData *imageData = UIImagePNGRepresentation(image);
    BOOL ret = [imageData writeToFile:file atomically:YES];
    NSLog(@"write %@ %@", file, ret ? @"OK":@"failed");
}

+ (void)saveImageToPhotosAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)saveVideoToAlbum:(NSString*)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
            SEL onDone = @selector(video:didFinishSavingWithError:contextInfo:);
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, onDone, nil);
        }
    });
}

+ (void)deleteFile:(NSString *)file {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:file]) {
        [fileManager removeItemAtPath:file error:nil];
    }
}
#pragma mark -
#pragma mark - life cycle 视图的生命周期

#pragma mark -
#pragma mark - StatisticsLog 各种页面统计Log

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
