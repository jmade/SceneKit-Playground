//
//  JDMControlScrollView.h
//  SceneKit Playground
//
//  Created by Justin Madewell on 2/4/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDMControlScrollView : UIScrollView <UIGestureRecognizerDelegate>

@property(nonatomic) UILabel *label;

@property CGFloat maxAngleUp;
@property CGFloat maxAngleDown;
@property CGFloat maxAngleLeft;
@property CGFloat maxAngleRight;

@property CGFloat snapThreshold;
@property BOOL isSnapped;

-(CGPoint)normalizedTouchLocation;
-(void)updateLabel;
-(void)restore;
-(CGPoint)normalizedOffset;
-(int)normalizedQuadrant;


-(CGPoint)radianOffsetPoint;

-(CGFloat)radiansX;
-(CGFloat)radiansY;

-(CGPoint)normalizedAngle;
-(CGPoint)motionAngle;

-(void)moveViaNormalPoint:(CGPoint)normalPoint;
-(CGPoint)offsetPointFromNormal:(CGPoint)nPoint;
-(void)resetScrollViewToCenter;

-(void)setMaxAngleForUp:(CGFloat)up Down:(CGFloat)down Left:(CGFloat)left Right:(CGFloat)right;

@end
