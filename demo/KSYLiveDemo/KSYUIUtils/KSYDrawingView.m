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
@property CGRect cgRect;

@end
@implementation KSYDrawingView

+ (Class)layerClass{
    //this makes our view create a CAShapeLayer
    //instead of a CALayer for its backing layer
    return [CAShapeLayer class];
}

- (id)initDraw:(CGRect)rect{
    self = [super init];
    [self awakeFromNib];
    _cgRect = rect;
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
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //get the current point
    CGPoint point = [[touches anyObject] locationInView:self];
    if ((point.y > 0) && (point.y < _cgRect.size.height - 1)){
        //add a new line segment to our path
        [self.path addLineToPoint:point];
    }
    //update the layer with a copy of the path
    ((CAShapeLayer *)self.layer).path = self.path.CGPath;
}
@end
