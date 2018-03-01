//
//  KSYSecondView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/14.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYSecondView.h"
#import "KSYPictureAndLabelCell.h"
//自定义的按钮
#import "KSYSelectBottomButton.h"
#import "KSYPictureAndLabelModel.h"
//滑块视图
#import "KSYSliderVauleChangeView.h"
#import "HMSegmentedControl.h"

@interface KSYSecondView()<KSYSelectBottomButtonDelegate>

@property (nonatomic,assign) NSInteger selectItemIndex; // 选中的索引
@property (nonatomic,assign) NSInteger lastSelectItemIndex;

@property (nonatomic,strong) NSDictionary *allModelDic; // 数据源
@property (nonatomic,strong) NSMutableArray* dataArray; // 数组
@property (nonatomic,strong) UIView *collectionSuperView;
@property (nonatomic,strong) HMSegmentedControl *segmentedControl;

@end

@implementation KSYSecondView

- (NSDictionary*)allModelDic {
    if (!_allModelDic) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"ArrayResourceList.plist" ofType:nil];
        _allModelDic = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:path]];
    }
    return _allModelDic;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0,KSYScreenHeight-180 - SafeAreaBottomHeight,KSYScreenWidth , 180)];
    if (self) {
    }
    return self;
}

- (void)layoutUI {
    
    self.frame = CGRectMake(0,KSYScreenHeight-180 - SafeAreaBottomHeight,KSYScreenWidth , 180);
    
    [self.sliderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(50);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(@230);
    }];
        
    [self.secondCollectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.segmentedControl.mas_top);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(@130);
        [self.secondCollectView reloadData];
    }];
}

- (void)segmentChangedValue:(HMSegmentedControl *)control {

    self.selectedTitle = self.titleArray[control.selectedSegmentIndex];
    self.translateType = KSYTranslateTypeSlide;
    [self transformDirection:NO withCurrentView:self.sliderView withLastView:self.collectionSuperView];
    
    //选中的cell的索引
    YYCache *cache = [YYCache cacheWithName:@"mydb"];
    KSYPictureAndLabelModel *model = (KSYPictureAndLabelModel*)[cache objectForKey:self.selectedTitle];
    self.selectItemIndex = model.selectIndex;
    self.lastSelectItemIndex = model.selectIndex;
    
    self.dataArray = [[NSMutableArray alloc]init];
    NSArray *dataArray = [self.allModelDic valueForKey:self.selectedTitle];
    
    [dataArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL* stop){
        NSDictionary* dic = obj;
        KSYPictureAndLabelModel* model = [KSYPictureAndLabelModel modelWithDictionary:dic];
        [self.dataArray addObject:model];
        //刷新数据源
        [self.secondCollectView reloadData];
    }];
}

- (void)setUpSubView:(NSArray*)titleArray {
    self.titleArray = titleArray;
    KSYWeakSelf;
    //底部切换视图
    self.segmentedControl = [[HMSegmentedControl alloc]init];
    self.segmentedControl.sectionTitles = titleArray;
    //    self.segmentedControl.backgroundColor = [UIColor colorWithHexString:@"#08080b"];
    self.segmentedControl.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorColor = [UIColor redColor];
    self.segmentedControl.selectionIndicatorBoxColor = [UIColor redColor];
    self.segmentedControl.titleFormatter = ^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = nil;
        //if (selected) {
        attString = [[NSAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
        //        }
        //        else {
        //            attString = [[NSAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#9b9b9b"],NSFontAttributeName:[UIFont systemFontOfSize:17]}];
        //        }
        return attString;
    };
    [self.segmentedControl addTarget:self action:@selector(segmentChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.segmentedControl];
    
    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(@50);
    }];
    [self.segmentedControl setSelectedSegmentIndex:0 animated:YES];
    
    self.sliderView = [[KSYSliderVauleChangeView alloc]init];
    self.sliderView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    
    self.sliderView.block  = ^(UIButton *sender) {
        
        [weakSelf transformDirection:NO withCurrentView:weakSelf.sliderView withLastView:weakSelf.collectionSuperView];
    };
    [self addSubview:self.sliderView];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(50);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(@230);
    }];
    self.sliderView.alpha = 0;
    
    //collectionSuperView
    self.collectionSuperView = [[UIView alloc]init];
    self.collectionSuperView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    [self addSubview:self.collectionSuperView];
    
    //collectionView
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.secondCollectView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.secondCollectView registerNib:[UINib nibWithNibName:@"KSYPictureAndLabelCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.secondCollectView.delegate = self;
    self.secondCollectView.dataSource = self;
    self.secondCollectView.allowsMultipleSelection = NO;
    self.secondCollectView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    [self.collectionSuperView addSubview:self.secondCollectView];
    [self.collectionSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.segmentedControl.mas_top);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(@130);
    }];
    
    //collectionView
    [self.secondCollectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.segmentedControl.mas_top);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(@130);
        [self.secondCollectView reloadData];
    }];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"cell";
    KSYPictureAndLabelCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backGroundImageView.layer.borderWidth = 1;
    cell.model = self.dataArray[indexPath.item];
    
    if (indexPath.item == self.selectItemIndex){
        self.lastSelectItemIndex = self.selectItemIndex;
        cell.backGroundImageView.layer.borderColor = [UIColor redColor].CGColor;
        if ([self.selectedTitle isEqualToString:@"背景音乐"]||[self.selectedTitle isEqualToString:@"美颜"]) {
            cell.selectBgImage.image = [UIImage imageNamed:@"选中"];
        }
    }
    else{
        cell.backGroundImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.selectBgImage.image = nil;
    }
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(70,90);
}


