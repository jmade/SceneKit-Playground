//
//  ScratchGeometry.m
//  SceneKit Playground
//
//  Created by Justin Madewell on 3/13/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import <Foundation/Foundation.h>
@import SceneKit;
@import SpriteKit;
#import "Tools.h"


/*



-(SCNGeometry*)customCubeGeomety
{
    // Custom geometry data for a cube
    // --------------------------
    float cubeSide = 2.5;
    float halfSide = cubeSide/2.0;
    
    NSInteger vcount = 24;
    JDMVertex *vertices = malloc(sizeof(JDMVertex) * vcount);
    JDMVertex *v = vertices;
    
    // Vertices
    v->x = -halfSide, v->y = -halfSide, v->z =  halfSide,
    v->x =  halfSide, v->y = -halfSide, v->z =  halfSide,
    v->x = -halfSide, v->y = -halfSide, v->z = -halfSide,
    v->x =  halfSide, v->y = -halfSide, v->z = -halfSide,
    v->x = -halfSide, v->y =  halfSide, v->z =  halfSide,
    v->x =  halfSide, v->y =  halfSide, v->z =  halfSide,
    v->x = -halfSide, v->y =  halfSide, v->z = -halfSide,
    v->x =  halfSide, v->y =  halfSide, v->z = -halfSide,
    
    v->x = -halfSide, v->y = -halfSide, v->z =  halfSide,
    v->x =  halfSide, v->y = -halfSide, v->z =  halfSide,
    v->x = -halfSide, v->y = -halfSide, v->z = -halfSide,
    v->x =  halfSide, v->y = -halfSide, v->z = -halfSide,
    v->x = -halfSide, v->y =  halfSide, v->z =  halfSide,
    v->x =  halfSide, v->y =  halfSide, v->z =  halfSide,
    v->x = -halfSide, v->y =  halfSide, v->z = -halfSide,
    v->x =  halfSide, v->y =  halfSide, v->z = -halfSide,
    
    v->x = -halfSide, v->y = -halfSide, v->z =  halfSide,
    v->x =  halfSide, v->y = -halfSide, v->z =  halfSide,
    v->x = -halfSide, v->y = -halfSide, v->z = -halfSide,
    v->x =  halfSide, v->y = -halfSide, v->z = -halfSide,
    v->x = -halfSide, v->y =  halfSide, v->z =  halfSide,
    v->x =  halfSide, v->y =  halfSide, v->z =  halfSide,
    v->x = -halfSide, v->y =  halfSide, v->z = -halfSide,
    v->x =  halfSide, v->y =  halfSide, v->z = -halfSide;
    
    
    // normals
    
    float zero = 0;
    float one = 1;
    
    // up and down
    v->nx = zero, v->ny = -one, v->nz = zero ;
    v->nx = zero, v->ny = -one, v->nz = zero ;
    v->nx = zero, v->ny = -one, v->nz = zero ;
    v->nx = zero, v->ny = -one, v->nz = zero ;
    
    v->nx = zero, v->ny =  one, v->nz = zero ;
    v->nx = zero, v->ny =  one, v->nz = zero ;
    v->nx = zero, v->ny =  one, v->nz = zero ;
    v->nx = zero, v->ny =  one, v->nz = zero ;
    
    // back and forth
    v->nx = zero, v->ny = zero, v->nz = one ;
    v->nx = zero, v->ny = zero, v->nz = one ;
    v->nx = zero, v->ny = zero, v->nz = -one ;
    v->nx = zero, v->ny = zero, v->nz = -one ;
    
    v->nx = zero, v->ny = zero, v->nz = one ;
    v->nx = zero, v->ny = zero, v->nz = one ;
    v->nx = zero, v->ny = zero, v->nz = -one ;
    v->nx = zero, v->ny = zero, v->nz = -one ;
    
    // left and right
    v->nx = -one, v->ny = zero, v->nz = zero ;
    v->nx = one, v->ny = zero, v->nz = zero ;
    v->nx = -one, v->ny = zero, v->nz = zero ;
    v->nx = one, v->ny = zero, v->nz = zero ;
    
    v->nx = -one, v->ny = zero, v->nz = zero ;
    v->nx = one, v->ny = zero, v->nz = zero ;
    v->nx = -one, v->ny = zero, v->nz = zero ;
    v->nx = one, v->ny = zero, v->nz = zero ;
    
    // uvs
    v->s = zero, v->t = zero,
    v->s = one, v->t = zero,
    v->s = zero, v->t = one,
    v->s = one, v->t = one, //btm
    
    v->s = zero, v->t = one,
    v->s = one, v->t = one,
    v->s = zero, v->t = zero,
    v->s = one, v->t = zero, // top
    
    v->s = zero, v->t = one,
    v->s = one, v->t = one, // fr
    v->s = one, v->t = one,
    v->s = zero, v->t = one, // back
    
    v->s = zero, v->t = zero,
    v->s = one, v->t = zero, // fr
    v->s = one, v->t = zero,
    v->s = zero, v->t = zero, // back
    
    v->s = one, v->t = one, //l
    v->s = zero, v->t = one, //r
    v->s = zero, v->t = one, //l
    v->s = one, v->t = one, //r
    
    v->s = one, v->t = zero, //l
    v->s = zero, v->t = zero, //r
    v->s = zero, v->t = zero, //l
    v->s = one, v->t = zero; //r
    
    // Indices that turn the source data into triangles and lines
    // ----------------------------------------------------------
    
    int solidIndices[] = {
        // bottom
        0, 2, 1,
        1, 2, 3,
        // back
        10, 14, 11,  // 2, 6, 3,   + 8
        11, 14, 15,  // 3, 6, 7,   + 8
                     // left
        16, 20, 18,  // 0, 4, 2,   + 16
        18, 20, 22,  // 2, 4, 6,   + 16
                     // right
        17, 19, 21,  // 1, 3, 5,   + 16
        19, 23, 21,  // 3, 7, 5,   + 16
                     // front
        8,  9, 12,  // 0, 1, 4,   + 8
        9, 13, 12,  // 1, 5, 4,   + 8
                    // top
        4, 5, 6,
        5, 7, 6
    };
    
    int lineIndices[] = {
        // bottom
        0, 1,
        0, 2,
        1, 3,
        2, 3,
        // top
        4, 5,
        4, 6,
        5, 7,
        6, 7,
        // sides
        0, 4,
        1, 5,
        2, 6,
        3, 7,
        // diagonals
        0, 5,
        1, 7,
        2, 4,
        3, 6,
        1, 2,
        4, 7
    };
    
    // Creating the custom geometry object
    // ----------------------------------
    
    /*
     // Sources for the vertices, normals, and UVs
     SCNGeometrySource *vertexSource =
     [SCNGeometrySource geometrySourceWithVertices:vertices
     count:24];
     SCNGeometrySource *normalSource =
     [SCNGeometrySource geometrySourceWithNormals:normals
     count:24];
     
     SCNGeometrySource *uvSource =
     [SCNGeometrySource geometrySourceWithTextureCoordinates:UVs count:24];
     
     */
    ///
    ///
    /* New Sources */
    
    NSData *data = [NSData dataWithBytes:vertices length:vcount * sizeof(JDMVertex)];
    
    // Vertex source
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticVertex
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:0
                                                                     dataStride:sizeof(JDMVertex)];
    
    // Normal source
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(JDMVertex, nx)
                                                                     dataStride:sizeof(JDMVertex)];
    
    
    // Texture coordinates source
    SCNGeometrySource *texcoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:vcount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(JDMVertex, s)
                                                                       dataStride:sizeof(JDMVertex)];
    
    
    /* End New Sources */
    
    NSData *solidIndexData = [NSData dataWithBytes:solidIndices
                                            length:sizeof(solidIndices)];
    
    NSData *lineIndexData = [NSData dataWithBytes:lineIndices
                                           length:sizeof(lineIndices)];
    
    // Create one element for the triangles and one for the lines
    // using the two different buffers defined above
    SCNGeometryElement *solidElement =
    [SCNGeometryElement geometryElementWithData:solidIndexData
                                  primitiveType:SCNGeometryPrimitiveTypeTriangles
                                 primitiveCount:12
                                  bytesPerIndex:sizeof(int)];
    
    SCNGeometryElement *lineElement =
    [SCNGeometryElement geometryElementWithData:lineIndexData
                                  primitiveType:SCNGeometryPrimitiveTypeLine
                                 primitiveCount:18
                                  bytesPerIndex:sizeof(int)];
    
    
    
    // Create a geometry object from the sources and the two elements
    SCNGeometry *geometry =
    [SCNGeometry geometryWithSources:@[vertexSource, normalSource, texcoordSource]
                            elements:@[solidElement, lineElement]];
    
    SCNMaterial *solidMataterial = [SCNMaterial material];
    solidMataterial.diffuse.contents = [UIColor babyBlueColor];
    solidMataterial.locksAmbientWithDiffuse = YES;
    
    // ... and a white constant material for the lines
    SCNMaterial *lineMaterial = [SCNMaterial material];
    lineMaterial.diffuse.contents  = [UIColor whiteColor];
    lineMaterial.lightingModelName = SCNLightingModelConstant;
    
    geometry.materials = @[solidMataterial, lineMaterial];
    
    
    //    // Give the cube a light blue colored material for the solid part ...
    //    UIColor *lightBlueColor = [UIColor babyBlueColor];
    //
    //    SCNMaterial *solidMataterial = [SCNMaterial material];
    //    solidMataterial.diffuse.contents = lightBlueColor;
    //    solidMataterial.locksAmbientWithDiffuse = YES;
    //
    //    // ... and a white constant material for the lines
    //    SCNMaterial *lineMaterial = [SCNMaterial material];
    //    lineMaterial.diffuse.contents  = [UIColor whiteColor];
    //    lineMaterial.lightingModelName = SCNLightingModelConstant;
    //
    //    // geometry.materials = @[solidMataterial, lineMaterial];
    
    return geometry;
}



