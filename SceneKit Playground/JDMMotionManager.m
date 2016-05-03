//
//  JDMMotionManager.m
//  SceneKit Playground
//
//  Created by Justin Madewell on 2/15/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "JDMMotionManager.h"
#import "JDMUtility.h"
//#import "Tools.h"

#define radiansToDegrees(x) (180/M_PI)*x

@implementation JDMMotionManager

{
    CGFloat originalHoldingPitch;
    CGFloat originalHoldingRoll;
    CGFloat originalHoldingYaw;
}

#pragma mark - Init

-(instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

+(JDMMotionManager*)activate
{
    JDMMotionManager *motionManager = [[self alloc] init];

    
    // Set Dafault Update Interval
    motionManager.updateInterval = 0.01;
    motionManager.degreesForRoll = 45;
    motionManager.degreesForPitch = 45;
    
    
    
    [motionManager initMotionManager];
    [motionManager initAltimeter];
    
    
    return motionManager;
}


#pragma mark - MOTION

// --- class method to get magnitude of vector via Pythagorean theorem
//+ (double)magnitudeFromAttitude:(CMAttitude *)attitude {
//    return sqrt(pow(attitude.roll, 2.0f) + pow(attitude.yaw, 2.0f) + pow(attitude.pitch, 2.0f));
//}

-(CGFloat)magnitudeFromAttitude:(CMAttitude *)attitude {
    return sqrt(pow(attitude.roll, 2.0f) + pow(attitude.yaw, 2.0f) + pow(attitude.pitch, 2.0f));
}


-(void)stopManagingMotion
{
    [self.manager stopDeviceMotionUpdates];
    [self.altimeter stopRelativeAltitudeUpdates];
}



/* Initialize Motion Manager and set the Update Interval */
-(void)initMotionManager
{
    self.manager = [[CMMotionManager alloc] init];
    
    if (self.manager.deviceMotionAvailable)
    {
        self.manager.deviceMotionUpdateInterval = self.updateInterval;
        
        [self startManagerReadings];
    }
    
}

#pragma mark - Altimeter INIT

-(void)initAltimeter
{
    if([CMAltimeter isRelativeAltitudeAvailable]){
        self.altimeter = [[CMAltimeter alloc]init];
        
        [self.altimeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData *altitudeData, NSError *error) {
            
            // barometricPressureString = [NSString stringWithFormat:@"%.02f", altitudeData.pressure.floatValue];
            // NSLog(@"barometricPressureString:%@",barometricPressureString);
            
            //  altitudeString = [NSString stringWithFormat:@"%.02f m", altitudeData.relativeAltitude.floatValue];
            // NSLog(@"altitudeString:%@",altitudeString);
            
            // altBarReadout = [NSString stringWithFormat:@"Barometric Pressure:%@\nAltitude:%@",barometricPressureString,altitudeString];
            
            // readingslabel.text = readout;
            
            
            
        }];
    }
    
}






-(void)startManagerReadings
{
    // Main Manager Call**
    [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                      withHandler:^(CMDeviceMotion *data, NSError *error)
     {
         self.motionData = data;
         
         // For First Run Only
         // to get/set original Holding Offset
         static int firstNumber;
         if (firstNumber == 0) {
             [self resetHoldingAngles];
         }
         firstNumber++;
         
         
         [self digestMotionData:data];

         
     }];
    
}

//-(void)extractEulerAnglesFromDeviceMotionQuaternion:(CMQuaternion)quat
//{
//    self.roll = radiansToDegrees(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
//    self.pitch = radiansToDegrees(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
//    self.yaw = radiansToDegrees(asin(2*quat.x*quat.y + 2*quat.w*quat.z));
//
//}