//设置每个item横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
         if ([self.selectedTitle isEqualToString:@"美颜"]||[self.selectedTitle isEqualToString:@"背景音乐"]||[self.selectedTitle isEqualToString:@"LOGO"])
        {
            return UIEdgeInsetsMake(10,(KSYScreenWidth-70*4)/5,10,(KSYScreenWidth-70*4)/5);
        }
        else if ([self.selectedTitle isEqualToString:@"变声"]||[self.selectedTitle isEqualToString:@"混响"]||[self.selectedTitle isEqualToString:@"LOGO"]){
            //判断是否大于5个按钮的长度
            if (KSYScreenWidth > 350) {
                return UIEdgeInsetsMake(10,(KSYScreenWidth-70*5)/6,10,(KSYScreenWidth-70*5)/6);
            }
            else {
                 return UIEdgeInsetsMake(10,10,10,10);
            }
           
        }
         return UIEdgeInsetsMake(10,10,10,10);
}

////设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if ([self.selectedTitle isEqualToString:@"美颜"]||[self.selectedTitle isEqualToString:@"背景音乐"]||[self.selectedTitle isEqualToString:@"LOGO"])
    {
         return (KSYScreenWidth-70*4)/5;
    }
    else if ([self.selectedTitle isEqualToString:@"变声"]||[self.selectedTitle isEqualToString:@"混响"]||[self.selectedTitle isEqualToString:@"LOGO"]){
        if (KSYScreenWidth > 350) {
            return (KSYScreenWidth-70*5)/6;
        }
        else {
            return 10;
        }
    }
    return 10;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectItemIndex = indexPath.item;
    
    //如果是再次选中 ，进入下一界面
    if (self.selectItemIndex == self.lastSelectItemIndex) {
        
        if ([self.selectedTitle isEqualToString:@"美颜"]) {
            //隐藏音量和音调
            self.sliderView.alpha = 1;
            self.sliderView.nameTitle = self.selectedTitle;
            self.sliderView.voiceSlider.hidden = YES;
            self.sliderView.volumnSlider.hidden = YES;
            self.translateType = KSYTranslateTypeTurn;
            [self transformDirection:YES withCurrentView:self.collectionSuperView withLastView:self.sliderView];
            //[self turn]
        }
        else if ([self.selectedTitle isEqualToString:@"背景音乐"]){
            self.sliderView.alpha = 1;
            self.sliderView.nameTitle = self.selectedTitle;
            self.sliderView.exfoliatingSlider.hidden = YES;
            self.sliderView.hongrunSlider.hidden = YES;
            self.sliderView.whiteSlider.hidden = YES;
            self.translateType = KSYTranslateTypeTurn;
            [self transformDirection:YES withCurrentView:self.collectionSuperView withLastView:self.sliderView];
        }
        else{
            
        }
        
    }
    else{
        
        KSYPictureAndLabelCell* cell=(KSYPictureAndLabelCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell.backGroundImageView.layer.borderColor = [UIColor redColor].CGColor;
        
        
        YYCache* cache = [YYCache cacheWithName:@"mydb"];
        [cache setObject:self.dataArray[indexPath.item] forKey:self.selectedTitle];
        //发送通知
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)indexPath.item],[NSString stringWithFormat:@"%@",self.selectedTitle],nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:KYSStreamChangeNotice object:self userInfo:dic];
        
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        [collectionView reloadData];
    }
    
}

-(void)adjustParameter:(UIButton*)sender{
    // KSYWeakSelf;
    
}

-(void)showSecondView{
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    self.alpha = 1;
    self.transform = CGAffineTransformMakeScale(1.21, 1.21);
    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
    } completion:nil];
}


@end