#pragma mark - Custom geometry

- (SCNGeometry *)mobiusStripWithSubdivisionCount:(NSInteger)subdivisionCount {
    NSInteger hSub = subdivisionCount;
    NSInteger vSub = subdivisionCount / 2;
    NSInteger vcount = (hSub + 1) * (vSub + 1);
    NSInteger icount = (hSub * vSub) * 6;
    
    
    ASCVertex *vertices = malloc(sizeof(ASCVertex) * vcount);
    unsigned short *indices = malloc(sizeof(unsigned short) * icount);
    
    // Vertices
    float sStep = 2.f * M_PI / hSub;
    float tStep = 2.f / vSub;
    ASCVertex *v = vertices;
    float s = 0.f;
    float cosu, cosu2, sinu, sinu2;
    
    for (NSInteger i = 0; i <= hSub; ++i, s += sStep) {
        float t = -1.f;
        for (NSInteger j = 0; j <= vSub; ++j, t += tStep, ++v) {
            sinu = sin(s);
            cosu = cos(s);
            sinu2 = sin(s/2);
            cosu2 = cos(s/2);
            
            v->x = cosu * (1 + 0.5 * t * cosu2);
            v->y = sinu * (1 + 0.5 * t * cosu2);
            v->z = 0.5 * t * sinu2;
            
            v->nx = -0.125 * t * sinu  + 0.5  * cosu  * sinu2 + 0.25 * t * cosu2 * sinu2 * cosu;
            v->ny =  0.125 * t * cosu  + 0.5  * sinu2 * sinu  + 0.25 * t * cosu2 * sinu2 * sinu;
            v->nz = -0.5       * cosu2 - 0.25 * cosu2 * cosu2 * t;
            
            // normalize
            float invLen = 1. / sqrtf(v->nx * v->nx + v->ny * v->ny + v->nz * v->nz);
            v->nx *= invLen;
            v->ny *= invLen;
            v->nz *= invLen;
            
            
            v->s = 3.125 * s / M_PI;
            v->t = t * 0.5 + 0.5;
        }
    }
    
    // Indices
    unsigned short *ind = indices;
    unsigned short stripStart = 0;
    for (NSInteger i = 0; i < hSub; ++i, stripStart += (vSub + 1)) {
        for (NSInteger j = 0; j < vSub; ++j) {
            unsigned short v1	= stripStart + j;
            unsigned short v2	= stripStart + j + 1;
            unsigned short v3	= stripStart + (vSub+1) + j;
            unsigned short v4	= stripStart + (vSub+1) + j + 1;
            
            *ind++	= v1; *ind++	= v3; *ind++	= v2;
            *ind++	= v2; *ind++	= v3; *ind++	= v4;
        }
    }
    
    NSData *data = [NSData dataWithBytes:vertices length:vcount * sizeof(ASCVertex)];
    free(vertices);
    
    // Vertex source
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticVertex
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:0
                                                                     dataStride:sizeof(ASCVertex)];
    
    // Normal source
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(ASCVertex, nx)
                                                                     dataStride:sizeof(ASCVertex)];
    
    
    // Texture coordinates source
    SCNGeometrySource *texcoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:vcount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(ASCVertex, s)
                                                                       dataStride:sizeof(ASCVertex)];
    
    
    // Geometry element
    NSData *indicesData = [NSData dataWithBytes:indices length:icount * sizeof(unsigned short)];
    free(indices);
    
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indicesData
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                               primitiveCount:icount/3
                                                                bytesPerIndex:sizeof(unsigned short)];
    
    // Create the geometry
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, normalSource, texcoordSource] elements:@[element]];
    
    // Add textures
    geometry.firstMaterial = [SCNMaterial material];
    geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"moebius"];
    geometry.firstMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    geometry.firstMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    geometry.firstMaterial.doubleSided = YES;
    geometry.firstMaterial.reflective.contents = [UIImage imageNamed:@"envmap"];
    geometry.firstMaterial.reflective.intensity = 0.3;
    
    return geometry;
}




