//
//  JDMMesh.m
//  SceneKit Playground
//
//  Created by Justin Madewell on 3/22/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "JDMMesh.h"


@implementation JDMMesh

@synthesize vertices,indicies,textcoords,normals;


#pragma mark - Object Initialization

-(instancetype)init
{
    if ((self = [super init]))
    {
        
    }
    return self;
}

+(instancetype)makeMesh
{
    JDMMesh *mesh = [[self alloc]init];
    return mesh;

}


-(SCNGeometry *)mesh
{
    return [self bookMesh];
}

#pragma mark - Build Mesh

// Slope Function
GLKVector3(^function)(float, float) = ^(float x, float z) {
    float angle = 1.0/2.0 * sqrt(pow(x, 2) + pow(z, 2));
    
    return GLKVector3Make(x,
                          2.0 * cos(angle),
                          z);
};


-(SCNGeometry*)bookMesh
{
    //Mesh from book
    
    // The mesh will have a size of 50 x 50
    int width  = 50;
    int height = 50;
    NSUInteger pointCount = width * height;
    
    // Generate the index data for the mesh
    // ------------------------------------
    NSUInteger indexCount = (2 * width + 1) * (height-1);
    
    // Create a buffer for the index data
    int *indices = calloc(indexCount, sizeof(int));
    
    // Generate index data as described in the chapter
    int i = 0;
    
    for (int h=0 ; h<height-1 ; h++) {
        
        BOOL isEven = h%2 == 0;
        
        if (isEven) {
            // --->
            for (int w=0 ; w<width ; w++) {
                
                int value = (h * width + w);
                
                indices[i++] =  value; //h    * width + w;
                
                value = (h+1) * width + w;

                indices[i++] = value; //(h+1) * width + w;
            }
        } else {
            // <---
            for (int w=width-1 ; w>=0 ; w--) {
                
                int value = (h+0) * width + w;
                
                indices[i++] = value; ///(h+0) * width + w;
                
                value = (h+1) * width + w;
                
                indices[i++] = value; //(h+1) * width + w;
            }
        }
        int previous = indices[i-1];
        
        
        
        indices[i++] = previous;
    }
    NSAssert(indexCount == i, @"Should have added as many lines as the size of the buffer");
    
    
    // get it here
    NSMutableArray *iArray = [[NSMutableArray alloc]init];
    
    for (int x=0; x<indexCount; x++) {
        
         NSLog(@"indices[%i]: %i",x,(int)indices[x]);
        
        [iArray addObject:[NSNumber numberWithInt:indices[x]]];
        
    }
    
    // NSLog(@"iArray.count: %lu",(unsigned long)iArray.count);
    
    
    
    
    
    // Generate the source data for the mesh
    // -------------------------------------
    // Set up custom struct buffers to hold source data
    JDMMeshVertex *jm_meshVerticies = calloc(pointCount, sizeof(JDMMeshVertex));
    JDMMeshVertex *v = jm_meshVerticies;
    
    // init for temp containers
    NSMutableArray *vArray = [[NSMutableArray alloc]init];
    NSMutableArray *nArray = [[NSMutableArray alloc]init];
    NSMutableArray *tArray = [[NSMutableArray alloc]init];
    
    // Define the range of x and z for which values are calculated
    float slopeAmt = 30.0;
    float minX = -slopeAmt, maxX = slopeAmt;
    float minZ = -slopeAmt, maxZ = slopeAmt;
    
    
    /* WHERE THE MESH / 3D PLOT IS CREATED */
    // --------------------------------------
    
    for (int h = 0 ; h<height ; h++) {
        for (int w = 0 ; w<width ; w++,v++) {
            
//            static int counter;
//            NSLog(@"counter: %lu",(unsigned long)counter);
//            counter++;
//            
            
            // Calculate x and z for this point
            CGFloat x = w/(CGFloat)(width-1)  * (maxX-minX) + minX;
            CGFloat z = h/(CGFloat)(height-1) * (maxZ-minZ) + minZ;
            
            // Vertex data
            GLKVector3 current = function(x,z);
            SCNVector3 vertexVector = SCNVector3FromGLKVector3(current);
            [vArray addObject:[NSValue valueWithSCNVector3:vertexVector]];
            
            {
               v->x = vertexVector.x;
               v->y = vertexVector.y;
               v->z = vertexVector.z;
            }
            
            // Normal data
            CGFloat delta = 0.001;
            GLKVector3 nextX   = function(x+delta, z);
            GLKVector3 nextZ   = function(x,       z+delta);
            
            GLKVector3 dx = GLKVector3Subtract(nextX, current);
            GLKVector3 dz = GLKVector3Subtract(nextZ, current);
            
            GLKVector3 normal = GLKVector3Normalize( GLKVector3CrossProduct(dz, dx) );
            SCNVector3 normalsVector = SCNVector3FromGLKVector3(normal);
            [nArray addObject:[NSValue valueWithSCNVector3:normalsVector]];
            
            {
              v->nx = normalsVector.x;
              v->ny = normalsVector.y;
              v->nz = normalsVector.z;
            }
            
            // Texture data
            CGPoint txCoordPoint = CGPointMake(w/(CGFloat)(width-1),
                                               h/(CGFloat)(height-1));
            
            [tArray addObject:[NSValue valueWithCGPoint:txCoordPoint]];
            {
              v->s = txCoordPoint.x;
              v->t = txCoordPoint.y;
            }
        }
    }
    
    // Create Point Array for Line Geometry
    NSArray *pointsInPairsAsLines =
  @[
      [vArray objectAtIndex:0],
      [vArray objectAtIndex:1],
      
      [vArray objectAtIndex:1],
      [vArray objectAtIndex:2],
      
      [vArray objectAtIndex:2],
      [vArray objectAtIndex:3],
    
    ];
    
    
    
    
    NSMutableArray *pointsArray = [[NSMutableArray alloc]init];
    
    int numOfPoints = 500;
    
    for (int x=0; x<numOfPoints; x++) {
        
        [pointsArray addObject:[vArray objectAtIndex:x]];
    }
    
    // return [self lineGeometryFromPoints:pointsInPairsAsLines];
    return [self pointGeometryFromPoints:pointsInPairsAsLines];
    
    
    /* NSDATA */
    //--------------
    // Geometry Data
    NSData *indicesData = [NSData dataWithBytes:indices length:indexCount * sizeof(int)];
    free(indices);
    
    NSData *data = [NSData dataWithBytes:jm_meshVerticies length:pointCount * sizeof(JDMMeshVertex)];
    free(jm_meshVerticies);
    
    
    /* SCNGEOMETERY */
    // Vertex source
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticVertex
                                                                    vectorCount:pointCount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:0
                                                                     dataStride:sizeof(JDMMeshVertex)];
    
    // Normal source
    SCNGeometrySource *normalSource = [SCNGeometrySource geometrySourceWithData:data
                                                                       semantic:SCNGeometrySourceSemanticNormal
                                                                    vectorCount:pointCount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:offsetof(JDMMeshVertex, nx)
                                                                     dataStride:sizeof(JDMMeshVertex)];
    
    
    // Texture coordinates source
    SCNGeometrySource *texcoordSource = [SCNGeometrySource geometrySourceWithData:data
                                                                         semantic:SCNGeometrySourceSemanticTexcoord
                                                                      vectorCount:pointCount
                                                                  floatComponents:YES
                                                              componentsPerVector:2
                                                                bytesPerComponent:sizeof(float)
                                                                       dataOffset:offsetof(JDMMeshVertex, s)
                                                                       dataStride:sizeof(JDMMeshVertex)];
    
    
    
    // Elements
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indicesData
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangleStrip
                                                               primitiveCount:indexCount
                                                                bytesPerIndex:sizeof(int)];
    
    // Create the geometry
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, normalSource, texcoordSource] elements:@[element]];
    
    
    // Give it a blue checker board texture
    SCNMaterial *blueMaterial      = [SCNMaterial material];
    blueMaterial.diffuse.contents  = [UIImage imageNamed:@"checkerboard"];
    blueMaterial.specular.contents = [UIColor darkGrayColor];
    blueMaterial.shininess         = 0.25;
    
    // Scale down the image when used as a texture ...
    blueMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(5.0, 5.0, 1.0);
    // ... and make it repeat
    blueMaterial.diffuse.wrapS = SCNWrapModeRepeat;
    blueMaterial.diffuse.wrapT = SCNWrapModeRepeat;
    
    // set Materials
    geometry.materials = @[blueMaterial];
    
    return geometry;
}





