//
//  JDMControlScrollView.m
//  SceneKit Playground
//
//  Created by Justin Madewell on 2/4/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "JDMControlScrollView.h"
#import "JDMMotionManager.h"

#import "JDMUtility.h"

@implementation JDMControlScrollView
{
    CGFloat snappedTopYRadians;
    CGFloat snappedBottomYRadians;
    UIView *snappedView;
    UILabel *snappedViewLabel;
    UILabel *snappedViewMessageLabel;
    NSString *snappedMessage;
    
    NSMutableArray *accumulator;
    BOOL isShowingStatusMessage;
    BOOL onBottom;
    JDMMotionManager *motionManager;
    
}

@synthesize label;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //Add Label
        CGRect labelRect = CGRectMake(0, 0, CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/3);
        label = [[UILabel alloc] initWithFrame:labelRect];
        [label setCenter:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [label setBackgroundColor:[UIColor blackColor]];
        [[label layer] setCornerRadius:labelRect.size.height/2];
        [[label layer] setMasksToBounds:YES];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setText:@" X:0.00,Y:0.00"];
        [label setTextColor:[UIColor whiteColor]];
        [self addSubview:label];
        
        // Setup ContentSize for Scrolling amount/feel
        CGFloat contentMultiplyer = 2.0;
        
        CGFloat contentW = CGRectGetWidth(self.frame)*contentMultiplyer;
        CGFloat contentH = CGRectGetHeight(self.frame)*contentMultiplyer;
        CGSize contentSize = CGSizeMake(contentW, contentH);
        [self setContentSize:contentSize];
        
        // Don't Show Scroll Bars
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        
        //add vertical gesture recognition
        UIPanGestureRecognizer *verticalPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(verticalPan:)];
        [self addGestureRecognizer:verticalPan];
        
        //add double tap gesture recognizer to re-center
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        //init the accumulator array
        accumulator = [NSMutableArray array];
        
        // to position to the center
        //[self setContentOffset:self.center animated:YES];
        //[self restore];
        
        // set default angles
        self.maxAngleUp = 90;
        self.maxAngleLeft = 90;
        self.maxAngleRight = 90;
        self.maxAngleDown = 90;
        
    }
    return self;
}


-(void)handleDoubleTap:(UITapGestureRecognizer*)tap
{
    
     [self restore];
    
}

-(void)resetScrollViewToCenter
{
    CGFloat W = self.contentSize.width/4;
    CGFloat H = self.contentSize.height/4;
    
    CGPoint offset = CGPointMake(W, H);
    
    [self setContentOffset:offset animated:NO];
    //NSLog(@"offset : %@",NSStringFromCGPoint(offset));
    
    

}

#pragma mark - Scrolling Actions

-(void)updateLabel
{
   
    [label setCenter:[self paralaxPoint:1.0]];
    label.text = [self updatedLabelString];
    
    //,    NSLog(@"self.contentOffset : %@",NSStringFromCGPoint(self.contentOffset));
    
    
}

-(CGFloat)fixedNormalX:(CGFloat)nX
{
    if (nX < 0) {
        nX = (nX+1)/2;
    }
    else
    {
        nX = (nX-1)/2+1;
    }
    
    nX = (1.0 - nX);
    
    return nX;
}

-(CGFloat)fixedNormalY:(CGFloat)nY
{
    if (nY < 0) {
        nY = (nY+1)/2;
    }
    else
    {
        nY = (nY+0.5)/2;
        nY = nY + 0.25;
    }
    
    return nY;

}

-(CGPoint)offsetPointFromNormal:(CGPoint)nPoint
{
    CGFloat X = [self fixedNormalX:nPoint.x];
    CGFloat Y = [self fixedNormalY:nPoint.y];
    
    CGFloat W = self.contentSize.width/2;
    CGFloat H = self.contentSize.height/2;
    
    CGFloat offsetX = X*W;
    CGFloat offsetY = Y*H;
    
    
    [self updateLabel];
    
    return CGPointMake((int)offsetX, (int)offsetY);
}