-(CGFloat)getCurrentRoll
{
    CMQuaternion quat = self.manager.deviceMotion.attitude.quaternion;
    return radiansToDegrees(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
    
}


-(CGFloat)getCurrentPitch
{
    CMQuaternion quat = self.manager.deviceMotion.attitude.quaternion;
    return radiansToDegrees(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
    
}

-(void)digestMotionData:(CMDeviceMotion*)data
{
    self.rotation = atan2(data.gravity.x, data.gravity.y) - M_PI;
    
    self.magnitude = [self magnitudeFromAttitude:data.attitude];
    
    CMQuaternion quat = self.manager.deviceMotion.attitude.quaternion;
    self.roll = radiansToDegrees(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
    self.pitch = radiansToDegrees(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
    self.yaw = radiansToDegrees(asin(2*quat.x*quat.y + 2*quat.w*quat.z));
    
    [self normalizePitch:self.pitch andRoll:self.roll andYaw:self.yaw];
    
}


-(void)resetHoldingAngles
{
    originalHoldingPitch = [self getCurrentPitch];
    originalHoldingRoll = [self getCurrentRoll];
}

-(void)normalizePitch:(CGFloat)pitch andRoll:(CGFloat)roll andYaw:(CGFloat)yaw
{
    
    CGFloat scaledPitch = ((pitch - originalHoldingPitch) * - 1);
    
    CGFloat tiltSpan = self.degreesForPitch;
    
    scaledPitch = (scaledPitch/tiltSpan);
    //
    if(scaledPitch<-1.0){scaledPitch=-1.0;}
    if(scaledPitch>1.0){scaledPitch=1.0;}
    
    CGFloat scaledRoll = ((roll - originalHoldingRoll) * 1);
    
    CGFloat rollSpan = self.degreesForRoll;
    
    scaledRoll = (scaledRoll/rollSpan);
    
    if(scaledRoll<-1.0){scaledRoll=-1.0;}
    if(scaledRoll>1.0){scaledRoll=1.0;}
    
    CGFloat mY = [self motionYFromNormalizedPitch:scaledPitch];
    CGFloat mX = [self motionXFromNormalizedRoll:scaledRoll];
    
    CGPoint motionPoint = CGPointMake(mX, mY);
    self.motionOffset = motionPoint;
    
//    if (moveCameraWithMotion) {
//        // move camera
//        [self tiltCameraWithNormalizedOffset:motionPoint];
//    }
    
    //  NSString *intString = [NSString stringWithFormat:@"Roll: %i Pitch: %i Yaw: %i",(int)roll,(int)pitch,(int)yaw];
    
    // NSString *scaledString = [NSString stringWithFormat:@"Scaled Roll: %@ Scaled Pitch: %@",floatString(scaledRoll),floatString(scaledPitch)];
    
    //  NSString *string = [NSString stringWithFormat:@"%@\n%@",intString,scaledString];
    
    //motionlabel.text = string;
    
    
    
}
// Conversion method

-(CGFloat)motionXFromNormalizedRoll:(CGFloat)nRoll
{
    CGFloat X = nRoll;
    CGFloat fixedX;
    
    //CGFloat angleSpan = self.maxAngleLeft + self.maxAngleRight;
    
    CGFloat percent;
    
    if (self.leftAngle < self.rightAngle) {
        // up is greater than down
        percent = ((self.rightAngle/self.leftAngle) * 100 );
    }
    else
    {
        percent = ((self.leftAngle/self.rightAngle) * 100 );
    }
    
    if (self.leftAngle == self.rightAngle) {
        percent = 50.0;
    }
    
    percent = percent*0.01;
    //  NSLog(@"percent: %f",percent);
    
    CGFloat limiter = 1.0 - percent;
    // NSLog(@"limiter: %f",limiter);
    
    CGFloat totalRadians = RadiansFromDegrees((self.leftAngle + self.rightAngle));
    
    CGFloat leftRadianAmountOfScale = limiter * totalRadians;
    CGFloat rightRadiansAmountOfScale = totalRadians - leftRadianAmountOfScale;
    
    CGFloat newRadians;
    
    if (X < 0) {
        fixedX = ((1.0 - (X * -1.0))/2);
    }
    else
    {
        
        fixedX = 0.5 + (0.5 * X);
    }
    
    CGFloat fixedRad;
    
    if (fixedX < limiter) {
        //NSLog(@"Left Pan");
        newRadians = fixedX * totalRadians;
        fixedRad = leftRadianAmountOfScale - newRadians;
        fixedRad = (fixedRad * -1.0);
    }
    else
    {
        // NSLog(@"Right Pan");
        newRadians =(totalRadians - (fixedX * totalRadians));
        fixedRad = rightRadiansAmountOfScale - newRadians;
    }
    
    //NSLog(@"fixedRad: %f",fixedRad);
    
    return fixedRad;
    
}


-(CGFloat)motionYFromNormalizedPitch:(CGFloat)nPitch
{
    CGFloat Y = nPitch;
    CGFloat fixedY;
    
    CGFloat percent;
    
    if (self.upAngle > self.downAngle) {
        // up is greater than down
        percent = ((self.downAngle/self.upAngle) * 100 );
    }
    else
    {
        percent = ((self.upAngle/self.downAngle) * 100 );
    }
    
    percent = percent*0.01;
    
    CGFloat limiter = 1.0 - percent;
    
    CGFloat totalRadians = RadiansFromDegrees((self.upAngle + self.downAngle));
    
    CGFloat topRadianAmountOfScale = limiter * totalRadians;
    CGFloat bottomRadiansAmountOfScale = totalRadians - topRadianAmountOfScale;
    
    CGFloat newRadians;
    
    if (Y < 0) {
        fixedY = ((1.0 - (Y * -1.0))/2);
    }
    else
    {
        fixedY = 0.5 + (0.5 * Y);
    }
    
    CGFloat fixedRad;
    
    if (fixedY < limiter) {
        // NSLog(@"Top Pan");
        newRadians = fixedY * totalRadians;
        fixedRad = topRadianAmountOfScale - newRadians;
    }
    else
    {
        // NSLog(@"Bottom Pan");
        newRadians =(totalRadians - (fixedY * totalRadians));
        fixedRad = bottomRadiansAmountOfScale - newRadians;
    }
    
    return fixedY;
}


-(void)didMove
{
    NSLog(@"JDM Motion did move");
}


// make into a helper in tools
//-(void)logAttitude:(CMAttitude*)attitude
//{
//    NSString *attitudeString = [NSString stringWithFormat:@"Attitude:\nRoll:%@\nPitch:%@\nYaw:%@\n\n", floatString(attitude.roll),floatString(attitude.pitch),floatString(attitude.yaw)];
//    NSLog(@"%@",attitudeString);
//
//}


@end
