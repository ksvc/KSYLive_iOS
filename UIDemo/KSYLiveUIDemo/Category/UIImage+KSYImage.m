//
//  UIImage+KSYImage.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/6.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "UIImage+KSYImage.h"

@implementation UIImage (image)
+ (instancetype)imageWithOriginalName:(NSString *)imageName
{
    UIImage *selectImage = [UIImage imageNamed:imageName];
    selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return selectImage;
}

/**
 *  校验图片是否为有效的PNG图片
 *
 *  @param imageData 图片文件直接得到的NSData对象
 *
 *  @return 是否为有效的PNG图片
 */
+(BOOL)isValidPNGByImageData:(NSData*)imageData
{
    UIImage* image = [UIImage imageWithData:imageData];
    //第一种情况：通过[UIImage imageWithData:data];直接生成图片时，如果image为nil，那么imageData一定是无效的
    if (image == nil ) {
        
        return NO;
    }
    
    //第二种情况：图片有部分是OK的，但是有部分坏掉了，它将通过第一步校验，那么就要用下面这个方法了。将图片转换成PNG的数据，如果PNG数据能正确生成，那么这个图片就是完整OK的，如果不能，那么说明图片有损坏
    NSData* tempData = UIImagePNGRepresentation(image);
    if (tempData == nil) {
        return NO;
    } else {
        return YES;
    }
}
@end
