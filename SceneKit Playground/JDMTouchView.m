//
//  JDMTouchView.m
//  SceneKit Playground
//
//  Created by Justin Madewell on 2/1/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "JDMTouchView.h"

@implementation JDMTouchView


@synthesize lastTouchPoint,_horizontalScrollView, currentTouchPoint, lastX, lastY,normalizedX,normalizedY,startY,normalizedVerticalDragChange;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        
        // Steel Blue.
        self.backgroundColor = [UIColor colorWithRed:103/255.0f green:153/255.0f blue:170/255.0f alpha:1.0];
        
        [self initHorizontalScrollView:frame];
        [self initVerticalScrollView:frame];
        [self setup];
        
        
            }
    return self;
}







#pragma mark - Initialization Methods

-(void)setup
{
    // init all vars
    
    normalizedVerticalDragChange = 0.0;
    self.normalYNumber = @(0.0F);
    self.translationX = 0.0;
    
    
}


-(void)initVerticalScrollView:(CGRect)frame
{
    // Up and Down Scroller
    CGFloat scrollContentHeight = frame.size.height*2;
    CGSize scrollContentViewSize = CGSizeMake(frame.size.width, scrollContentHeight);
    CGRect scrollViewContentRect = CGRectMake(0, 0, scrollContentViewSize.width, scrollContentViewSize.height);
    
    UIView *contentView = [[UIView alloc]initWithFrame:scrollViewContentRect];
    contentView.backgroundColor = [UIColor yellowColor];
    contentView.layer.cornerRadius = contentView.frame.size.width/2;
    
    self._verticalScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height)];
    self._verticalScrollView.contentSize = scrollContentViewSize;
    self._verticalScrollView.delegate = self;
    self._verticalScrollView.showsVerticalScrollIndicator = YES;
    self._verticalScrollView.scrollEnabled = YES;
    [self._verticalScrollView setUserInteractionEnabled:NO];
    
    [self._verticalScrollView addSubview:contentView];
    // self._verticalScrollView.hidden = YES;
    
    CGFloat newContentOffsetY = (self._verticalScrollView.contentSize.height/2) - (self._verticalScrollView.bounds.size.height/2);
    self._verticalScrollView.contentOffset = CGPointMake(0, newContentOffsetY);
    
    [self addSubview:self._verticalScrollView];
    [self addGestureRecognizer:self._verticalScrollView.panGestureRecognizer];
    
}

-(void)initHorizontalScrollView:(CGRect)frame
{
    //  Left and Right Scroller
    CGFloat scrollContentWidth = frame.size.width*2;
    CGSize scrollContentViewSize = CGSizeMake(scrollContentWidth, frame.size.height);
    CGRect scrollViewContentRect = CGRectMake(0, 0, scrollContentViewSize.width, scrollContentViewSize.height);
    
    UIView *contentView = [[UIView alloc]initWithFrame:scrollViewContentRect];
    contentView.backgroundColor = [UIColor greenColor];
    contentView.layer.cornerRadius = contentView.frame.size.width/2;
    
    self._horizontalScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, frame.size.width, frame.size.height)];
    
    self._horizontalScrollView.contentSize = scrollContentViewSize;
    self._horizontalScrollView.delegate = self;
    self._horizontalScrollView.showsHorizontalScrollIndicator = YES;
    self._horizontalScrollView.scrollEnabled = YES;
    [self._horizontalScrollView setUserInteractionEnabled:NO];
    
    
    [self._horizontalScrollView addSubview:contentView];
    //self._horizontalScrollView.hidden = YES;
    
    CGFloat newContentOffsetX = (self._horizontalScrollView.contentSize.width/2) - (self._horizontalScrollView.bounds.size.width/2);
    
    self._horizontalScrollView.contentOffset = CGPointMake(newContentOffsetX, 0);
    
    [self addSubview:self._horizontalScrollView];
    [self addGestureRecognizer:self._horizontalScrollView.panGestureRecognizer];
    
}




#pragma mark - Touches


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentTouchPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    
//    [self._horizontalScrollView setContentOffset:CGPointMake(currentTouchPoint.x, 0) animated:YES];
//    [self._verticalScrollView setContentOffset:CGPointMake(0, currentTouchPoint.y) animated:YES];
    
    
    [super touchesBegan:touches withEvent:event];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    currentTouchPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    
//    [self._horizontalScrollView setContentOffset:CGPointMake(currentTouchPoint.x, 0) animated:YES];
//    [self._verticalScrollView setContentOffset:CGPointMake(0, currentTouchPoint.y) animated:YES];
    
    [super touchesMoved:touches withEvent:event];
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    lastTouchPoint = [[[touches allObjects] objectAtIndex:0] locationInView:self];
    
    [super touchesEnded:touches withEvent:event];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}




#pragma mark - Normalize

-(CGFloat)normalizeForY:(CGFloat)Y
{
   return  (Y - (self.frame.size.height/2)) / (self.frame.size.height/2);
}

-(CGFloat)normalizeForX:(CGFloat)X
{
    return  (X - (self.frame.size.width/2)) / (self.frame.size.width/2);
}


// dont need
-(void)normalizeOffsetForY:(CGFloat)Y
{
    CGFloat cenY = self.frame.size.height/2;
    // so that were negative above and positive below
    CGFloat trackingY = Y - cenY ;
    normalizedY = trackingY / cenY ;
    self.normalYNumber = [NSNumber numberWithFloat:normalizedY];
    //NSLog(@"normalizedY: %f",normalizedY);
    [self anylyzeVerticalMovement:normalizedY];
}



// dont need
-(void)normalizeScrollAmount:(CGFloat)offsetX
{
    CGFloat cen = self._horizontalScrollView.center.x;
    CGFloat amount = cen - offsetX;
    CGFloat normalized = amount/ -cen;
    CGFloat translation = normalized * cen;
    self.translationX = translation;
    
    // NSLog(@"X translation: %f",translation);
    
    
    // lastY =  [[_scrollView panGestureRecognizer] translationInView:_scrollView].y;
    
    //[self tiltCameraWithOffset:CGPointMake(translation, _lastY)];
    
}


-(void)anylyzeVerticalMovement:(CGFloat)normedY
{
    // Normalized Amount changed on each Drag;
    
    CGFloat result =  startY - normedY ;
    normalizedVerticalDragChange = result;
   
    if (result > 0.0) {
        // NSLog(@"UP");
    }
    if (result < 0.0) {
        // NSLog(@"DOWN");
    }
}





#pragma mark - Scroll View Delegate



-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self._horizontalScrollView) {
        //
        //[self normalizeScrollAmount:scrollView.contentOffset.x];
        CGFloat nX = [self normalizeForY:scrollView.contentOffset.x];
        NSLog(@"nX: %f",nX);
    }
    
    else if (scrollView == self._verticalScrollView) {
        //
        CGFloat nY = [self normalizeForY:scrollView.contentOffset.y];
        NSLog(@"nY: %f",nY);
        
    }
    
   
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}



@end
