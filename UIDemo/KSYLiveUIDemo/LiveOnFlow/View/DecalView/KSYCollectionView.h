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

@property(nonatomic,strong)UIButton *completeEditButton;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy)void(^DEBlock)(NSString *imgName);

@property (nonatomic, copy)void(^completeBlock)(UIButton *button);



@end

