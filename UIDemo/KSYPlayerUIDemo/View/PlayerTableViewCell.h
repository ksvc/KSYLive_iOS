//
//  PlayerTableViewCell.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoModel;

@interface PlayerTableViewCell : UITableViewCell

- (void)configeWithVideoModel:(VideoModel *)videoModel;

@end