-(SCNGeometry*)makeGeometry
{
    SCNGeometry *geo = ReturnGeometryOfType(ShapeTypeBox, 2);
    geo.firstMaterial = [self makeTexturedMaterial];
    
    return geo;
}



- (SCNGeometry *)customGeometry{
    
    NSArray *sources = @[
                         [SCNGeometrySource geometrySourceWithVertices: (SCNVector3[]){
                             {.x = -1.0f, .y = -1.0f, .z = 0.0f},
                             {.x = -1.0f, .y = 1.0f, .z = 0.0f},
                             {.x = 1.0f, .y = 1.0f, .z = 0.0f},
                             {.x = 1.0f, .y = -1.0f, .z = 0.0f}
                         } count:4],
                         [SCNGeometrySource geometrySourceWithNormals:(SCNVector3[]){
                             {.x = 0.0f, .y = 0.0f, .z = -1.0f},
                             {.x = 0.0f, .y = 0.0f, .z = -1.0f},
                             {.x = 0.0f, .y = 0.0f, .z = -1.0f},
                             {.x = 0.0f, .y = 0.0f, .z = -1.0f}
                         } count:4],
                         [SCNGeometrySource geometrySourceWithTextureCoordinates:(CGPoint[]){
                             {.x = 0.0f, .y = 0.0f},
                             {.x = 0.0f, .y = 1.0f},
                             {.x = 1.0f, .y = 1.0f},
                             {.x = 1.0f, .y = 0.0f}
                         } count:4]
                         ];
    
    NSArray *elements = @[
                          [SCNGeometryElement geometryElementWithData:[NSData dataWithBytes:(short[]){0, 2, 3,0,1,2} length:sizeof(short[6])]
                                                        primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                       primitiveCount:2
                                                        bytesPerIndex:sizeof(short)]];
    
    SCNGeometry *geo = [SCNGeometry geometryWithSources:sources elements:elements];
    
    SCNMaterial *mat = [SCNMaterial material];
    mat.diffuse.contents = [UIColor redColor];
    
    geo.firstMaterial = mat;
    geo.firstMaterial.doubleSided = YES;
    
    return geo;
    
}

