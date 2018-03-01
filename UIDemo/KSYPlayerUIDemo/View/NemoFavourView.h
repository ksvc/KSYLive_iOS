//
//  ALFavourView.h
//  Nemo
//
//  Created by iVermisseDich on 16/11/23.
//  Copyright © 2016年 com.ksyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NemoFavourView : UIView

@property (nonatomic, strong) NSArray <__kindof UIImage *>*imageArray;

- (void)dismiss;

- (void)animationStart;

@end
