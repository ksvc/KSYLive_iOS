//
//  DefinitionMenuView.h
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/29.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"

@interface DefinitionMenuView : UIView
@property (weak, nonatomic) IBOutlet UIButton *superHighDefinitionButton;
@property (weak, nonatomic) IBOutlet UIButton *hightDefinitionButton;
@property (weak, nonatomic) IBOutlet UIButton *standardDefinitionButton;
- (void)definitationButtonColorHandler:(VideoDefinitionType)definition;
@end
