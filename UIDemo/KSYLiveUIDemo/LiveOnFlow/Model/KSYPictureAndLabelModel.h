//
//  KSYPictureAndLabelModel.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/22.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSYPictureAndLabelModel : NSObject<NSCoding>

//标题名字
@property(nonatomic,copy)NSString *titleName;
//图片名字  ios
@property(nonatomic,copy)NSString *pictureName;
//label文本内容
@property(nonatomic,copy)NSString *textLabelName;
//选中索引
@property(nonatomic,assign)int selectIndex;

+(KSYPictureAndLabelModel*)modelWithDictionary:(NSDictionary*)dic;

-(instancetype)initWithDictionary:(NSDictionary*)dic;

@end