#pragma mark - TESTING CUSTOM GEOMETRY

// Verticies
-(NSArray*)positions
{
    CGFloat cubeSide = 15.0;
    CGFloat halfSide = cubeSide/2.;
    
    return @[
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide, -halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide, -halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide, -halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide, -halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide,  halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide,  halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide,  halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide,  halfSide, -halfSide)],
             // repeat exactly the same
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide, -halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide, -halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide, -halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide, -halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide,  halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide,  halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide,  halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide,  halfSide, -halfSide)],
             // repeat exactly the same
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide, -halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide, -halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide, -halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide, -halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide,  halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide,  halfSide,  halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make(-halfSide,  halfSide, -halfSide)],
             [NSValue valueWithSCNVector3:SCNVector3Make( halfSide,  halfSide, -halfSide)]
             ];
}

-(NSArray*)normals
{
    return @[
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, -1, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, -1, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, -1, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, -1, 0)],
             
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 1, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 1, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 1, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 1, 0)],
             
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 0, 1)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 0, 1)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 0, -1)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 0, -1)],
             
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 0, 1)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 0, 1)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 0, -1)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 0, 0, -1)],
             
             [NSValue valueWithSCNVector3:SCNVector3Make( -1, 0, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 1, 0, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( -1, 0, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 1, 0, 0)],
             
             [NSValue valueWithSCNVector3:SCNVector3Make( -1, 0, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 1, 0, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( -1, 0, 0)],
             [NSValue valueWithSCNVector3:SCNVector3Make( 1, 0, 0)]
             ];
}

