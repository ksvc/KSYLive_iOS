//
//  DefinitionMenuView.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/8/29.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "DefinitionMenuView.h"

@implementation DefinitionMenuView

- (void)definitationButtonColorHandler:(VideoDefinitionType)definition {
    switch (definition) {
        case VideoDefinitionTypeStandard:
        {
            self.standardDefinitionButton.selected = YES;
            self.hightDefinitionButton.selected = NO;
            self.superHighDefinitionButton.selected = NO;
        }
            break;
            
        case VideoDefinitionTypeHigh:
        {
            self.standardDefinitionButton.selected = NO;
            self.hightDefinitionButton.selected = YES;
            self.superHighDefinitionButton.selected = NO;
        }
            break;
            
        case VideoDefinitionTypeSuper:
        {
            self.standardDefinitionButton.selected = NO;
            self.hightDefinitionButton.selected = NO;
            self.superHighDefinitionButton.selected = YES;
        }
            break;
            
        default:
            break;
    }
}

@end
