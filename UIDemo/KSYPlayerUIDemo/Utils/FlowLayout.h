//
//  FlowLayout.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/23.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlowLayout;

@protocol FlowLayoutDelegate <NSObject>

@required
- (CGFloat)flowLayout:(FlowLayout *)flowLayout heightForRowAtIndexPath:(NSInteger)index itemWidth:(CGFloat)itemWidth;

@optional
- (CGFloat)columnCountInFlowLayout:(FlowLayout *)flowLayout;
- (CGFloat)columnMarginInFlowLayout:(FlowLayout *)flowLayout;
- (CGFloat)rowMarginInFlowLayout:(FlowLayout *)flowLayout;
- (UIEdgeInsets)edgeInsetsInFlowLayout:(FlowLayout *)flowLayout;

@end

@interface FlowLayout : UICollectionViewLayout
@property (nonatomic ,weak) id<FlowLayoutDelegate> delegate;
@end