-(void)moveViaNormalPoint:(CGPoint)normalPoint
{
   CGFloat X = [self fixedNormalX:normalPoint.x];
   CGFloat Y = [self fixedNormalY:normalPoint.y];
    
    CGFloat W = self.contentSize.width/2;
    CGFloat H = self.contentSize.height/2;
    
    CGFloat offsetX = X*W;
    CGFloat offsetY = Y*H;
    
    CGPoint offset = CGPointMake((int)offsetX, (int)offsetY);
    NSLog(@"offset : %@",NSStringFromCGPoint(offset));
    
    // [self setContentOffset:offset animated:YES];
    
    
    

}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark - Restore Scroll View
-(void)restoreBottomSnapped
{
    [self setContentOffset:[self currentXBottomYPoint] animated:YES];
    onBottom = YES;
    
}

-(void)restore
{
    
    [self setContentOffset:self.center animated:YES];
    onBottom = NO;
}

//-(void)bottomBounceUp
//{
//    [self setContentOffset:[self bottomBounceUpPoint] animated:YES];
//}



#pragma mark - ContentOffsetPoint

-(CGPoint)offsetCenter
{
    CGPoint contentCenter = CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
    CGPoint offsetAmountPoint = [self offsetAmountOfCenter:self.contentOffset];
    CGPoint centeredOffset = CGPointMake(contentCenter.x+(offsetAmountPoint.x*0.75),contentCenter.y+(offsetAmountPoint.y+label.frame.size.height));
    return centeredOffset;
}

-(CGPoint)currentXBottomYPoint
{
    return CGPointMake([self contentOffset].x, 0);
}

-(CGPoint)bottomBounceUpPoint
{
    return CGPointMake([self contentOffset].x, 7);
}

-(CGPoint)currentXTopYPoint
{
    return CGPointMake([self contentOffset].x, self.frame.size.height);
}

-(CGPoint)currentXBottomPoint
{
    // current X position
    CGFloat X = [self contentOffset].x;
    
    // Center
    X = self.center.x;
    
    CGFloat Y = self.frame.size.height;
    
    return CGPointMake(X, Y);
}



// For Vertical ScrollViewContentOffsetManipulation.
- (void)verticalPan :(UIPanGestureRecognizer *) sender {
    
    
}


#pragma mark - Utilites
-(CGPoint)offsetAmountOfCenter:(CGPoint)offset
{
    CGPoint offsetAmount;
    CGPoint cen = self.center;
    // X
    CGFloat xMultiplyer;
    CGFloat xDiff;
    
    // check to see if the new point is to the left(-) or right(+) of center
    if (offset.x > cen.x) {
        // Moving to the Right
        xDiff = offset.x - cen.x ;
        xMultiplyer = 1.0;
    }
    else
    {
        // Left
        xDiff = cen.x - offset.x ;
        xMultiplyer = -1.0;
    }
    
    xDiff = (xDiff * xMultiplyer);
    
    // Y
    CGFloat yMultiplyer;
    CGFloat yDiff;
    // check to see if the new point is to the left(-) or right(+) of center
    if (offset.y > cen.y) {
        // Moving Up
        yDiff = offset.y - cen.y ;
        yMultiplyer = 1.0;
    }
    else
    {
        // Moving Down
        yDiff = cen.y - offset.y ;
        yMultiplyer = -1.0;
    }

    yDiff = (yDiff * yMultiplyer);

    offsetAmount = CGPointMake(xDiff, yDiff);
    
    return offsetAmount;
}

// need to fix
// currently it only cuts the amount of size of rectangle it should scroll not the speed of the scroll ?
-(CGPoint)paralaxPoint:(CGFloat)paralaxAmount;
{
    CGPoint offsetAmountPoint = [self offsetAmountOfCenter:self.contentOffset];
    
    // Find out how may times the label can fit into the window, then we can manipulte the number.
    CGFloat xDivisor = self.frame.size.width / label.frame.size.width ;
    CGFloat yDivisor = self.frame.size.height / label.frame.size.height ;
    
    // halftime scroll effect == 1.0;
    CGFloat pMultiplyer = paralaxAmount;
    
    // Assing the new Manipulated Value
    xDivisor = xDivisor * pMultiplyer;
    yDivisor = yDivisor * pMultiplyer;
    
    
    CGPoint contentCenter = CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
    
    CGFloat px = contentCenter.x + (offsetAmountPoint.x / xDivisor);
    CGFloat py = contentCenter.y+ (offsetAmountPoint.y / yDivisor);
    
    // New point
    return CGPointMake(px, py);
}

