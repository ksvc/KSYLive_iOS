//
//  KSYHeadControl.m
//  KSYLiveUIDemo
//
//  Created by 王旭 on 2017/11/13.
//  Copyright © 2017年 王旭. All rights reserved.
//

#import "KSYHeadControl.h"

@interface KSYHeadControl()

@property (nonatomic,strong) UIButton *headIconBtn;
@property (nonatomic,strong) UILabel *textLabel;

@end

@implementation KSYHeadControl

-(instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
        self.layer.cornerRadius = 45/2;
    }
    return self;
}

- (void)layoutSubviews {

    UIButton *headIconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headIconButton.frame = CGRectMake(5,5,35,35);
    headIconButton.layer.cornerRadius = 35/2;
    headIconButton.layer.masksToBounds = YES;
    [headIconButton setImage:[UIImage imageNamed:@"头像.jpg"] forState: UIControlStateNormal];
    [self addSubview:headIconButton];
    
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(headIconButton.frame)+5,5,80,35)];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont systemFontOfSize:17];
    textLabel.layer.masksToBounds = YES;
   // textLabel.backgroundColor = KSYRGB(178, 178, 178);
    //    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:20],};
    
    //    CGSize textSize = [str boundingRectWithSize:CGSizeMake(100, 100) options:NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;;
    //    [textLabel setFrame:CGRectMake(100, 100, textSize.width, textSize.height)];
    textLabel.text = [NSString stringWithFormat:@"%@",@"金山云"];
    [self addSubview:textLabel];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
