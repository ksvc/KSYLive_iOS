//
//  ViewController.m
//  ALCollectionViewDemo
//
//  Created by iVermisseDich on 2017/7/18.
//  Copyright © 2017年 com.ksyun. All rights reserved.
//

#import "KSYCollectionView.h"
#import "KSYCollectionCell.h"

#define kScreenSize [UIScreen mainScreen].bounds.size
#define kCollectionViewCellIdentifier @"com.ksyun.collecviewcell"

@interface KSYCollectionView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation KSYCollectionView

- (id) init{
    self = [super init];
    
    _btn0  = [self addButton:@"done"];
    
    // Do any additional setup after loading the view, typically from a nib.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 8;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kScreenSize.height-200, kScreenSize.width, 100) collectionViewLayout:layout];
    [_collectionView registerClass:[KSYCollectionCell class] forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.scrollsToTop = YES;
    _collectionView.alpha = 0.8;
    
    [self addSubview:_collectionView];
    
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 8;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KSYCollectionCell *cell = (KSYCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier forIndexPath:indexPath];
    
    // 图片的名称
    NSString *imageToLoad = [NSString stringWithFormat:@"decal_%ld", indexPath.row];
    // 设置imageView的图片
    cell.name = imageToLoad;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.DEBlock){
        NSString *imageNameToLoad = [NSString stringWithFormat:@"decal_%ld", indexPath.row];
        self.DEBlock(imageNameToLoad);
    }
}

- (void)layoutUI{
    [super layoutUI];
    [self putRow3:_btn0
              and:[UIView new]
              and:[UIView new]];
    self.btnH = 100;
    self.gap = 0;
    self.yPos = self.height - self.btnH;
    [self putRow1:_collectionView];
}
@end
