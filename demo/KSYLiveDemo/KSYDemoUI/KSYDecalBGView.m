//
//  KSYDecalBGView.m
//  demo
//
//  Created by iVermisseDich on 2017/5/25.
//  Copyright © 2017年 ksyun. All rights reserved.
//

#import "KSYDecalBGView.h"
#import "KSYDecalView.h"

@interface KSYDecalBGView()

@property (nonatomic, readonly) KSYDecalView * decalView;
@property (nonatomic, readonly) KSYDecalView *curDecalView;
// 贴纸gesture 相关
@property (nonatomic, assign) CGPoint loc_in;
@property (nonatomic, assign) CGPoint ori_center;
@property (nonatomic, assign) CGFloat curScale;

@end

@implementation KSYDecalBGView

- (id)init{
    self = [super init];
    _loc_in = CGPointZero;
    _curScale = 1.0f;
    
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for (UIView *view in self.subviews) {
        CGPoint subPoint = [view convertPoint:point fromView:self];
        UIView *resultView = [view hitTest:subPoint withEvent:event];
        if (resultView) {
            return resultView;
        }
    }
    return [super hitTest:point withEvent:event];
}

- (void)genDecalViewWithImgName:(NSString *)imgName{
    UIImage *image = [UIImage imageNamed:imgName];
    _decalView = [[KSYDecalView alloc] initWithImage:image];
    _decalView.select = YES;
    _curDecalView = _decalView;
    [self addSubview:_decalView];
    
    _decalView.frame = CGRectMake((self.frame.size.width - image.size.width * 0.5) * 0.5,
                                 (self.frame.size.height - image.size.height * 0.5) * 0.5,
                                 image.size.width * 0.5, image.size.height * 0.5);
    // pan
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [_decalView addGestureRecognizer:panGes];
    // tap
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [_decalView addGestureRecognizer:tapGes];
    // pinch
    UIPinchGestureRecognizer *pinGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [_decalView addGestureRecognizer:pinGes];
    // 旋转&缩放
    [_decalView.dragBtn addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scaleAndRotate:)]];
}

- (void)deleteDecal:(UIButton *)sender{
    if (_curDecalView.isSelected) {
        [_curDecalView removeFromSuperview];
    }else{
        NSLog(@"delete Btn display error");
    }
}

- (void)scaleAndRotate:(UIPanGestureRecognizer *)gesture{
    if (_curDecalView.isSelected) {
        CGPoint curPoint = [gesture locationInView:self];
        if (gesture.state == UIGestureRecognizerStateBegan) {
            _loc_in = [gesture locationInView:self];
        }
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            _curDecalView.oriTransform = _curDecalView.transform;
        }
        
        // 计算缩放
        CGFloat preDistance = [self getDistance:_loc_in withPointB:_curDecalView.center];
        CGFloat curDistance = [self getDistance:curPoint withPointB:_curDecalView.center];
        CGFloat scale = curDistance / preDistance;
        
        // 计算弧度
        CGFloat preRadius = [self getRadius:_curDecalView.center withPointB:_loc_in];
        CGFloat curRadius = [self getRadius:_curDecalView.center withPointB:curPoint];
        CGFloat radius = curRadius - preRadius;
        radius = - radius;
        CGAffineTransform transform = CGAffineTransformScale(_curDecalView.oriTransform, scale, scale);
        _curDecalView.transform = CGAffineTransformRotate(transform, radius);
        
        if (gesture.state == UIGestureRecognizerStateEnded ||
            gesture.state == UIGestureRecognizerStateCancelled) {
            _curDecalView.oriScale = scale * _curDecalView.oriScale;
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)tapGes{
    if ([[tapGes view] isKindOfClass:[KSYDecalView class]]){
        KSYDecalView *view = (KSYDecalView *)[tapGes view];
        
        if (view != _curDecalView) {
            _curDecalView.select = NO;
            view.select = YES;
            _curDecalView = view;
        }else{
            view.select = !view.select;
            if (view.select) {
                _curDecalView = view;
            }else{
                _curDecalView = nil;
            }
        }
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)pinGes{
    if ([[pinGes view] isKindOfClass:[KSYDecalView class]]){
        KSYDecalView *view = (KSYDecalView *)[pinGes view];
        
        if (pinGes.state ==UIGestureRecognizerStateBegan) {
            view.oriTransform = view.transform;
        }
        
        if (pinGes.state ==UIGestureRecognizerStateChanged) {
            _curScale = pinGes.scale;
            CGAffineTransform tr = CGAffineTransformScale(view.oriTransform, pinGes.scale, pinGes.scale);
            
            view.transform = tr;
        }
        
        // 当手指离开屏幕时,将lastscale设置为1.0
        if ((pinGes.state == UIGestureRecognizerStateEnded) || (pinGes.state == UIGestureRecognizerStateCancelled)) {
            view.oriScale = view.oriScale * _curScale;
            pinGes.scale = 1;
        }
    }
}

- (void)move:(UIPanGestureRecognizer *)panGes {
    if ([[panGes view] isKindOfClass:[KSYDecalView class]]){
        CGPoint loc = [panGes locationInView:self];
        KSYDecalView *view = (KSYDecalView *)[panGes view];
        if (_curDecalView.select) {
            if ([_curDecalView pointInside:[_curDecalView convertPoint:loc fromView:self] withEvent:nil]){
                view = _curDecalView;
            }
        }
        if (!view.select) {
            return;
        }
        if (panGes.state == UIGestureRecognizerStateBegan) {
            _loc_in = [panGes locationInView:self];
            _ori_center = view.center;
        }
        
        CGFloat x;
        CGFloat y;
        x = _ori_center.x + (loc.x - _loc_in.x);
        y = _ori_center.y + (loc.y - _loc_in.y);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0 animations:^{
                view.center = CGPointMake(x, y);
            }];
        });
    }
}

// 距离
-(CGFloat)getDistance:(CGPoint)pointA withPointB:(CGPoint)pointB
{
    CGFloat x = pointA.x - pointB.x;
    CGFloat y = pointA.y - pointB.y;
    
    return sqrt(x*x + y*y);
}

// 角度
-(CGFloat)getRadius:(CGPoint)pointA withPointB:(CGPoint)pointB
{
    CGFloat x = pointA.x - pointB.x;
    CGFloat y = pointA.y - pointB.y;
    return atan2(x, y);
}

- (void)setInteractionEnabled:(BOOL)interactionEnabled{
    _interactionEnabled = interactionEnabled;
    if (interactionEnabled) {
        self.userInteractionEnabled = YES;
        for (KSYDecalView *view in self.subviews) {
            view.userInteractionEnabled = YES;
        }
    }else{
        self.userInteractionEnabled = NO;
        for (KSYDecalView *view in self.subviews) {
            view.select = NO;
            view.userInteractionEnabled = NO;
        }
    }
}

@end
