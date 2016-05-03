//
//  JDMMotionManager.h
//  SceneKit Playground
//
//  Created by Justin Madewell on 2/15/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDMMotionProtocol.h"


@import UIKit;
@import CoreMotion;


@interface JDMMotionManager : NSObject <JDMMotionProtocol>

@property CGFloat pitch;
@property CGFloat roll;
@property CGFloat yaw;

@property CGFloat nPitch;
@property CGFloat nRoll;
@property CGFloat nYaw;

@property CGFloat upAngle;
@property CGFloat downAngle;
@property CGFloat leftAngle;
@property CGFloat rightAngle;

@property CGFloat degreesForPitch;
@property CGFloat degreesForRoll;

@property CGFloat magnitude;
@property CGFloat rotation;

@property CGPoint motionOffset;

-(CGPoint)normalizedOffset;



@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) CMAltimeter *altimeter;

@property (nonatomic, strong) CMDeviceMotion *motionData;

@property (nonatomic, strong) CMDeviceMotion *deviceMotion;
@property (nonatomic, strong) CMAttitude *attitude;

@property (nonatomic, strong) NSString *barometricPressureString;
@property (nonatomic, strong) NSString *altitudeString;

@property (nonatomic)  NSTimeInterval updateInterval;

//-(void)didMove;

+(JDMMotionManager*)activate;


@end
