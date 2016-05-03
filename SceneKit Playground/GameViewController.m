//
//  GameViewController.m
//  SceneKit Playground
//
//  Created by Justin Madewell on 1/26/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "GameViewController.h"
#import "JDMTouchView.h"

#import "JDMMotionManager.h"
#import "JDMUtility.h"
#import "JDMNode.h"



#import "JDMControlScrollView.h"

@import Accelerate;
@import SpriteKit;
@import AVFoundation;
@import CoreMotion;

#define CAM_DIST_Y 60

#define radiansToDegrees(x) (180/M_PI)*x
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

const BOOL ShouldUseVideoFromDevicesCamera = YES;


@implementation GameViewController
{
    JDMNode *characterNode;
    
    
    // AVStuff
    UIView *viewPreview;
    AVCaptureSession *captureSession;
    AVCaptureVideoPreviewLayer *videoPreviewLayer;
    AVAudioPlayer *audioPlayer;
    BOOL isReading;
    CALayer *avLayer;
    
    //
    dispatch_queue_t sampleQueue;
    AVCaptureVideoPreviewLayer *previewLayer;
    SKTexture *camTexture;
    SKVideoNode *videoNode;
    UIImage *imageFromVideo;
    
    SCNNode *boxNode;
    SCNGeometry *originalGeometry;
    SCNGeometry *reflectiveGeometry;
    UISwitch *reflectivitySwitch;
    UISwitch *labelSwitch;
    
    
    
    
    
    JDMTouchView *_touchView;
    JDMControlScrollView *_controlScrollView;
    JDMMotionManager *_motionManager;
    
    UIView *controlsView;
    
    CGFloat originalHoldingPitch;
    CGFloat originalHoldingRoll;
    CGFloat originalHoldingYaw;
    
    
    SCNNode *_cameraNode;
    SCNNode *_cameraPitch ;
    SCNNode *_cameraHandle ;
    SCNNode *_boxNode;
    SCNNode *_legoNode;
    
    UILabel *belowLabel_1;
    UILabel *belowLabel_2;
    UILabel *belowLabel_3;
    
    UILabel *controlsUpAngle;
    UILabel *controlsDownAngle;
    UILabel *controlsLeftAngle;
    UILabel *controlsRightAngle;
    
    UILabel *controlsPitchRange;
    UILabel *controlsRollRange;
    
    UILabel *bbLabel;
    BOOL isInCameraMode;
    
    UIStepper *stepperUp;
    UIStepper *stepperDown;
    UIStepper *stepperLeft;
    UIStepper *stepperRight;
    
    UIStepper *stepperPitch;
    UIStepper *stepperRoll;
    
    CGFloat upAngle;
    CGFloat downAngle;
    CGFloat leftRightAngle;
    
    UIView *belowView;
    
    CGFloat _lastY;
    
    UILabel *motionlabel;

    CGFloat lastPitch;
    CGFloat lastRoll;
    CGFloat lastYaw;
   
    
    //camera manipulation
    SCNVector3 _cameraBaseOrientation;
    CGPoint    _initialOffset, _lastOffset;
    SCNMatrix4 _cameraHandleTransforms;
    SCNMatrix4 _cameraOrientationTransforms;
    dispatch_source_t _timer;
    BOOL zoomed;
    
    BOOL moveCameraWithMotion;
}

#pragma mark - AV

// Return the Front Facing Camera
- (AVCaptureDevice *)frontCamera {
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([device position] == AVCaptureDevicePositionFront) {
            return device;
        }
    }
    
    return [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
}


-(void)initAV
{
    
    captureSession = [[AVCaptureSession alloc] init];
    
    [captureSession setSessionPreset:AVCaptureSessionPreset640x480];
   
    AVCaptureDevice *device = [self frontCamera];
    
    if (!device) {
        NSLog(@"Couldn't get a camera.");
        return;
    }
    
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device
                                                                         error:&error];
    
   
    
    if (input) {
        [captureSession addInput:input];
        
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [output setVideoSettings:@{ (id)kCVPixelBufferPixelFormatTypeKey: @(kCMPixelFormat_32BGRA)}];
        sampleQueue = dispatch_queue_create("VideoSampleQueue", DISPATCH_QUEUE_SERIAL);
        
        [output setSampleBufferDelegate:self queue:sampleQueue];
        [captureSession addOutput:output];
        
        [captureSession startRunning];
        NSLog(@"Running video ");
    } else {
        NSLog(@"Couldn't initialize device input: %@", error);
    }
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
   
    
    
    if (reflectivitySwitch.isOn) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
//        
        UIImage *img = [self imageFromSampleBuffer:sampleBuffer];
        imageFromVideo = img;
        SCNGeometry *newGeo = ReturnGeometryOfType(ShapeTypeBox,5);
        newGeo.firstMaterial.diffuse.contents = [UIColor grayColor];
        newGeo.firstMaterial.shininess = 60;
        newGeo.firstMaterial.reflective.contents = imageFromVideo;
        newGeo.firstMaterial.reflective.intensity = 0.89;
  
        
        [boxNode setGeometry:newGeo];

    }
    
    
    
    
};

- (void)captureOutput:(AVCaptureOutput *)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
}


// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    
    UIImage *image = [[UIImage alloc] initWithCGImage:quartzImage scale:(CGFloat)1.0 orientation:UIImageOrientationLeft];
    
    
    
    // CVImageBufferRef cvImage = CMSampleBufferGetImageBuffer(sampleBuffer);
    // CIImage *ciImage = [CIImage imageWithCVPixelBuffer:cvImage];
    
    //  CIImage *ciImage = [CIImage imageWithCGImage:quartzImage];
    //UIImage *image = [UIImage imageWithCIImage:ciImage];

    
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    
    //  UIImage *image = [UIImage imageWithCGImage:quartzImage];
//    UIImage  *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationUp];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}








-(void)startStopCamera
{
    if (!isReading)
    {
        // This is the case where the app should read a QR code when the start button is tapped.
        if ([self startReading])
        {
            // If the startReading methods returns YES and the capture session is successfully
            // running, then change the start button title and the status message.
            
        }
    }
    else
    {
        // In this case the app is currently reading a QR code and it should stop doing so.
        [self stopReading];
        // The bar button item's title should change again.
        
    }
    
    // Set to the flag the exact opposite value of the one that currently has.
    isReading = !isReading;
}

- (BOOL)startReading {
    NSError *error;
    
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoPreviewLayer setFrame:viewPreview.layer.bounds];
    [viewPreview.layer addSublayer:videoPreviewLayer];
    
    avLayer = videoPreviewLayer;
    
    
    // Start video capture.
    [captureSession startRunning];
    
    return YES;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [captureSession stopRunning];
    captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [videoPreviewLayer removeFromSuperlayer];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // AV
    // Initially make the captureSession object nil.
    //captureSession = nil;
    
    // Set the initial value of the flag to NO.
    // isReading = NO;
    viewPreview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 128, 128)];
    [self initAV];
    
    // create a new scene
    SCNScene *scene = [SCNScene scene];
    
    
    [self lights:scene];
    [self camera:scene];
    [self action:scene];
    
    lastPitch = 0.0;
    
    CGFloat y = (self.view.frame.size.height - ScreenWidth() ) / 2;
    
    CGRect aboveRect = CGRectMake(0, 0, ScreenWidth(), y);
    
    CGRect belowRect = CGRectMake(0, self.view.frame.size.height-y, ScreenWidth(), y);
    
    
    // TOP
    
    UIView *topView = [[UIView alloc]initWithFrame:aboveRect];
    topView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:topView];
    [topView addSubview:viewPreview];
    
    UITapGestureRecognizer *topDoubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTopDoubleTap:)];
    topDoubleTap.numberOfTapsRequired = 2;
    [topView addGestureRecognizer:topDoubleTap];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleTopSwipe:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    [topView addGestureRecognizer:swipeDown];
    
    
    
    motionlabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, aboveRect.size.width, aboveRect.size.height)];
    motionlabel.textAlignment = NSTextAlignmentCenter;
    motionlabel.textColor = [UIColor blueColor];
    motionlabel.text = @"Double Tap to Control With Motion";
    motionlabel.numberOfLines = 10;
    [topView addSubview:motionlabel];
    
    // Top Switches
    
    // Reflectivity Switch
    reflectivitySwitch = [[UISwitch alloc]initWithFrame:CGRectMake(10, 20, 1, 1)];
    reflectivitySwitch.onTintColor = [UIColor whiteColor];
    [reflectivitySwitch addTarget:self action:@selector(reflectivitySwitchFlicked:) forControlEvents:UIControlEventAllEvents];
    [topView addSubview:reflectivitySwitch];
    
    moveCameraWithMotion = NO;
    
    
       //BelowView
    belowView = [[UIView alloc]initWithFrame:belowRect];
    
    belowView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:belowView];
    
    [self setupMotion];
   
#pragma mark - Control Scroll View
    
    CGRect r = CGRectMake(0, 0, belowView.frame.size.width, belowView.frame.size.height);
    _controlScrollView = [[JDMControlScrollView alloc]initWithFrame:r];
    
    
    _controlScrollView.maxAngleUp = 60;
    _controlScrollView.maxAngleDown = 90;
    
    _controlScrollView.maxAngleLeft = 170;
    _controlScrollView.maxAngleRight = 170;
    
    [self setCameraScrollOffsets];
    
    self.pitchSpan = 20;
    self.rollSpan = 20;
    
    _controlScrollView.delegate = self;
    [belowView addSubview:_controlScrollView];
    
    [_controlScrollView restore];

    
    CGRect sceneFrame = CGRectMake(0, y, ScreenWidth(), ScreenWidth());
    SCNView *myScnView = [[SCNView alloc]initWithFrame:sceneFrame];
    [self.view addSubview:myScnView];
    
    // retrieve the SCNView
    SCNView *scnView = myScnView; //(SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = NO;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = NO;

    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
     UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]   initWithTarget:self action:@selector(handlePinch:)];
    [scnView addGestureRecognizer:pinchGesture];
    
    [self setupControlsView];
    

    
}

-(void)setCameraScrollOffsets
{
    _controlScrollView.maxAngleUp = 45;
    _controlScrollView.maxAngleDown = 5;
    
    _controlScrollView.maxAngleLeft = 60;
    _controlScrollView.maxAngleRight = 60;
}

-(void)reflectivitySwitchFlicked:(UISwitch*)refSwitch
{
    if (!reflectivitySwitch.isOn) {
        [boxNode setGeometry:originalGeometry];

    }
}