-(NSArray*)textureCords
{
    /*
     // uvs
     v->s = zero, v->t = zero,
     v->s = one, v->t = zero,
     v->s = zero, v->t = one,
     v->s = one, v->t = one, //btm
     
     v->s = zero, v->t = one,
     v->s = one, v->t = one,
     v->s = zero, v->t = zero,
     v->s = one, v->t = zero, // top
     
     v->s = zero, v->t = one,
     v->s = one, v->t = one, // fr
     v->s = one, v->t = one,
     v->s = zero, v->t = one, // back
     
     v->s = zero, v->t = zero,
     v->s = one, v->t = zero, // fr
     v->s = one, v->t = zero,
     v->s = zero, v->t = zero, // back
     
     v->s = one, v->t = one, //l
     v->s = zero, v->t = one, //r
     v->s = zero, v->t = one, //l
     v->s = one, v->t = one, //r
     
     v->s = one, v->t = zero, //l
     v->s = zero, v->t = zero, //r
     v->s = zero, v->t = zero, //l
     v->s = one, v->t = zero; //r
     
     */
    return @[];
}



-(int)indices
{
    unsigned short myShort[] = {
        // bottom
        0, 2, 1,
        1, 2, 3,
        // back
        10, 14, 11,  // 2, 6, 3,   + 8
        11, 14, 15,  // 3, 6, 7,   + 8
                     // left
        16, 20, 18,  // 0, 4, 2,   + 16
        18, 20, 22,  // 2, 4, 6,   + 16
                     // right
        17, 19, 21,  // 1, 3, 5,   + 16
        19, 23, 21,  // 3, 7, 5,   + 16
                     // front
        8,  9, 12,  // 0, 1, 4,   + 8
        9, 13, 12,  // 1, 5, 4,   + 8
                    // top
        4, 5, 6,
        5, 7, 6
    };
    
    return (int)myShort;
    
}

