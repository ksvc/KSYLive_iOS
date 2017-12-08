//
//  KSYDrawingView.h
//  KSYGPUStreamerDemo
//
//  Created by 江东 on 17/6/19.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYDrawingView.h"
#import <QuartzCore/QuartzCore.h>

@interface KSYDrawingView ()

@property (nonatomic, strong) UIBezierPath *path;

@end
@implementation KSYDrawingView

+ (Class)layerClass{
    //this makes our view create a CAShapeLayer
    //instead of a CALayer for its backing layer
    return [CAShapeLayer class];
}

- (id)init{
    self = [super init];
    [self awakeFromNib];
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    //create a mutable path
    self.path = [[UIBezierPath alloc] init];
    
    //configure the layer
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineWidth = 5;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //get the starting point
    CGPoint point = [[touches anyObject] locationInView:self];
    
    //move the path drawing cursor to the starting point
    [self.path moveToPoint:point];
    if(_viewUpdateCallback) {
        _viewUpdateCallback();
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //get the current point
    CGPoint point = [[touches anyObject] locationInView:self];
    CGSize sz = self.frame.size;
    if ((point.y > 0) && (point.y < sz.height - 1)){
        //add a new line segment to our path
        [self.path addLineToPoint:point];
    }
    //update the layer with a copy of the path
    ((CAShapeLayer *)self.layer).path = self.path.CGPath;
    if(_viewUpdateCallback) {
        _viewUpdateCallback();
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if(_viewUpdateCallback) {
        _viewUpdateCallback();
    }
}
- (void) clearAllPath {
    [self.path removeAllPoints];
    ((CAShapeLayer *)self.layer).path = nil;
    if(_viewUpdateCallback) {
        _viewUpdateCallback();
    }
}
@end
