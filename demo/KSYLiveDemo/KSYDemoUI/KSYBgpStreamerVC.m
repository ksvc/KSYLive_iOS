//
//  KSYBgpStreamerVC.m
//  KSYLiveDemo
//
//  Created by 江东 on 17/4/21.
//  Copyright © 2017年 qyvideo. All rights reserved.
//

#import "KSYBgpStreamerVC.h"
#import "KSYUIView.h"
#import <libksygpulive/KSYGPUStreamerKit+bgp.h>

@interface KSYBgpStreamerVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIButton *selectFileBtn;//选择背景图片
}
@end

@implementation KSYBgpStreamerVC
- (id)initWithUrl:(NSURL *)rtmpUrl {
    if (self = [super initWithUrl:rtmpUrl]) {
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupUI {
    [super setupUI];
    // top view
    selectFileBtn = [self.ctrlView addButton:@"选择背景图片"];
    [self layoutUI];
}

- (void)layoutUI {
    [super layoutUI];
    self.ctrlView.yPos = CGRectGetMaxY(self.quitBtn.frame) + 4;
    UIView * v = [[UIView alloc] init];
    [self.ctrlView putRow3:selectFileBtn and:v and:v];
}

- (void)onBtn:(UIButton *)btn {
    [super onBtn:btn];
    if (btn == selectFileBtn){
        [self onSelectFile];
    }
}

- (void)onSelectFile {
    //从相册获取照片
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate methods
-(void)imagePickerController:(UIImagePickerController *)picker
       didFinishPickingImage:(UIImage *)image
                 editingInfo:(NSDictionary *)editingInfo {
    if(image != nil) {
        [self.kit updateBgpImage:image];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)onCapture {
    if ( ! self.kit.bgPic){
        UIImage* img = [UIImage imageNamed:@"bgp"];
        if (img) {
            [self.kit updateBgpImage:img];
        }
    }
    self.captureBtn.selected = !self.captureBtn.selected;
    if (self.captureBtn.selected){
        [self.kit startBgpPreview:self.bgView];
    }
    else {
        [self.kit stopPreview];
    }
    self.profilePicker.hidden = self.captureBtn.selected;
}

- (void)onStream {
    if (self.kit.streamerBase.streamState == KSYStreamStateIdle ||
        self.kit.streamerBase.streamState == KSYStreamStateError) {
        [self.kit startBgpStream:self.url];
    }
    else { //停止推流
        [self.kit stopBgpStream];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