-(CGPoint)stickyCenteredPoint
{
    CGPoint contentCenter = CGPointMake(self.contentSize.width/2, self.contentSize.height/2);
    CGPoint offsetAmountPoint = [self offsetAmountOfCenter:self.contentOffset];
    return CGPointMake(contentCenter.x+offsetAmountPoint.x,contentCenter.y+offsetAmountPoint.y);
}

-(NSString*)snappedBottomString
{
     return [NSString stringWithFormat:@"Panning X:%@",[NSString stringWithFormat:@"X:%@",floatString([self normalizeForX:self.contentOffset.x])]];
}


-(NSString*)updatedLabelString
{
    return [NSString stringWithFormat:@"%@,%@",[NSString stringWithFormat:@"X:%@",floatString([self normalizeForX:self.contentOffset.x])],[NSString stringWithFormat:@"Y:%@",floatString([self normalizeForY:self.contentOffset.y])]];
}

-(CGFloat)normalizeForY:(CGFloat)Y
{
    return  ((Y - (self.frame.size.height/2)) / (self.frame.size.height/2) * -1);
}

-(CGFloat)normalizeForX:(CGFloat)X
{
    return  ((X - (self.frame.size.width/2)) / (self.frame.size.width/2) * -1);
}

-(CGPoint)normalizedOffset
{
    return CGPointMake([self normalizeForX:self.contentOffset.x], [self normalizeForY:self.contentOffset.y]);
}

-(int)normalizedQuadrant
{
    CGPoint n  = [self normalizedOffset];
    
    int quadrant = 0;
    // 0=Left, 1=Right.
    CGFloat xSide = 1.0;
    CGFloat ySide = 1.0;
    
    if (n.x > 0) {
        xSide = 0;
    }
    
    if (n.y > 0) {
        ySide = 0;
    }
    
    CGFloat left = 0;
    //CGFloat right = 1;
    CGFloat up = 0;
    //CGFloat down = 1;
    
    if (xSide == left) {
        //
        if (ySide == up) {
            // top Left
            quadrant = 0;
        }
        else
        {
            //bottom Left
            quadrant = 2;
        }
    }
    else
    {
        // xSide==right
        if (ySide == up) {
            // top Right
            quadrant = 1;
        }
        else
        {
            //bottom Right
            quadrant = 3;
        }

    }
    
    
    // catch if its centered
    
    if (CGPointEqualToPoint(n, CGPointZero)) {
        quadrant = 0;
    }
    
    // flip flop ???
    
    int flippedQuad = 0;
    
    if (quadrant == 3) {
        flippedQuad = 0;
    }
    if (quadrant == 2) {
        flippedQuad = 1;
    }
    if (quadrant == 1) {
        flippedQuad = 2;
    }
    if (quadrant == 0) {
        flippedQuad = 3;
    }
    
    return flippedQuad;
}


#pragma mark - Angel

-(CGFloat)angleFromOffsetX
{
    
    CGFloat nx = [self normalizedOffset].x;
    
    CGFloat degrees = self.maxAngleRight;
    
    if (nx > 0) {
        degrees = self.maxAngleLeft;
    }
    
    CGFloat radians = RadiansFromDegrees(degrees);
    CGFloat normalizedRadians = radians * [self normalizedOffset].x;
   
    return normalizedRadians;
}

-(CGFloat)angleFromOffsetY
{
    CGFloat ny = [self normalizedOffset].y;
    
    CGFloat degrees = self.maxAngleDown;
    
    if (ny < 0) {
        degrees = self.maxAngleUp;
    }
    
    CGFloat radians = RadiansFromDegrees(degrees);
    CGFloat normalizedRadians = radians *  ny;
    
    return normalizedRadians;
}


-(CGFloat)rescaledX
{
    CGFloat X = [self normalizedOffset].x;
    CGFloat fixedX;
    
    CGFloat angleSpan = self.maxAngleLeft + self.maxAngleRight;
    
    if (X < 0) {
        fixedX = ((1.0 - (X * -1.0))/2);
    }
    else
    {
        fixedX = 0.5 + (0.5 * X);
    }
    
    // NSLog(@"fixedX: %f",fixedX);
    return fixedX;
}

