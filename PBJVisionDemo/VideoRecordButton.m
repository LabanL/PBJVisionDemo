//
//  VideoRecordButton.m
//  PBJVisionDemo
//
//  Created by LabanL on 18/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import "VideoRecordButton.h"

// Common
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define VideoRecordButtonSize 120
#define BackViewMainViewNormalRatio 0.6

@implementation VideoRecordButton{
    NSTimer *_animationTimer;
    CGFloat _progressAngle;
    CGFloat _currentAnimationProgress;
    CGFloat _animationProgressStep;
}

- (instancetype) initWithCenter:(CGPoint)center{
    CGRect rect = CGRectMake(center.x-VideoRecordButtonSize/2, center.y-VideoRecordButtonSize/2, VideoRecordButtonSize, VideoRecordButtonSize);
    self = [super initWithFrame:rect];
    if(self){
        self.backgroundColor = [UIColor clearColor]; //设置默认背景为透明
        UILongPressGestureRecognizer* longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
        [self addGestureRecognizer:longPressGes];
    }
    return self;
}

- (void)handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self animateProgressBar];
            
            [self setNeedsDisplay];
            if([self.delegate respondsToSelector:@selector(recordStarted:)]){
                [self.delegate recordStarted:self];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if(_animationTimer){
                [_animationTimer invalidate];
            }
            _animationTimer = nil;
            [self setNeedsDisplay];
            if([self.delegate respondsToSelector:@selector(recordCompleted:)]){
                [self.delegate recordCompleted:self];
            }
        }
            break;
        default:
            break;
    }
}

- (BOOL)isAnimating{
    return !(_animationTimer == nil);
}

- (UIColor*)topViewColor{
    if(_topViewColor == nil){
        _topViewColor = [UIColor whiteColor];
    }
    return _topViewColor;
}

- (UIColor*)backViewColor{
    if(_backViewColor == nil){
        _backViewColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    }
    return _backViewColor;
}

- (UIColor*)progressColor{
    if(_progressColor == nil){
        _progressColor = [UIColor colorWithRed:39/255.0 green:181/255.0 blue:243/255.0 alpha:1];
    }
    return _progressColor;
}

- (CGFloat)topBackViewNormalRatio{
    if(_topBackViewNormalRatio <= 0){
        _topBackViewNormalRatio = 0.7;
    }
    return _topBackViewNormalRatio;
}

- (CGFloat)topBackViewAnimatingRatio{
    if(_topBackViewAnimatingRatio <= 0){
        _topBackViewAnimatingRatio = 0.3;
    }
    return _topBackViewAnimatingRatio;
}

- (CGFloat)progressBackViewAnimatingRatio{
    if(_progressBackViewAnimatingRatio <= 0){
        _progressBackViewAnimatingRatio = 0.1;
    }
    return _progressBackViewAnimatingRatio;
}

- (NSUInteger)maxRecordTime{
    if(_maxRecordTime <= 0){
        _maxRecordTime = 10;
    }
    return _maxRecordTime;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGPoint innerCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(innerCenter.x, innerCenter.y);
    if(!self.isAnimating) radius = radius*BackViewMainViewNormalRatio;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    [self drawBackground:context];
    [self drawBackView:context center:innerCenter andRadius:radius];
    CGFloat topViewRadius = radius*(self.isAnimating ? self.topBackViewAnimatingRatio : self.topBackViewNormalRatio);
    [self drawTopView:context center:innerCenter andRadius:topViewRadius];
    
    if(self.isAnimating){
        [self drawProgressBar:context center:innerCenter andRadius:radius andWidth:radius*self.progressBackViewAnimatingRatio];
    }
}

- (void)drawBackground:(CGContextRef)context {
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, self.bounds);
}

//绘制TopView
- (void)drawTopView:(CGContextRef)context center:(CGPoint)center andRadius:(CGFloat) radius{
    CGContextSetFillColorWithColor(context, self.topViewColor.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(360), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

//绘制BackView
- (void)drawBackView:(CGContextRef)context center:(CGPoint)center andRadius:(CGFloat) radius{
    CGContextSetFillColorWithColor(context, self.backViewColor.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(0), DEGREES_TO_RADIANS(360), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

//绘制ProgressBarView
- (void)drawProgressBar:(CGContextRef)context center:(CGPoint)center andRadius:(CGFloat)radius andWidth:(CGFloat)width{
    CGContextSetFillColorWithColor(context, self.progressColor.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(-90), DEGREES_TO_RADIANS(_progressAngle), 0);
    CGContextAddArc(context, center.x, center.y, radius - width, DEGREES_TO_RADIANS(_progressAngle), DEGREES_TO_RADIANS(-90), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark - Amination
- (void)animateProgressBar{
    _currentAnimationProgress = 0.0;
    _animationProgressStep = 360 * 0.01f / self.maxRecordTime;

    _animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgressBarForAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
}

- (void)updateProgressBarForAnimation {
    _currentAnimationProgress += _animationProgressStep;
    _progressAngle = _currentAnimationProgress - 90;
    if(_progressAngle >= 270){
        [_animationTimer invalidate];
        _animationTimer = nil;
        if([self.delegate respondsToSelector:@selector(recordCompleted:)]){
            [self.delegate recordCompleted:self];
        }
    }
    [self setNeedsDisplay];
}
@end