-(void)testTest
{
    // Indices
    unsigned short myShort[] = {
        // bottom
        0, 2, 1,
        1, 2, 3,
        // back
        10, 14, 11,  // 2, 6, 3,   + 8
        11, 14, 15,  // 3, 6, 7,   + 8
                     // left
        16, 20, 18,  // 0, 4, 2,   + 16
        18, 20, 22,  // 2, 4, 6,   + 16
                     // right
        17, 19, 21,  // 1, 3, 5,   + 16
        19, 23, 21,  // 3, 7, 5,   + 16
                     // front
        8,  9, 12,  // 0, 1, 4,   + 8
        9, 13, 12,  // 1, 5, 4,   + 8
                    // top
        4, 5, 6,
        5, 7, 6
    };
    
    
    //    *myShort++ = 1;
    //    *myShort++ = 2;
    
    int indices = (unsigned short)[self indices];
    
    unsigned short *inds = (unsigned short)[self indices];
    
    NSLog(@"INT = %hu",(unsigned short)[self indices]);
    
    NSLog(@"myShort: %hu",(unsigned short)myShort);
    
    
}

-(SCNGeometry*)buildTestGeometry
{
    // [self testTest];
    
    NSArray *positions = [self positions];
    
    NSArray *normals = [self normals];
    
    NSInteger vcount = positions.count;
    
    JDMVertex *vertices = malloc(sizeof(JDMVertex) * vcount);
    
    // Indices
    
    NSInteger icount = 36;
    
    
    unsigned short indices[] = {
        // bottom
        0, 2, 1,
        1, 2, 3,
        // back
        10, 14, 11,  // 2, 6, 3,   + 8
        11, 14, 15,  // 3, 6, 7,   + 8
                     // left
        16, 20, 18,  // 0, 4, 2,   + 16
        18, 20, 22,  // 2, 4, 6,   + 16
                     // right
        17, 19, 21,  // 1, 3, 5,   + 16
        19, 23, 21,  // 3, 7, 5,   + 16
                     // front
        8,  9, 12,  // 0, 1, 4,   + 8
        9, 13, 12,  // 1, 5, 4,   + 8
                    // top
        4, 5, 6,
        5, 7, 6
    };
    
    // Verticies
    
    for (int x=0; x<positions.count; x++) {
        //
        SCNVector3 vector = [[positions objectAtIndex:x] SCNVector3Value];
        SCNVector3 normal = [[normals objectAtIndex:x] SCNVector3Value];
        
        vertices->x = (float)vector.x;
        vertices->y = (float)vector.y;
        vertices->z = (float)vector.z;
        
        vertices->nx = (float)normal.x;
        vertices->ny = (float)normal.y;
        vertices->nz = (float)normal.z;
    }
    
    
    NSData *data = [NSData dataWithBytes:vertices length:vcount * sizeof(JDMVertex)];
    free(vertices);
    
    
    
    
    // Vertex source
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticVertex
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:0
                                                                     dataStride:sizeof(JDMVertex)];
    
    // Normal source
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:vcount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(JDMVertex, nx)
                                                                     dataStride:sizeof(JDMVertex)];
    
    
    // Texture coordinates source
    SCNGeometrySource *texcoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:vcount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(JDMVertex, s)
                                                                       dataStride:sizeof(JDMVertex)];
    
    
    // Geometry element
    NSData *indicesData = [NSData dataWithBytes:indices length:icount * sizeof(unsigned short)];
    // free(indices);
    
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indicesData
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                               primitiveCount:icount/3
                                                                bytesPerIndex:sizeof(unsigned short)];
    
    // Create the geometry
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, normalSource, texcoordSource] elements:@[element]];
    
    return geometry;
    
}


