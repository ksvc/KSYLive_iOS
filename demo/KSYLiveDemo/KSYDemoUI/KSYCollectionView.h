//
//  ViewController.h
//  ALCollectionViewDemo
//
//  Created by iVermisseDich on 2017/7/18.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSYUIView.h"

@interface KSYCollectionView : KSYUIView

@property UIButton* btn0;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy)void(^DEBlock)(NSString *imgName);

@end