-(SCNGeometry*)lineGeometryFromPoints:(NSArray*)points
{
    NSUInteger pointCount = points.count;
    
    // Set up custom struct buffers to hold source data
    JDMMeshLinePoint *meshLinePoint = calloc(pointCount, sizeof(JDMMeshLinePoint));
    JDMMeshLinePoint *p = meshLinePoint;
    
    // Set up the source containers.
    int _lineIndicies[pointCount];
    
    // fill containers
    for (int x=0; x<pointCount; x++,p++ ) {
        
        SCNVector3 pointVector = [[points objectAtIndex:x] SCNVector3Value];
        
        p->x = pointVector.x;
        p->y = pointVector.y;
        p->z = pointVector.z;
        
        _lineIndicies[x] = x;
    }
    
    int newlineInd[]={
      0,1,
      2,3,
      4,5,
    };
    
    // Geometry Data
    NSData *indexData = [NSData dataWithBytes:newlineInd length:pointCount * sizeof(int)];

    NSData *pointData = [NSData dataWithBytes:meshLinePoint length:pointCount * sizeof(JDMMeshLinePoint)];
    free(meshLinePoint);

    /* SCNGEOMETERY */
    
    // Vertex source
    SCNGeometrySource *customLineVertexSource = [SCNGeometrySource geometrySourceWithData:pointData
                                                                       semantic:SCNGeometrySourceSemanticVertex
                                                                    vectorCount:pointCount
                                                                floatComponents:YES
                                                            componentsPerVector:3
                                                              bytesPerComponent:sizeof(float)
                                                                     dataOffset:0
                                                                     dataStride:sizeof(JDMMeshLinePoint)];

    

    // Elements
    SCNGeometryElement *lineElement = [SCNGeometryElement geometryElementWithData:indexData
                                                                primitiveType:SCNGeometryPrimitiveTypeLine
                                                               primitiveCount:1
                                                                bytesPerIndex:sizeof(int)];
    
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[customLineVertexSource] elements:@[lineElement]];
    
    // Material
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [UIColor redColor];
    material.lightingModelName = SCNLightingModelConstant;
    
    geometry.firstMaterial = material;
    
    return geometry;
}

