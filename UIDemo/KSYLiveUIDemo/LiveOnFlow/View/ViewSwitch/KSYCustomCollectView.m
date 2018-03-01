//
//  KSYCustomCollectView.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/13.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYCustomCollectView.h"
//cell
#import "KSYOptionsCollectionViewCell.h"

#import "KSYPictureAndLabelModel.h"

@interface KSYCustomCollectView ()

@property (nonatomic,strong) NSMutableArray* dataSourceArray;
@property (nonatomic,strong) NSDictionary *allModelDic;

@end

@implementation KSYCustomCollectView

-(NSDictionary*)allModelDic{
    if (!_allModelDic) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"ArrayResourceList.plist" ofType:nil];
        _allModelDic = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:path]];
    }
    return _allModelDic;
}

-(instancetype)init{
    self = [super init];
    self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    
    if (self) {
        //添加布局
        [self addCollectView];
        //获取数据源
        [self obtainArrayDataSource];
        self.translateType = KSYTranslateTypeSlide;
    }
    return self;
}

- (void)layoutSubviews {
    self.frame =  CGRectMake(0,KSYScreenHeight-180-SafeAreaBottomHeight,KSYScreenWidth,180);
    [self.scratchableLatexView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(180);
        [self.scratchableLatexView reloadData];
    }];
    [self.secondView layoutUI];
}

-(void)obtainArrayDataSource{
    
    self.dataSourceArray = [[NSMutableArray alloc]init];
    NSArray* dataArray = [self.allModelDic valueForKey:@"功能"];
    [dataArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL* stop){
        NSDictionary* dic = obj;
        KSYPictureAndLabelModel *model = [KSYPictureAndLabelModel modelWithDictionary:dic];
        [self.dataSourceArray addObject:model];
        if (idx == dataArray.count-1) {
            [self.scratchableLatexView reloadData];
        }
    }];
}


-(void)addCollectView{
    //UIButton
    
    //弱引用
    __weak typeof(self)weakSelf = self;
    
    self.secondView = [[KSYSecondView alloc]init];
    
    self.secondView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    self.secondView.alpha = 0;
    self.secondView.returnBtnBlock = ^(UIButton *sender) {
        if ([sender.titleLabel.text isEqualToString: @"返回"]) {
            [weakSelf transformDirection:NO withCurrentView:weakSelf.secondView withLastView:weakSelf.scratchableLatexView];
        }
        else{
            [weakSelf dismissWithCurrentView:weakSelf.secondView];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"displayBottomView" object:nil];
        }
    };
    [self addSubview:self.secondView];
    //[self.secondView layoutSubviews];
    
    [self.secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(180);
        //[self.scratchableLatexView reloadData];
    }];
    
    //初始化布局类
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    // layout.itemSize = CGSizeMake(KSYScreenWidth/3, 40);
    //初始化collectView
    self.scratchableLatexView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout: layout];
    [self.scratchableLatexView registerNib:[UINib nibWithNibName:@"KSYOptionsCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.scratchableLatexView.delegate = self;
    self.scratchableLatexView.dataSource = self;
    self.scratchableLatexView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
    [self addSubview:self.scratchableLatexView];
    
    [self.scratchableLatexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.width.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(180);
        [self.scratchableLatexView reloadData];
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 6;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    KSYOptionsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.model = self.dataSourceArray[indexPath.item];
    
    if ([cell.model.textLabelName isEqualToString:@"静音"]) {
        if (_muteState) {
            cell.backGroundImageView.image = [UIImage imageNamed:@"静音开"];
        }
        else{
            cell.backGroundImageView.image = [UIImage imageNamed:@"静音未开"];
        }
    }
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(58,80);
}
//设置每个item横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (KSYScreenWidth-58*3)/4;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(7.f, (KSYScreenWidth-58*3)/4, 7.f, (KSYScreenWidth-58*3)/4);
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 7;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"collectionView");
    //点击切换
    KSYOptionsCollectionViewCell *collectCell = (KSYOptionsCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    NSString *title = collectCell.titleNameLabel.text;
    if ( [title isEqualToString:@"静音"]) {
        _muteState = !_muteState;
        
        if (_muteState) {
            collectCell.backGroundImageView.image = [UIImage imageNamed:@"静音开"];
        }
        else{
            collectCell.backGroundImageView.image = [UIImage imageNamed:@"静音未开"];
        }
        if (self.titleBlock) {
            self.titleBlock(title,_muteState);
        }
    }
    else if([title isEqualToString:@"镜像"]){
        _mirrorState = !_mirrorState;
        if (self.titleBlock) {
            self.titleBlock(title,_mirrorState);
        }
        
    }
    else if([title isEqualToString:@"拉流地址"]) {
        
        if (self.titleBlock) {
            self.titleBlock(title,NO);
        }
    }
    else if ([title isEqualToString:@"音效"]) {
        NSArray *array = @[@"混响",@"变声"];
        //  [self.secondView layoutSubviews];
        [self.secondView setUpSubView:array];
        
        self.secondView.alpha = 1;
        [self transformDirection:YES withCurrentView:self.scratchableLatexView withLastView:self.secondView];
        self.scratchableLatexView.hidden = YES;
    }
    else if ([title isEqualToString:@"背景音乐"]) {
        NSArray *array = @[@"背景音乐"];
        [self.secondView setUpSubView:array];
        //传数据值
        self.secondView.sliderView.volumnSlider.sldier.value =  self.volumnSliderValue;
        self.secondView.sliderView.voiceSlider.sldier.value= self.voiceSliderValue;
        
        self.secondView.alpha = 1;
        if (self.titleBlock) {
            self.titleBlock(title,NO);
        }
        [self transformDirection:YES withCurrentView:self.scratchableLatexView withLastView:self.secondView];
        self.scratchableLatexView.hidden = YES;
    }
    else if ([title isEqualToString:@"LOGO"]) {
        NSArray *array = @[@"LOGO"];
        [self.secondView setUpSubView:array];
        
        self.secondView.alpha = 1;
        [self transformDirection:YES withCurrentView:self.scratchableLatexView withLastView:self.secondView];
        self.scratchableLatexView.hidden = YES;
    }
    
}

-(void)showView{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    self.scratchableLatexView.transform = CGAffineTransformMakeScale(1.21, 1.21);
    self.scratchableLatexView.alpha = 0;
    
    [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.scratchableLatexView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        self.scratchableLatexView.alpha = 1.0;
    } completion:nil];
}



@end

