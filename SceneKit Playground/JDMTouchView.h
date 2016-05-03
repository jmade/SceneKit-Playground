//
//  JDMTouchView.h
//  SceneKit Playground
//
//  Created by Justin Madewell on 2/1/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.


#import <UIKit/UIKit.h>

@interface JDMTouchView : UIView <UIScrollViewDelegate> id<UIGestureRecognizerDelegate>;

@property CGPoint currentTouchPoint;
@property CGPoint lastTouchPoint;
@property CGPoint startTouchPoint;
@property CGFloat lastX;
@property CGFloat lastY;
@property CGFloat normalizedY;
@property CGFloat normalizedX;
@property CGFloat verticalPanNormalizedAmount;
@property CGFloat startY;

@property NSNumber *normalYNumber;
@property CGFloat translationX;

@property CGFloat normalizedVerticalDragChange;




@property (nonatomic, strong) UIScrollView *_horizontalScrollView;
@property (nonatomic, strong) UIScrollView *_verticalScrollView;


@end
