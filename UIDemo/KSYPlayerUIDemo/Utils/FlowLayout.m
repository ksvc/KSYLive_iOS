//
//  FlowLayout.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "FlowLayout.h"
#import <AssetsLibrary/AssetsLibrary.h>
//默认的列数
static const NSInteger DefaultColumnCpunt = 2;

//每一列之间的间距
static const CGFloat DefaultColumnMargin = 13;

//没一行之间的间距
static const CGFloat DefaultRowMargin = 7;

//边缘间距
static const UIEdgeInsets DefaultEdgeInsets = {0,13,2,13};

@interface FlowLayout ()
//c存放所有cell的布局属性
@property (nonatomic, strong) NSMutableArray *attrsArray;
//存放所有列的当前高度
@property (nonatomic, strong) NSMutableArray *columnHeights;
/** 内容的高度 */
@property (nonatomic, assign) CGFloat contentHeight;

- (CGFloat)rowMargin;
- (CGFloat)columnMargin;
- (NSInteger)columnCount;
- (UIEdgeInsets)edgeInsets;
@end

@implementation FlowLayout

- (CGFloat)rowMargin
{
    if ([self.delegate respondsToSelector:@selector(rowMarginInFlowLayout:)]) {
        return [self.delegate rowMarginInFlowLayout:self];
    } else {
        return DefaultRowMargin;
    }
}

- (CGFloat)columnMargin
{
    if ([self.delegate respondsToSelector:@selector(columnMarginInFlowLayout:)]) {
        return [self.delegate columnMarginInFlowLayout:self];
    } else {
        return DefaultColumnMargin;
    }
}

- (NSInteger)columnCount
{
    if ([self.delegate respondsToSelector:@selector(columnCountInFlowLayout:)]) {
        return [self.delegate columnCountInFlowLayout:self];
    } else {
        return DefaultColumnCpunt;
    }
}

- (UIEdgeInsets)edgeInsets
{
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInFlowLayout:)]) {
        return [self.delegate edgeInsetsInFlowLayout:self];
    } else {
        return DefaultEdgeInsets;
    }
}

- (NSMutableArray *)attrsArray
{
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (NSMutableArray *)columnHeights
{
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.contentHeight = 0;
    
    //清除之前计算的所有高度，因为刷新的时候回调用这个方法
    [self.columnHeights removeAllObjects];
    for (NSInteger i = 0; i < DefaultColumnCpunt; i++) {
        [self.columnHeights addObject:@(self.edgeInsets.top)];
    }
    
    //把初始化的操作都放到这里
    [self.attrsArray removeAllObjects];
    
    //开始创建每一个cell对应的布局属性
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attrsArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat collectionViewW = self.collectionView.frame.size.width;
    
    CGFloat w = (collectionViewW - self.edgeInsets.left - self.edgeInsets.right -(self.columnCount - 1) * self.columnMargin) / self.columnCount;
    
    CGFloat h = [self.delegate flowLayout:self heightForRowAtIndexPath:indexPath.item itemWidth:w];
    
    NSInteger destColumn = 0;
    
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 0; i < self.columnCount; i++) {
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            destColumn = i;
        }
    }
    
    CGFloat x = self.edgeInsets.left + destColumn * (w + self.columnMargin);
    CGFloat y = minColumnHeight;
    if (y != self.edgeInsets.top) {
        y += self.rowMargin;
    }
    
    attrs.frame = CGRectMake(x, y, w, h);
    
    self.columnHeights[destColumn] = @(CGRectGetMaxY(attrs.frame));
    
    CGFloat columnHeight = [self.columnHeights[destColumn] doubleValue];
    if (self.contentHeight < columnHeight) {
        self.contentHeight = columnHeight;
    }
    return attrs;
    
}

- (CGSize)collectionViewContentSize
{
    //    CGFloat maxColumnHeight = [self.columnHeights[0] doubleValue];
    //
    //    for (NSInteger i = 1; i < DefaultColumnCpunt; i++) {
    //        // 取得第i列的高度
    //        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
    //
    //        if (maxColumnHeight < columnHeight) {
    //            maxColumnHeight = columnHeight;
    //        }
    //    }
    return CGSizeMake(0, self.contentHeight + self.edgeInsets.bottom);
}

@end
