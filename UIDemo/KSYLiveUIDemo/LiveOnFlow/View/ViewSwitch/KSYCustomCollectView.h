//
//  KSYCustomCollectView.h
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/13.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYTransViewAfterView.h"

#import "KSYSecondView.h"

typedef void(^collectViewBlock)(NSString *title,BOOL muteState);


@interface KSYCustomCollectView : KSYTransViewAfterView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/**
 九宫格view
 */
@property(nonatomic,strong)UICollectionView *scratchableLatexView;

@property(nonatomic,strong)KSYSecondView *secondView;
/**
 展现视图
 */
-(void)showView;

- (void)layoutSubviews;

@property(nonatomic,copy)collectViewBlock titleBlock;

//静音的状态
@property(nonatomic,assign)BOOL muteState;
@property(nonatomic,assign)BOOL mirrorState;
//音量和音调
@property(nonatomic,assign)float volumnSliderValue; //音量
@property(nonatomic,assign)float voiceSliderValue; //音调

@end