-(SCNGeometry*)pointGeometryFromPoints:(NSArray*)points
{
    NSUInteger pointCount = points.count;
    
    // Set up custom struct buffers to hold source data
    JDMMeshLinePoint *meshLinePoint = calloc(pointCount, sizeof(JDMMeshLinePoint));
    JDMMeshLinePoint *p = meshLinePoint;
    
    // Set up the source containers.
    int _lineIndicies[pointCount];
    
    // fill containers
    for (int x=0; x<pointCount; x++,p++ ) {
        
        SCNVector3 pointVector = [[points objectAtIndex:x] SCNVector3Value];
        
        p->x = pointVector.x;
        p->y = pointVector.y;
        p->z = pointVector.z;
        
        _lineIndicies[x] = x;
    }
    
//    int newlineInd[]={
//        0,1,
//        2,3,
//        4,5,
//    };
    
    // Geometry Data
    NSData *indexData = [NSData dataWithBytes:_lineIndicies length:pointCount * sizeof(int)];
    
    NSData *pointData = [NSData dataWithBytes:meshLinePoint length:pointCount * sizeof(JDMMeshLinePoint)];
    free(meshLinePoint);
    
    /* SCNGEOMETERY */
    
    // Vertex source
    SCNGeometrySource *customLineVertexSource = [SCNGeometrySource geometrySourceWithData:pointData
                                                                                 semantic:SCNGeometrySourceSemanticVertex
                                                                              vectorCount:pointCount
                                                                          floatComponents:YES
                                                                      componentsPerVector:3
                                                                        bytesPerComponent:sizeof(float)
                                                                               dataOffset:0
                                                                               dataStride:sizeof(JDMMeshLinePoint)];
    
    
    
    // Elements
    SCNGeometryElement *lineElement = [SCNGeometryElement geometryElementWithData:indexData
                                                                    primitiveType:SCNGeometryPrimitiveTypePoint
                                                                   primitiveCount:1
                                                                    bytesPerIndex:sizeof(int)];
    
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[customLineVertexSource] elements:@[lineElement]];
    
    // Material
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = [UIColor blueColor];
    material.lightingModelName = SCNLightingModelConstant;
    
    geometry.firstMaterial = material;
    
    return geometry;
}








@end
