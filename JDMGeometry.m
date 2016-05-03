//
//  JDMGeometry.m
//  SceneKit Playground
//
//  Created by Justin Madewell on 3/26/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "JDMGeometry.h"

@implementation JDMGeometry


#pragma mark - Object Initialization

-(instancetype)init
{
    if ((self = [super init]))
    {
        
    }
    return self;
}

-(void)load
{
    JDMGeometryPoint pointAVector = makePoint(1.0, 1.0, 1.0);
    JDMGeometryPoint pointBVector = makePoint(-1.0, -1.0, -1.0);
    
    JDMGeometryLine line = makeLine(pointAVector, pointBVector);
    
    
    
}


@end


#pragma mark - Points
