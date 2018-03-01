//
//  VideoCollectionHeaderView.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "VideoCollectionHeaderView.h"
#import "VideoModel.h"
#import "UIImageView+WebCache.h"

@interface VideoCollectionHeaderView ()
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLab;
@end

@implementation VideoCollectionHeaderView

- (IBAction)tapAction:(id)sender {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)configeVideoModel:(VideoModel *)videoModel {
    self.descriptionLab.text = videoModel.VideoTitle;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:videoModel.CoverURL.firstObject] placeholderImage:[UIImage imageNamed:@""]];
}

@end
