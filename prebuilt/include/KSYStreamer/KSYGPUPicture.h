//
//  KSYGPUPicture.h
//  KSYStreamer
//
//  Created by ksyun on 16/6/1.
//  Copyright © 2016年 yiqian. All rights reserved.
//

#import <GPUImage/GPUImage.h>

/** 图片读入类
 
 1. 继承自GPUImagePicture
 2. 增加通过指定图片名称载入图片的功能
 3. 图片搜索顺序如下  mainBundle  ->  mainBundle中的 KSYGPUResource.bundle -> Documents/GPUResource

 顺序在以上路径中查找是否有指定名称的图片
 */
@interface KSYGPUPicture: GPUImagePicture

- (id)initWithImageName:(NSString *)name;

@end
