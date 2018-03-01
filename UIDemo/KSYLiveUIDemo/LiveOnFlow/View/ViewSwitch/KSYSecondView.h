//
//  KSYSecondView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/14.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYTransViewAfterView.h"
#import "KSYSliderVauleChangeView.h"
//返回
typedef void (^returnBlock) (UIButton* sender);

@interface KSYSecondView : KSYTransViewAfterView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

//返回按钮的回调
@property (nonatomic,copy)returnBlock returnBtnBlock;
//二级视图
@property(nonatomic,strong)UICollectionView* secondCollectView;

@property(nonatomic,strong)KSYSliderVauleChangeView *sliderView;

@property (nonatomic,strong) NSArray *voiceArray; //数据来源
@property (nonatomic,strong) NSArray *pictureArray; //图片资源
@property (nonatomic,copy) NSString *selectedTitle;
@property (nonatomic,strong) NSArray *titleArray;

//设置collectionView
- (void)setUpSubView:(NSArray*)titleArray;
//出现视图
- (void)showSecondView;
//布局
- (void)layoutUI ;

@end

