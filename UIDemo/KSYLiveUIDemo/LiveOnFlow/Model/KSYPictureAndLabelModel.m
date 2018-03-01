//
//  KSYPictureAndLabelModel.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/22.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYPictureAndLabelModel.h"

@implementation KSYPictureAndLabelModel

+ (instancetype)modelWithDictionary:(NSDictionary*)dic {
    KSYPictureAndLabelModel *model = [[KSYPictureAndLabelModel alloc]initWithDictionary:dic];
    return model;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        //标题
        _titleName = [dic objectForKey:@"name"];
        //选中索引
       _selectIndex = [[dic objectForKey:@"selectIndex"] intValue];
        //图片名字
        _pictureName = [dic objectForKey:@"pictureName"];
        //label文本内容
        _textLabelName = [dic objectForKey:@"textLabelName"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.selectIndex forKey:@"selectIndex"];
    [aCoder encodeObject:self.titleName forKey:@"name"];
    [aCoder encodeObject:self.textLabelName forKey:@"textLabelName"];
    [aCoder encodeObject:self.pictureName forKey:@"pictureName"];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.selectIndex = [aDecoder decodeIntForKey:@"selectIndex"];
    self.titleName = [aDecoder decodeObjectForKey:@"name"];
    self.textLabelName = [aDecoder decodeObjectForKey:@"textLabelName"];
    self.pictureName = [aDecoder decodeObjectForKey:@"pictureName"];
    return self;
}

@end