-(void)handleTopSwipe:(UISwipeGestureRecognizer*)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        [self showControlsView];
        [self refreshSteppers];
    }
}

-(void)handleControlSwipeUp:(UISwipeGestureRecognizer*)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        //up
        [self hideControlsView];
        [_controlScrollView restore];
       
       
        
    }
}

-(void)showControlsView
{
    
    CGRect showFrame = CGRectMake(0, 0, controlsView.frame.size.width, controlsView.frame.size.height);
    CGPoint showCenter = RectGetCenter(showFrame);
    
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.62 initialSpringVelocity:0.34 options:UIViewAnimationOptionTransitionNone animations:^{
        //
        [controlsView setCenter:showCenter];
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)hideControlsView
{
    
    CGRect hideFrame = CGRectMake(0, -controlsView.frame.size.height, controlsView.frame.size.width, controlsView.frame.size.height);
    CGPoint hideCenter = RectGetCenter(hideFrame);
    
//    CGFloat damp = randFloat(0.34, 0.73);
//    CGFloat vel = randFloat(0.24, 0.65);
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.67 initialSpringVelocity:0.45 options:UIViewAnimationOptionTransitionNone animations:^{
        [controlsView setCenter:hideCenter];
    } completion:^(BOOL finished) {
        //
    }];
}

-(void)fadeCameraSteppersIn
{
    stepperUp.hidden = NO;
    controlsUpAngle.hidden = NO;
    stepperDown.hidden = NO;
    controlsDownAngle.hidden = NO;
    stepperLeft.hidden = NO;
    controlsLeftAngle.hidden = NO;
    stepperRight.hidden = NO;
    controlsRightAngle.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        //
        stepperPitch.alpha = 0.0;
        controlsPitchRange.alpha = 0.0;
        stepperRoll.alpha = 0.0;
        controlsRollRange.alpha = 0.0;
        //
        stepperUp.alpha = 1.0;
        controlsUpAngle.alpha = 1.0;
        stepperDown.alpha = 1.0;
        controlsDownAngle.alpha = 1.0;
        stepperLeft.alpha = 1.0;
        controlsLeftAngle.alpha = 1.0;
        stepperRight.alpha = 1.0;
        controlsRightAngle.alpha = 1.0;
        //
    } completion:^(BOOL finished) {
        //
        stepperPitch.hidden = YES;
        controlsPitchRange.hidden = YES;
        stepperRoll.hidden = YES;
        controlsRollRange.hidden = YES;
        //
    }];

}

-(void)fadeCameraSteppersOut
{
    stepperPitch.hidden = NO;
    controlsPitchRange.hidden = NO;
    stepperRoll.hidden = NO;
    controlsRollRange.hidden = NO;

    
    [UIView animateWithDuration:0.5 animations:^{
        //
        stepperUp.alpha = 0.0;
        controlsUpAngle.alpha = 0.0;
        stepperDown.alpha = 0.0;
        controlsDownAngle.alpha = 0.0;
        stepperLeft.alpha = 0.0;
        controlsLeftAngle.alpha = 0.0;
        stepperRight.alpha = 0.0;
        controlsRightAngle.alpha = 0.0;
        //
        stepperPitch.alpha = 1.0;
        controlsPitchRange.alpha = 1.0;
        stepperRoll.alpha = 1.0;
        controlsRollRange.alpha = 1.0;
        //

        
    } completion:^(BOOL finished) {
        //
        stepperUp.hidden = YES;
        controlsUpAngle.hidden = YES;
        stepperDown.hidden = YES;
        controlsDownAngle.hidden = YES;
        stepperLeft.hidden = YES;
        controlsLeftAngle.hidden = YES;
        stepperRight.hidden = YES;
        controlsRightAngle.hidden = YES;
        
    }];
}





#pragma mark - ScrollView Delegate
#pragma mark - Scroll View Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    
    if (!moveCameraWithMotion) {
        [self tiltCameraWithNormalizedOffset:[_controlScrollView normalizedOffset]];
        [_controlScrollView updateLabel];

    }
    
    
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}


#pragma mark - Video Preview Layer

//-(CALayer*)videoPreviewLayer
//{
//    
//    
//    NSError *inputError = nil;
//    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    
//    AVCaptureDeviceInput * videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&inputError];
//    
//    if (!videoInput) {
//        // Look at `inputError` for information about the error
//        NSLog(@"Failed to get video input, with error: %@",[inputError localizedDescription]);
//        return nil;
//    }
//    
//    AVCaptureSession *captureSession= [AVCaptureSession new];
//    if ([captureSession canAddInput:videoInput]) {
//        [captureSession addInput:videoInput];
//    }
//    else
//    {
//        // Handle the case where there is no input to work with
//        NSLog(@"Can't add video input to capture session.");
//        return nil;
//    }
//    
//    CGFloat textureSize = 256.0;
//    AVCaptureVideoPreviewLayer *cameraPreview = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
//    
//    cameraPreview.frame = CGRectMake(0, 0, textureSize, textureSize);
//    
//
//    UIView *videoView =[[UIView alloc] init];
//    
//    videoView.frame = CGRectMake(0, 0, textureSize, textureSize);
//    [videoView.layer addSublayer:cameraPreview];
//    
//    
//    [captureSession startRunning];
//    
//    
//    return cameraPreview;
//    
//}