-(CGPoint)rescaledOffset
{
    return CGPointMake([self rescaledX], [self rescaledY]);
}

-(CGFloat)radiansY
{
        CGFloat Y = [self normalizedOffset].y;
        CGFloat fixedY;
        
    // CGFloat angleSpan = self.maxAngleUp + self.maxAngleDown;
        
        CGFloat percent;
        
        if (self.maxAngleUp > self.maxAngleDown) {
            // up is greater than down
            percent = ((self.maxAngleDown/self.maxAngleUp) * 100 );
        }
        else
        {
            percent = ((self.maxAngleUp/self.maxAngleDown) * 100 );
        }
        
        percent = percent*0.01;
        //NSLog(@"percent: %f",percent);
        
        CGFloat limiter = 1.0 - percent;
        //  NSLog(@"limiter: %f",limiter);
        
        CGFloat totalRadians = RadiansFromDegrees((self.maxAngleUp + self.maxAngleDown));
        
        CGFloat topRadianAmountOfScale = limiter * totalRadians;
        CGFloat bottomRadiansAmountOfScale = totalRadians - topRadianAmountOfScale;
        // NSLog(@"topRadianAmountOfScale: %f",topRadianAmountOfScale);
        
    // NSLog(@"UP(%f)/TR(%f)",topRadianAmountOfScale,totalRadians);
        
        CGFloat newRadians;
        
        if (Y < 0) {
            fixedY = ((1.0 - (Y * -1.0))/2);
        }
        else
        {
            fixedY = 0.5 + (0.5 * Y);
        }
        
    //NSLog(@"fixedY: %f",fixedY);
        CGFloat fixedRad;
        
        if (fixedY < limiter) {
            //NSLog(@"Top Pan");
            newRadians = fixedY * totalRadians;
            fixedRad = topRadianAmountOfScale - newRadians;
        }
        else
        {
            // NSLog(@"Bottom Pan");
            newRadians =(totalRadians - (fixedY * totalRadians));
            fixedRad = bottomRadiansAmountOfScale - newRadians;
            fixedRad = (fixedRad * -1.0);
        }
        
        //NSLog(@"fixedRad: %f",fixedRad);
        
        return -fixedRad;

}

-(CGPoint)radianOffsetPoint
{
    CGFloat Y = [self radiansY];
    
    if (self.isSnapped) {
        NSLog(@"We are snapped");
        Y = ((RadiansFromDegrees(self.maxAngleDown)) * 1.0);
        
    }
    
    //NSLog(@"Y: %f",Y);
    
    
    return CGPointMake([self radiansX],Y);
}

