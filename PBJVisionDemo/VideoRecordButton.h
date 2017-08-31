//
//  VideoRecordButton.h
//  PBJVisionDemo
//
//  Created by LabanL on 18/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoRecordButton;

@protocol VideoRecordButtonDelegate <NSObject>

- (void) recordStarted:(VideoRecordButton*)sender;
- (void) recordCompleted:(VideoRecordButton*)sender;

@end

@interface VideoRecordButton : UIView

@property (nonatomic, weak) id<VideoRecordButtonDelegate> delegate;

@property (nonatomic, retain) UIColor* backViewColor;
@property (nonatomic, retain) UIColor* topViewColor;
@property (nonatomic, retain) UIColor* progressColor;

@property (nonatomic, assign) CGFloat topBackViewNormalRatio;
@property (nonatomic, assign) CGFloat topBackViewAnimatingRatio;
@property (nonatomic, assign) CGFloat progressBackViewAnimatingRatio;

@property (nonatomic, readonly) BOOL isAnimating;

@property (nonatomic, assign) NSUInteger maxRecordTime; //最大录制时间(Second)

- (instancetype) initWithCenter:(CGPoint)center;

@end