#pragma mark - Geometry Nodes

-(SCNNode*)backWall
{
    CGFloat wallNum = 350;
    CGSize backWallSize =  CGSizeMake(wallNum, wallNum/2);
    
    SCNGeometry *backWallGeo = [SCNPlane planeWithWidth:backWallSize.width height:backWallSize.height];
    
//    backWallGeo.firstMaterial.diffuse.contents = [self videoPreviewLayer];//[UIImage imageNamed:@"wood"];
//    backWallGeo.firstMaterial.reflective.contents = [self videoPreviewLayer];
    
    SCNNode *backWallNode = [SCNNode nodeWithGeometry:backWallGeo];
    backWallNode.name = @"backWallNode";
    
    backWallNode.position = SCNVector3Make(0, backWallSize.height/2, -40);
    
    return backWallNode;
}

-(SCNNode*)wallNodewithSize:(CGSize)wallSize
{
    
    CGFloat wallThickness = 1.0;
    
    SCNGeometry *wallGeo = [SCNBox boxWithWidth:wallThickness height:wallSize.height length:wallSize.width chamferRadius:0.0];
    
    wallGeo.firstMaterial.diffuse.contents = [UIColor lightGrayColor];
    
    
    SCNNode *wallNode = [SCNNode nodeWithGeometry:wallGeo];
    
    return wallNode;
    
}


-(SCNNode*)floorNode
{
    SCNNode *floorNode = [SCNNode node];
    floorNode.name = @"floorNode";
    
    
//    SKTexture *floorTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"floor"]];
//    SKTexture *floorTextureNormal = [floorTexture textureByGeneratingNormalMap];

    
    SCNMaterial *floorMat = [SCNMaterial material];
    floorMat.diffuse.contents = [UIColor grayColor];

    SCNFloor *floor = [SCNFloor floor];
    floor.reflectivity = 0.15;
    floor.reflectionFalloffEnd = 15;
    floor.firstMaterial = floorMat;
    
    floorNode.geometry = floor;
    
    return floorNode;
}

-(SCNNode*)boxNode
{
    
    CGFloat boxNum = 5;
    originalGeometry = ReturnGeometryOfType(ShapeTypeBox,boxNum);
    reflectiveGeometry = ReturnGeometryOfType(ShapeTypeBox,boxNum);
    // Material
    SKTexture *boxTexture = [SKTexture textureWithImage:[UIImage imageNamed:@"rock"]];
    SKTexture *boxTextureNormal = [boxTexture textureByGeneratingNormalMap];
    
    originalGeometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"rock"];
    originalGeometry.firstMaterial.normal.contents = boxTextureNormal;
    
    reflectiveGeometry.firstMaterial.diffuse.contents = [UIColor grayColor];
    reflectiveGeometry.firstMaterial.shininess = 60;
    reflectiveGeometry.firstMaterial.reflective.intensity = 0.89;
    
    
    boxNode = [SCNNode nodeWithGeometry:originalGeometry];
    boxNode.name = @"boxNode";
    boxNode.position = SCNVector3Make(0, boxNum/2, 0);
    boxNode.castsShadow = YES;
    
    return boxNode;
}


-(SCNNode*)legoBrickNode
{
    NSString *sceneName = @"art.scnassets/lego.scn";
    NSString *legoNodeName = @"lego";
    
    sceneName = @"art.scnassets/studlogo4.scn";
    legoNodeName = @"studlogo";
    
    
    SCNScene *legoScene = [SCNScene sceneNamed:sceneName];
    
    SCNNode *legoNode = [legoScene.rootNode childNodeWithName:legoNodeName recursively:YES];
    
    _legoNode = legoNode;
    _legoNode.geometry.firstMaterial = [self legoMat];
    
    
    return _legoNode;
}

-(SCNMaterial*)legoMat
{
    SCNMaterial *legoBrickMaterial = [SCNMaterial material];
    
    
    legoBrickMaterial.diffuse.contents = [UIColor whiteColor];
    legoBrickMaterial.shininess = 0.80;
    legoBrickMaterial.reflective.intensity = 0.89;
    

    
    return legoBrickMaterial;
}

-(void)addLegoNodeToScene:(SCNScene*)scene
{
    [scene.rootNode addChildNode:[self legoBrickNode]];
    
    _legoNode.position = SCNVector3Make(0,5,0);
    _legoNode.scale = SCNVector3Make(15, 15, 15);
    
    _legoNode.rotation = SCNVector4Make(1, 0, 0, RadiansFromDegrees(-135));
    //  _legoNode.rotation = SCNVector4Make(0, 1, 0, RadiansFromDegrees(45));
    
  
    
    SCNAction *tilt = [SCNAction rotateByAngle:RadiansFromDegrees(1440) aroundAxis:SCNVector3Make(1, 0, 0) duration:60.0];
    [_legoNode runAction:tilt];

}





#pragma mark - Action
-(void)action:(SCNScene*)scene
{
    
    [scene.rootNode addChildNode:[self boxNode]];
    
    
    [scene.rootNode addChildNode:[self floorNode]];
    
    CGSize wallSize = CGSizeMake(100, 50);
    
    SCNNode *wall = [self wallNodewithSize:wallSize];
    wall.position = SCNVector3Make(0, wallSize.height/2, -40);
    wall.rotation = SCNVector4Make(0, 1, 0, RadiansFromDegrees(90));
    
    [scene.rootNode addChildNode:wall];
}