-(SCNGeometry*)customGeometryFromBook
{
    // Custom geometry for a cube
    // --------------------------
    // A square box is positioned in the center of the scene (default)
    // and given a small rotation around Y to highlight the perspective.
    CGFloat cubeSide = 15.0;
    CGFloat halfSide = cubeSide/2.;
    
    SCNVector3 positions[] = {
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide),
        
        // repeat exactly the same
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide),
        
        // repeat exactly the same
        SCNVector3Make(-halfSide, -halfSide,  halfSide),
        SCNVector3Make( halfSide, -halfSide,  halfSide),
        SCNVector3Make(-halfSide, -halfSide, -halfSide),
        SCNVector3Make( halfSide, -halfSide, -halfSide),
        SCNVector3Make(-halfSide,  halfSide,  halfSide),
        SCNVector3Make( halfSide,  halfSide,  halfSide),
        SCNVector3Make(-halfSide,  halfSide, -halfSide),
        SCNVector3Make( halfSide,  halfSide, -halfSide)
    };
    
    SCNVector3 normals[] = {
        
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        SCNVector3Make( 0, -1, 0),
        
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        SCNVector3Make( 0, 1, 0),
        
        
        SCNVector3Make( 0, 0,  1),
        SCNVector3Make( 0, 0,  1),
        SCNVector3Make( 0, 0, -1),
        SCNVector3Make( 0, 0, -1),
        
        SCNVector3Make( 0, 0, 1),
        SCNVector3Make( 0, 0, 1),
        SCNVector3Make( 0, 0, -1),
        SCNVector3Make( 0, 0, -1),
        
        
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
        SCNVector3Make(-1, 0, 0),
        SCNVector3Make( 1, 0, 0),
    };
    
    
    // The indices for the 12 triangles that make up the cubes sides
    // Note the ordering to control the frontside and backside of each
    // surface.
    
    int indices[] = {
        // bottom
        0, 2, 1,
        1, 2, 3,
        // back
        10, 14, 11,  // 2, 6, 3,   + 8
        11, 14, 15,  // 3, 6, 7,   + 8
                     // left
        16, 20, 18,  // 0, 4, 2,   + 16
        18, 20, 22,  // 2, 4, 6,   + 16
                     // right
        17, 19, 21,  // 1, 3, 5,   + 16
        19, 23, 21,  // 3, 7, 5,   + 16
                     // front
        8,  9, 12,  // 0, 1, 4,   + 8
        9, 13, 12,  // 1, 5, 4,   + 8
                    // top
        4, 5, 6,
        5, 7, 6
    };
    
    
    // Create sources for the vertices and normals
    
    SCNGeometrySource *vertexSource =
    [SCNGeometrySource geometrySourceWithVertices:positions
                                            count:24];
    SCNGeometrySource *normalSource =
    [SCNGeometrySource geometrySourceWithNormals:normals
                                           count:24];
    
    
    
    
    
    NSData *indexData = [NSData dataWithBytes:indices
                                       length:sizeof(indices)];
    
    // Note that there is still only 12 indices for the 12 triangles
    // even though there are 24 vertices
    
    SCNGeometryElement *element =
    [SCNGeometryElement geometryElementWithData:indexData
                                  primitiveType:SCNGeometryPrimitiveTypeTriangles
                                 primitiveCount:12
                                  bytesPerIndex:sizeof(int)];
    
    
    SCNGeometry *geometry =
    [SCNGeometry geometryWithSources:@[vertexSource, normalSource]
                            elements:@[element]];
    
    
    // Give the cube a red colored material
    
    SCNMaterial *redMataterial = [SCNMaterial material];
    redMataterial.diffuse.contents = [UIColor redColor];
    
    geometry.materials = @[redMataterial];
    
    return geometry;
}
