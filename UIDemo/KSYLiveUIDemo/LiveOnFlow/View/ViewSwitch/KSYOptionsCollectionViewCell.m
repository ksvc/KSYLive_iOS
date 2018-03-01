//
//  KSYOptionsCollectionViewCell.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2018/1/28.
//  Copyright © 2018年 王旭. All rights reserved.
//

#import "KSYOptionsCollectionViewCell.h"

@implementation KSYOptionsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(KSYPictureAndLabelModel *)model{
    //背景图片
    _backGroundImageView.image = [UIImage imageNamed:model.pictureName];
    //标签名字
    _titleNameLabel.text = [NSString stringWithFormat:@"%@",model.textLabelName];
    
    _backGroundImageView.contentMode = UIViewContentModeScaleToFill;
    
    _model = model;
    // _backGroundImageView.layer.borderWidth = 1;
    
}

@end