#pragma mark - Lights
-(void)lights:(SCNScene*)scene
{
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    lightNode.castsShadow = YES;
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    ambientLightNode.castsShadow = YES;
    [scene.rootNode addChildNode:ambientLightNode];
}

#pragma mark - Camera
-(void)camera:(SCNScene*)scene
{
    

    
    _cameraHandle = [SCNNode node];
    _cameraHandle.name = @"cameraHandle" ;
    [scene.rootNode addChildNode:_cameraHandle];
    
    
    _cameraPitch = [SCNNode node];
    _cameraPitch.name = @"cameraPitch" ;
    [_cameraHandle addChildNode:_cameraPitch];
    
    _cameraNode = [SCNNode node];
    _cameraNode.name = @"cameraNode" ;
    _cameraNode.camera = [SCNCamera camera];
    
//    _cameraNode.camera.xFov = 70.0;
//    _cameraNode.camera.yFov = 30.0;
    
    [_cameraPitch addChildNode:_cameraNode];
    
    // place the camera
    _cameraNode.position = SCNVector3Make(0, 6, 20);
    zoomed = NO;
}





#pragma mark - Gestures

//restore the default camera orientation and position
- (void)restoreCameraAngle
{
    //reset drag offset
    _initialOffset = CGPointMake(0, 0);
    _lastOffset = _initialOffset;
    
    //restore default camera
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    _cameraHandle.eulerAngles = SCNVector3Make(0, 0, 0);
    [SCNTransaction commit];
}









-(void)tiltCameraWithNormalizedOffset:(CGPoint)normalizedOffset
{
    if (moveCameraWithMotion) {
        _cameraHandle.eulerAngles =  SCNVector3Make(-normalizedOffset.y, normalizedOffset.x, 0);
        
//        CGPoint offsetPoint =  [_controlScrollView offsetPointFromNormal:normalizedOffset];
//        
//        CGPoint fixedOffset = CGPointMake(offsetPoint.x, offsetPoint.y);
        
      
    }
    else
    {
        _cameraHandle.eulerAngles =  SCNVector3Make([_controlScrollView radianOffsetPoint].y, [_controlScrollView radianOffsetPoint].x, 0);
        //[_controlScrollView moveViaNormalPoint:normalizedOffset];
    }

}


-(void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if (zoomed == NO) {
        zoomed = YES;
        //move the camera IN
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration: 0.55];
        [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        // Change properties
        _cameraNode.position = SCNVector3Make(0, 3, 8);
        [SCNTransaction commit];
    }
    else
    {
        zoomed = NO;
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration: 0.75];
        [SCNTransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        // Change properties
        _cameraNode.position = SCNVector3Make(0, 6, 20);
        [SCNTransaction commit];
    }
}

-(void)handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    NSLog(@"Swiped");
}

-(void)handleSingleTap:(UITapGestureRecognizer *)singleTap
{
    
    // [self explodeOut];
    
    /*
     
     // retrieve the SCNView
     SCNView *scnView = (SCNView *)self.view;
     
     // check what nodes are tapped
     CGPoint p = [singleTap locationInView:scnView];
     NSArray *hitResults = [scnView hitTest:p options:nil];
     
     // check that we clicked on at least one object
     if([hitResults count] > 0){
     // retrieved the first clicked object
     SCNHitTestResult *result = [hitResults objectAtIndex:0];
     
     // Look At Contraint
     
     SCNLookAtConstraint *lookAt = [SCNLookAtConstraint lookAtConstraintWithTarget:result.node];
     //_cameraHandle.constraints = @[lookAt];
     
     
     // get its material
     SCNMaterial *material = result.node.geometry.firstMaterial;
     
     // highlight it
     [SCNTransaction begin];
     [SCNTransaction setAnimationDuration:0.5];
     
     // on completion - unhighlight
     [SCNTransaction setCompletionBlock:^{
     [SCNTransaction begin];
     [SCNTransaction setAnimationDuration:0.5];
     
     material.emission.contents = [UIColor blackColor];
     
     [SCNTransaction commit];
     }];
     
     material.emission.contents = [SKColor colorWithWhite:0.3 alpha:1.0];
     
     [SCNTransaction commit];
     }
     */
    
    
}

