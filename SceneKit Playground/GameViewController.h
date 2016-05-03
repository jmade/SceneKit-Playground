//
//  GameViewController.h
//  SceneKit Playground
//

//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "JDMUtility.h"

@import AVFoundation;

#import "JDMMotionManager.h"
#import "JDMMotionProtocol.h"

@interface GameViewController : UIViewController <UIScrollViewDelegate, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>



// Motion

@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) CMAltimeter *altimeter;
@property (nonatomic, strong) CMDeviceMotion *motionData;
@property (nonatomic, strong) CMAttitude *initialAttitude;
@property (nonatomic, strong) CMDeviceMotion *deviceMotion;
@property (nonatomic, strong) CMAttitude *attitude;
@property (nonatomic)  NSTimeInterval updateInterval;

@property (nonatomic, strong) UIView *cameraPreviewView;
@property (nonatomic, strong) CALayer *cameraPreviewLayer;

@property CGFloat pitchSpan;
@property CGFloat rollSpan;

-(void)didMove;



@end
