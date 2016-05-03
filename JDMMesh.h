//
//  JDMMesh.h
//  SceneKit Playground
//
//  Created by Justin Madewell on 3/22/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JDMUtility.h"

@import SceneKit;
@import SpriteKit;
@import GLKit;


typedef struct {
    float x, y, z;
    float nx, ny, nz;
    float s, t;
} JDMMeshVertex;

typedef struct {
    float x, y, z;
} JDMMeshLinePoint;

@interface JDMMesh : NSObject

@property (nonatomic, strong) NSArray *indicies;
@property (nonatomic, strong) NSArray *vertices;
@property (nonatomic, strong) NSArray *normals;
@property (nonatomic, strong) NSArray *textcoords;

+(instancetype)makeMesh;
-(SCNGeometry*)mesh;

@end
