//
//  CollectionCell.m
//  demo
//
//  Created by iVermisseDich on 2017/5/19.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYCollectionCell.h"

@interface KSYCollectionCell()

@property(nonatomic,weak)UIImageView *imageView;

@end


@implementation KSYCollectionCell

-(UIImageView *)imageView
{
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        _imageView = imageView;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return _imageView;
}

-(void)setName:(NSString *)name{
    _name = name;
    self.imageView.image = [UIImage imageNamed:_name];
}

@end