-(void)handleTopDoubleTap:(UITapGestureRecognizer*)tap
{
    
    
    if (moveCameraWithMotion == NO) {
        [_controlScrollView resetScrollViewToCenter];
        
        [tap.view setBackgroundColor:[UIColor orangeColor]];
        moveCameraWithMotion = YES;
        
    }
    else
    {
         [tap.view setBackgroundColor:[UIColor lightGrayColor]];
        moveCameraWithMotion = NO;
    }
    
    [self resetHoldingAngles];
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
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

-(void)setupMotion
{
    self.updateInterval = 0.01;
    [self initMotionManager];
    [self initAltimeter];
}


/* Initialize Motion Manager and set the Update Interval */
-(void)initMotionManager
{
    self.manager = [[CMMotionManager alloc] init];
    
    if (self.manager.deviceMotionAvailable)
    {
        self.manager.deviceMotionUpdateInterval = self.updateInterval;
        
    
        [self resetHoldingAngles];
        
        [self startManagerReadings];
    }
}

-(void)logAttitude:(CMAttitude*)attitude
{
    NSString *attitudeString = [NSString stringWithFormat:@"Attitude:\nRoll:%@\nPitch:%@\nYaw:%@\n\n", floatString(attitude.roll),floatString(attitude.pitch),floatString(attitude.yaw)];
    NSLog(@"%@",attitudeString);
    
}

-(void)startManagerReadings
{
    
    
    // Main Manager Call
    [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                 withHandler:^(CMDeviceMotion *data, NSError *error)
     {
         // action;
         self.motionData = data;
         
         // For First Run Only
         static int firstNumber;
         if (firstNumber == 0) {
             [self resetHoldingAngles];
         }
         firstNumber++;
         

        [self digestMotionData:data];
         
     }];
    
}

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
    // double rotation = atan2(data.gravity.x, data.gravity.y) - M_PI;
    
    // CGFloat magnitude = [self magnitudeFromAttitude:data.attitude];
    
    CMQuaternion quat = self.manager.deviceMotion.attitude.quaternion;
    CGFloat myRoll = radiansToDegrees(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
    CGFloat myPitch = radiansToDegrees(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
    CGFloat myYaw = radiansToDegrees(asin(2*quat.x*quat.y + 2*quat.w*quat.z));
    
    [self normalizePitch:myPitch andRoll:myRoll andYaw:myYaw];
    
}


-(void)resetHoldingAngles
{
    originalHoldingPitch = [self getCurrentPitch];
    originalHoldingRoll = [self getCurrentRoll];
}

-(void)normalizePitch:(CGFloat)pitch andRoll:(CGFloat)roll andYaw:(CGFloat)yaw
{

    CGFloat scaledPitch = ((pitch - originalHoldingPitch) * - 1);
    
    CGFloat tiltSpan = 0;
    tiltSpan = self.pitchSpan;
    
    scaledPitch = (scaledPitch/tiltSpan);
    //
    if(scaledPitch<-1.0){scaledPitch=-1.0;}
    if(scaledPitch>1.0){scaledPitch=1.0;}
    
    // try -1 ??
    CGFloat scaledRoll = ((roll - originalHoldingRoll) * 1);
    CGFloat rollSpan = 0;
    rollSpan = self.rollSpan;
    
    scaledRoll = (scaledRoll/rollSpan);
    
    if(scaledRoll<-1.0){scaledRoll=-1.0;}
    if(scaledRoll>1.0){scaledRoll=1.0;}
    
    CGFloat mY = [self motionYFromNormalizedPitch:scaledPitch];
    CGFloat mX = [self motionXFromNormalizedRoll:scaledRoll];
    
    //
    //
    
    CGPoint scaledPoint = CGPointMake(scaledRoll, scaledPitch);
    CGPoint fixedOffset =  [_controlScrollView offsetPointFromNormal:scaledPoint];
  
    CGPoint motionPoint = CGPointMake(mX, mY);
    
    NSString *intString = [NSString stringWithFormat:@"Roll: %i Pitch: %i Yaw: %i",(int)roll,(int)pitch,(int)yaw];
    
    NSString *scaledString = [NSString stringWithFormat:@"Scaled Roll: %@ Scaled Pitch: %@",floatString(scaledRoll),floatString(scaledPitch)];
    
    NSString *string = [NSString stringWithFormat:@"%@\n%@",intString,scaledString];

    
    
    if (moveCameraWithMotion) {
        // move camera
        [self tiltCameraWithNormalizedOffset:motionPoint];
        [_controlScrollView setContentOffset:fixedOffset animated:NO];
        motionlabel.text = string;

    }
    else
    {
         motionlabel.text = @"Double Tap to Control With Motion";
    }

    

    
}
// Conversion method

-(CGFloat)motionXFromNormalizedRoll:(CGFloat)nRoll
{
    CGFloat X = nRoll;
    CGFloat fixedX;
    
    //CGFloat angleSpan = self.maxAngleLeft + self.maxAngleRight;
    
    CGFloat percent;
    
    if (_controlScrollView.maxAngleLeft < _controlScrollView.maxAngleRight) {
        // up is greater than down
        percent = ((_controlScrollView.maxAngleRight/_controlScrollView.maxAngleLeft) * 100 );
    }
    else
    {
        percent = ((_controlScrollView.maxAngleLeft/_controlScrollView.maxAngleRight) * 100 );
    }
    
    if (_controlScrollView.maxAngleLeft == _controlScrollView.maxAngleRight) {
        percent = 50.0;
    }
    
    percent = percent*0.01;
    //  NSLog(@"percent: %f",percent);
    
    CGFloat limiter = 1.0 - percent;
    // NSLog(@"limiter: %f",limiter);
    
    CGFloat totalRadians = RadiansFromDegrees((_controlScrollView.maxAngleLeft + _controlScrollView.maxAngleRight));
    
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
    
    if (_controlScrollView.maxAngleUp > _controlScrollView.maxAngleDown) {
        // up is greater than down
        percent = ((_controlScrollView.maxAngleDown/_controlScrollView.maxAngleUp) * 100 );
    }
    else
    {
        percent = ((_controlScrollView.maxAngleUp/_controlScrollView.maxAngleDown) * 100 );
    }
    
    percent = percent*0.01;
    
    CGFloat limiter = 1.0 - percent;
    
    CGFloat totalRadians = RadiansFromDegrees((_controlScrollView.maxAngleUp + _controlScrollView.maxAngleDown));
    
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


#pragma mark - Controls View

-(void)setupControlsView
{
    CGFloat tall = (ScreenHeight() * 0.80);
    controlsView = [[UIView alloc]initWithFrame:CGRectMake(0, -tall, ScreenWidth(), tall)];
    
    controlsView.alpha = 1.0;
    controlsView.backgroundColor = [UIColor purpleColor];
    
    UISwipeGestureRecognizer *swipeAway = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleControlSwipeUp:)];
    swipeAway.direction = UISwipeGestureRecognizerDirectionUp;
    [controlsView addGestureRecognizer:swipeAway];
    
    [self.view addSubview:controlsView];
    
    [self fillControlsView];
    
}



-(void)fillControlsView
{
    NSInteger numberOfControls = 4;
    CGFloat halfWidth = controlsView.frame.size.width/2;
    CGFloat heightSegment = controlsView.frame.size.height/numberOfControls;
    
    // BottomBarView
    CGFloat bbH = (controlsView.frame.size.height * 0.10);
    CGSize bbSize = CGSizeMake(controlsView.frame.size.width,bbH);
    CGRect bottomBarRect = CGRectMake(0, controlsView.frame.size.height-bbH, bbSize.width, bbSize.height);
    UIView *bottomBarView = [[UIView alloc]initWithFrame:bottomBarRect];
    bottomBarView.backgroundColor = [UIColor yellowColor];
    [controlsView addSubview:bottomBarView];
    
    CGRect bbSwitchRect = CGRectMake(0, 0, 1, 1);
    UISwitch *bbSwitch = [[UISwitch alloc]initWithFrame:bbSwitchRect];
    bbSwitch.tintColor = [UIColor greenColor];
    bbSwitch.thumbTintColor = [UIColor purpleColor];
    bbSwitch.onTintColor = [UIColor greenColor];
    bbSwitch.on = YES;
    [bbSwitch addTarget:self action:@selector(bbSwitchFlicked:) forControlEvents:UIControlEventAllEvents];
    CGPoint cenOffset = CGPointMake(40, bottomBarView.frame.size.height/2);
    bbSwitch.center = cenOffset;
    [bottomBarView addSubview:bbSwitch];
    
    
    CGRect bbLabelRect = CGRectMake(0, 0, bottomBarView.frame.size.width, bottomBarView.frame.size.height);
    
    bbLabel = [[UILabel alloc]initWithFrame:bbLabelRect];
    bbLabel.textAlignment = NSTextAlignmentCenter;
    bbLabel.textColor = [UIColor purpleColor];
    bbLabel.text = @"Control Mode: Camera    ";
    [bottomBarView addSubview:bbLabel];
    
    CGSize workingSpaceSize = CGSizeMake(controlsView.frame.size.width,(controlsView.frame.size.height-bbH));
    
    // qtrView =
    CGFloat qtrViewWidth = workingSpaceSize.width/2;
    CGFloat qtrViewHeigth = workingSpaceSize.height/2;
    CGSize qtrViewSize = CGSizeMake(qtrViewWidth, qtrViewHeigth);
    
    CGPoint qtrPoint_1 = CGPointMake(0, 0);
    CGPoint qtrPoint_2 = CGPointMake(qtrViewSize.width, 0);
    CGPoint qtrPoint_3 = CGPointMake(0, qtrViewSize.height);
    CGPoint qtrPoint_4 = CGPointMake(qtrViewSize.width, qtrViewSize.height);
    
    // Rects
    CGRect qtrViewFrame_1 = CGRectMake(qtrPoint_1.x, qtrPoint_1.y, qtrViewSize.width, qtrViewSize.height);
    CGRect qtrViewFrame_2 = CGRectMake(qtrPoint_2.x, qtrPoint_2.y, qtrViewSize.width, qtrViewSize.height);
    CGRect qtrViewFrame_3 = CGRectMake(qtrPoint_3.x, qtrPoint_3.y, qtrViewSize.width, qtrViewSize.height);
    CGRect qtrViewFrame_4 = CGRectMake(qtrPoint_4.x, qtrPoint_4.y, qtrViewSize.width, qtrViewSize.height);
    
    
    controlsDownAngle = [self makeLabelWithFrame:qtrViewFrame_2];
    controlsLeftAngle = [self makeLabelWithFrame:qtrViewFrame_3];
    controlsRightAngle = [self makeLabelWithFrame:qtrViewFrame_4];
    controlsUpAngle = [self makeLabelWithFrame:qtrViewFrame_1];
    controlsUpAngle.text = @"1";
    controlsDownAngle.text = @"2";
    controlsLeftAngle.text = @"3";
    controlsRightAngle.text = @"4";
    
    stepperUp = [self makeStepperUnderCenter:controlsUpAngle.center];
    stepperDown = [self makeStepperUnderCenter:controlsDownAngle.center];
    stepperLeft = [self makeStepperUnderCenter:controlsLeftAngle.center];
    stepperRight = [self makeStepperUnderCenter:controlsRightAngle.center];
    [self refreshSteppers];
    
    // Pitch & Roll
    
    CGFloat ctlWidth = workingSpaceSize.width/2;
    CGFloat ctlHeight = workingSpaceSize.height+ (workingSpaceSize.height/2);
    CGSize ctlSize = CGSizeMake(ctlWidth, ctlHeight);
    
    CGRect ctlRect_1 = CGRectMake(0, 0, ctlSize.width,ctlSize.height);
    CGRect ctlRect_2 = CGRectMake(ctlSize.width, 0, ctlSize.width, ctlSize.height);
    
    controlsPitchRange = [self makeLabelWithFrame:ctlRect_1];
    controlsRollRange = [self makeLabelWithFrame:ctlRect_2];
    
    stepperPitch = [self makeStepperUnderCenter:controlsPitchRange.center];
    stepperRoll = [self makeStepperUnderCenter:controlsRollRange.center];
    
    stepperPitch.value = self.pitchSpan;
    stepperRoll.value = self.rollSpan;
    
    controlsPitchRange.alpha = 0.0;
    controlsRollRange.alpha = 0.0;
    stepperPitch.alpha = 0.0;
    stepperRoll.alpha = 0.0;
    
    controlsRollRange.hidden = YES;
    controlsPitchRange.hidden = YES;
    stepperPitch.hidden = YES;
    stepperRoll.hidden = YES;

}

-(void)refreshSteppers
{
    stepperUp.value = _controlScrollView.maxAngleUp;
    controlsUpAngle.text = [NSString stringWithFormat:@"UP\n\n%i",(int)stepperUp.value];
    stepperDown.value = _controlScrollView.maxAngleDown;
    controlsDownAngle.text=[NSString stringWithFormat:@"DOWN\n\n%i",(int)stepperDown.value];
    stepperLeft.value = _controlScrollView.maxAngleLeft;
    controlsLeftAngle.text=[NSString stringWithFormat:@"LEFT\n\n%i",(int)stepperLeft.value];
    stepperRight.value = _controlScrollView.maxAngleRight;
    controlsRightAngle.text=[NSString stringWithFormat:@"RIGHT\n\n%i",(int)stepperRight.value];
    
    controlsPitchRange.text = [NSString stringWithFormat:@"Pitch\n\n%i",(int)stepperPitch.value];
    controlsRollRange.text = [NSString stringWithFormat:@"Roll\n\n%i",(int)stepperRoll.value];
    
    
}



-(UIStepper*)makeStepperUnderCenter:(CGPoint)centerPointOfLabel
{
    
    CGPoint myCenter = CGPointMake(centerPointOfLabel.x, centerPointOfLabel.y + (controlsView.frame.size.height/6));
    
    UIStepper *stepper = [[UIStepper alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    stepper.minimumValue = 0.0;
    stepper.maximumValue = 90.0;
    stepper.stepValue = 1.0;
    stepper.value = 45.0;
    stepper.tintColor = [UIColor greenColor];
    [stepper addTarget:self action:@selector(stepperStepped:) forControlEvents:UIControlEventAllEvents];
    stepper.center = myCenter;
    [controlsView addSubview:stepper];
    return stepper;
}

-(UILabel*)makeLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 3;
    label.text = @"Text\nHere";
    
    [controlsView addSubview:label];
    
    CGPoint offsetCenterPoint = CGPointMake(RectGetCenter(frame).x,( RectGetCenter(frame).y - frame.size.height/4));
    label.center = offsetCenterPoint;
    
    return label;
}





-(void)stepperStepped:(UIStepper*)stepper
{
    if (stepper == stepperUp) {
        
        controlsUpAngle.text = [NSString stringWithFormat:@"UP\n\n%i",(int)stepperUp.value];
        _controlScrollView.maxAngleUp = stepperUp.value;
    }
    else if (stepper == stepperDown)
    {
        controlsDownAngle.text=[NSString stringWithFormat:@"DOWN\n\n%i",(int)stepperDown.value];
        _controlScrollView.maxAngleDown = stepperDown.value;
    }
    else if (stepper == stepperLeft)
    {
        controlsLeftAngle.text=[NSString stringWithFormat:@"LEFT\n\n%i",(int)stepperLeft.value];
        _controlScrollView.maxAngleLeft = stepperLeft.value;
    }
    else if (stepper == stepperRight)
    {
        controlsRightAngle.text=[NSString stringWithFormat:@"RIGHT\n\n%i",(int)stepperRight.value];
        _controlScrollView.maxAngleRight = stepperRight.value;
    }
    else if (stepper == stepperPitch)
    {
        // pitch
        controlsPitchRange.text = [NSString stringWithFormat:@"Pitch\n\n%i",(int)stepperPitch.value];
        self.pitchSpan = stepperPitch.value;
    }
    else if (stepper == stepperRoll)
    {
        // Roll
        controlsRollRange.text = [NSString stringWithFormat:@"Roll\n\n%i",(int)stepperRoll.value];
        self.rollSpan = stepperRoll.value;
    }
    
    // NSLog(@"stepper stepped");
}

-(void)didMove
{
    NSLog(@"did move from vc");
}


-(void)bbSwitchFlicked:(UISwitch*)flickedSwitch
{
    isInCameraMode = flickedSwitch.on;
    
    if (isInCameraMode) {
        [self fadeCameraSteppersIn];
        bbLabel.text = @"Control Mode: Camera    ";
    }
    else
    {
        [self fadeCameraSteppersOut];
        bbLabel.text = @"Control Mode: Controller";
    }
    NSLog(@"isInCameraMode value: %d", isInCameraMode);
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
