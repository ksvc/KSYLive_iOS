//
//  VideoCollectionViewCell.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "VideoCollectionViewCell.h"
#import "VideoModel.h"
#import "UIImageView+WebCache.h"

@interface VideoCollectionViewCell ()
@property (nonatomic, strong) VideoModel *videoModel;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLab;
@end

@implementation VideoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configeWithVideoModel:(VideoModel *)videoModel {
    self.videoModel = videoModel;
    
    self.descriptionLab.text = videoModel.VideoTitle;
    //找到背景图片设置为空的地方
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:videoModel.CoverURL.lastObject] placeholderImage:[UIImage imageNamed:@""]];
}

@end
