//
//  KSYPictureAndLabelCell.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYPictureAndLabelCell.h"

@implementation KSYPictureAndLabelCell

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
