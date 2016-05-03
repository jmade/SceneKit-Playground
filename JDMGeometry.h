//
//  JDMGeometry.h
//  SceneKit Playground
//
//  Created by Justin Madewell on 3/26/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDMUtility.h"


@import SceneKit;
@import SpriteKit;
@import GLKit;

// Point
typedef struct {
    float x, y, z;
} JDMGeometryPoint;

// Line
typedef struct {
    JDMGeometryPoint start,end;
} JDMGeometryLine;

// Triangle
typedef struct {
    JDMGeometryLine lineAB,lineBC,lineCB;
} JDMGeometryTriangle;

// Initializers for Stucts
// Point
JDMGeometryPoint makePoint(float x,float y,float z)
{
    JDMGeometryPoint point;
    point.x = x;
    point.y = y;
    point.z = z;
    
    return point;
}

// Line
JDMGeometryLine makeLine(JDMGeometryPoint start, JDMGeometryPoint end)
{
    JDMGeometryLine line;
    line.start = start;
    line.end = end;
    
    return line;
}

// Triangle
JDMGeometryTriangle makeTriangle(JDMGeometryPoint pointA,JDMGeometryPoint pointB,JDMGeometryPoint pointC)
{
    JDMGeometryTriangle triangle;
    
    JDMGeometryLine lineab = makeLine(pointA, pointB);
    triangle.lineAB = lineab;
    
    JDMGeometryLine linebc = makeLine(pointB, pointC);
    triangle.lineBC = linebc;
    
    JDMGeometryLine linecb = makeLine(pointC, pointA);
    triangle.lineCB = linecb;
    
    return triangle;
    
}




@interface JDMGeometry : NSObject

@property (nonatomic, strong) NSArray *indicies;
@property (nonatomic, strong) NSArray *vertices;
@property (nonatomic, strong) NSArray *normals;
@property (nonatomic, strong) NSArray *textcoords;


@end
