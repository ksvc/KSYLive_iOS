//
//  KSYDecalView.h
//  demo
//
//  Created by iVermisseDich on 2017/5/19.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * 贴纸类型
 */
typedef NS_ENUM(NSInteger, DecalType){
    DecalType_Sticker,      // 贴图
    DecalType_SubTitle      // 字幕
};

@interface KSYDecalView : UIImageView

#pragma mark - UI
@property (nonatomic) UIButton *closeBtn;
@property (nonatomic) UIImageView *dragBtn;

#pragma mark -
@property (nonatomic, assign) DecalType type;
// 选中后出现边框
@property (nonatomic, assign, getter=isSelected) BOOL select;

#pragma mark - Functions

/**
 创建一中类型的贴纸
 @param image 贴图图片
 @param type 默认为贴图
 */
- (instancetype)initWithImage:(UIImage *)image Type:(DecalType)type;


/**
 根据气泡类型，设置字符显示区域
 （需要用户根据自己的气泡设置显示区域）
 @param name 气泡名称
 */
- (void)calcInputRectWithImgName:(NSString *)name;

- (void)close:(id)sender;


#pragma mark - Reserved

@property (nonatomic, assign) CGFloat oriScale;

@property (nonatomic, assign) CGAffineTransform oriTransform;

@end