-(CGFloat)radiansX
{
    CGFloat X = [self normalizedOffset].x;
    CGFloat fixedX;
    
    //CGFloat angleSpan = self.maxAngleLeft + self.maxAngleRight;
    
    CGFloat percent;
    
    if (self.maxAngleLeft < self.maxAngleRight) {
        // up is greater than down
        percent = ((self.maxAngleRight/self.maxAngleLeft) * 100 );
    }
    else
    {
        percent = ((self.maxAngleLeft/self.maxAngleRight) * 100 );
    }
    
    if (self.maxAngleLeft == self.maxAngleRight) {
        percent = 50.0;
    }
    
    percent = percent*0.01;
    //  NSLog(@"percent: %f",percent);
    
    CGFloat limiter = 1.0 - percent;
    // NSLog(@"limiter: %f",limiter);
    
    CGFloat totalRadians = RadiansFromDegrees((self.maxAngleLeft + self.maxAngleRight));
    
    CGFloat leftRadianAmountOfScale = limiter * totalRadians;
    CGFloat rightRadiansAmountOfScale = totalRadians - leftRadianAmountOfScale;
    // NSLog(@"LeftRadianAmountOfScale: %f",leftRadianAmountOfScale);
    
    //  NSLog(@"Left(%f)/TR(%f)",leftRadianAmountOfScale,totalRadians);
    
    CGFloat newRadians;
    
    if (X < 0) {
        fixedX = ((1.0 - (X * -1.0))/2);
    }
    else
    {
        fixedX = 0.5 + (0.5 * X);
    }
    
    // NSLog(@"fixedX: %f",fixedX);
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



-(CGFloat)rescaledY
{
    CGFloat Y = [self normalizedOffset].y;
    CGFloat fixedY;
    
    CGFloat percent;
    
    if (self.maxAngleUp > self.maxAngleDown) {
        // up is greater than down
        percent = ((self.maxAngleDown/self.maxAngleUp) * 100 );
    }
    else
    {
         percent = ((self.maxAngleUp/self.maxAngleDown) * 100 );
    }
    
    percent = percent*0.01;
    
    CGFloat limiter = 1.0 - percent;
    
    CGFloat totalRadians = RadiansFromDegrees((self.maxAngleUp + self.maxAngleDown));
    
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

-(void)scaleDegrees
{
    CGFloat Y = [self normalizedOffset].y;
    CGFloat fixedY;
    
    // CGFloat angleSpan = self.maxAngleUp + self.maxAngleDown;
    
    if (Y < 0) {
        fixedY = (Y * -1.0);
        fixedY = 1.0 - fixedY;
    }
    else
    {
        fixedY = 0.5 + (0.5 * Y);
    }
    
    NSLog(@"fixedY: %f",fixedY);
}

-(CGFloat)testXAngle
{
    CGFloat nx = [self normalizedOffset].x;
    
    CGFloat totalDegrees = (self.maxAngleLeft + self.maxAngleRight);
    //NSLog(@"totalDegrees: %f",totalDegrees);
    
    
    /*
     CGFloat degrees = self.maxAngleDown;
     
     if (ny < 0) {
     degrees = self.maxAngleUp;
     }
     */
    
    CGFloat radians = RadiansFromDegrees(totalDegrees);
    //NSLog(@"radians: %f",radians);
    
    CGFloat normalizedRadians = (radians/2) *  nx;
    
    return normalizedRadians;
    
}

-(CGFloat)testYAngle
{
    CGFloat ny = [self normalizedOffset].y;
    
    CGFloat totalDegrees = self.maxAngleDown + self.maxAngleUp;
    
    CGFloat totalRad = RadiansFromDegrees(totalDegrees);
    // NSLog(@"totalRad: %f",totalRad);
    
    
    CGFloat maxDownRad = RadiansFromDegrees(self.maxAngleDown);
    // NSLog(@"maxDownRad: %f",maxDownRad);
    
    CGFloat maxUpRad = RadiansFromDegrees(self.maxAngleUp);
    // NSLog(@"maxUpRad: %f",maxUpRad);
    
    
    CGFloat radians = RadiansFromDegrees(totalDegrees);
    // NSLog(@"Yradians: %f",radians);
    
    CGFloat normalizedRadians = (radians/2) *  ny;
    //  NSLog(@"normalizedRadians: %f",normalizedRadians);
    
    
    return normalizedRadians;
    
}







-(CGPoint)normalizedAngle
{
    return CGPointMake([self testXAngle], [self testYAngle]);
}


-(CGFloat)motionYAngle
{
    CGFloat ny = motionManager.nPitch;
    
    CGFloat totalDegrees = self.maxAngleDown + self.maxAngleUp;
    
    CGFloat totalRad = RadiansFromDegrees(totalDegrees);
    // NSLog(@"totalRad: %f",totalRad);
    
    
    CGFloat maxDownRad = RadiansFromDegrees(self.maxAngleDown);
    // NSLog(@"maxDownRad: %f",maxDownRad);
    
    CGFloat maxUpRad = RadiansFromDegrees(self.maxAngleUp);
    // NSLog(@"maxUpRad: %f",maxUpRad);
    
    
    CGFloat radians = RadiansFromDegrees(totalDegrees);
    // NSLog(@"Yradians: %f",radians);
    
    CGFloat normalizedRadians = (radians/2) *  ny;
    //  NSLog(@"normalizedRadians: %f",normalizedRadians);
    
    
    return normalizedRadians;
}


-(CGPoint)motionAngle
{
    return CGPointMake(0, [self motionYAngle]);
}


// custom normalized point to return ?
-(CGPoint)normalizedTouchLocation
{
    return CGPointMake([self normalizeForX:self.contentOffset.x], [self normalizeForY:self.contentOffset.y]);
}

@end
