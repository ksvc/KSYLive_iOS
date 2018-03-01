//
//  KSYOptionsCollectionViewCell.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2018/1/28.
//  Copyright © 2018年 王旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYPictureAndLabelModel.h"

@interface KSYOptionsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;


@property(nonatomic,strong)KSYPictureAndLabelModel* model;

@end
