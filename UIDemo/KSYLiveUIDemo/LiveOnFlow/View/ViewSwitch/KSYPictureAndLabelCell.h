//
//  KSYPictureAndLabelCell.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/15.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "KSYPictureAndLabelModel.h"

@interface KSYPictureAndLabelCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectBgImage;

@property(nonatomic,strong)KSYPictureAndLabelModel* model;

@end
