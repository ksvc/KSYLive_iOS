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
    self.completeEditButton = [[UIButton alloc]initButtonWithTitleName:@"完成编辑" buttonWithImageName:nil buttonTag:600];
    [self.completeEditButton addTarget:self action:@selector(buttonClick:) forControlEvents: UIControlEventTouchUpInside];
    [self addSubview:self.completeEditButton];
    [self.completeEditButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([[KSYGetDeviceName getDeviceName] isEqual:@"iPhoneX"]) {
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self).offset(SafeAreaTopHeight);
            make.width.mas_equalTo(@100);
            make.height.mas_equalTo(@40);
        }
        else {
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self).offset(20);
            make.width.mas_equalTo(@100);
            make.height.mas_equalTo(@40);
        }
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(100, 100);
    layout.minimumLineSpacing = 8;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kScreenSize.height-100, kScreenSize.width, 100) collectionViewLayout:layout];
    [_collectionView registerClass:[KSYCollectionCell class] forCellWithReuseIdentifier:kCollectionViewCellIdentifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.scrollsToTop = YES;
    _collectionView.alpha = 0.7;
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

-(void)buttonClick:(UIButton*)button{
    if (self.completeBlock){
        self.completeBlock(button);
    }
}
@end
