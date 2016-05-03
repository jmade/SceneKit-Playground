//
//  JDMNode.m
//  SceneKit Playground
//
//  Created by Justin Madewell on 3/6/15.
//  Copyright (c) 2015 Justin Madewell. All rights reserved.
//

#import "JDMNode.h"
#import "JDMMesh.h"

#define ARC4RANDOM_MAX      0x100000000

// Data structure representing a vertex that will be used to create custom geometries
typedef struct {
    float x, y, z;    // position
    float nx, ny, nz; // normal
    float s, t;       // texture coordinates
} ASCVertex;

typedef struct {
    float x, y, z;
    float nx, ny, nz;
    float s, t;
} JDMVertex;


@implementation JDMNode

-(instancetype)self
{
    return self;
}


-(instancetype)init
{
    if ((self = [super init]))
    {
        [self buildCustom];
    }
    return self;
}

+ (instancetype) makeCharacter
{
    return [[self alloc] init];
}


#pragma mark - Materials

-(SCNMaterial*)makeTexturedMaterial
{
    NSString *tString = [NSString stringWithFormat:@"texture%i",(int)randomInt(1, 7)];
    
    SKTexture *texture = [SKTexture textureWithImageNamed:tString];
    SKTexture *normalTexture = [texture textureByGeneratingNormalMap];
    
    SCNMaterial *mat = [SCNMaterial material];
    mat.diffuse.contents = texture;
    mat.normal.contents = normalTexture;
    
    return mat;
}

-(SCNMaterial*)makeMaterial
{
    SCNMaterial *mat = [SCNMaterial material];
    mat.diffuse.contents = randomColor();
    
    return mat;
}

#pragma mark - Contraints

-(void)initConstraint
{
    SCNTransformConstraint *transformConstraint = [SCNTransformConstraint transformConstraintInWorldSpace:YES withBlock:^SCNMatrix4(SCNNode *node, SCNMatrix4 transform) {
        
        node.rotation = SCNVector4Make(0, 0, 1, DegreesToRadians(45));
        
        return node.transform;
        
    }];
    
    self.constraints = @[transformConstraint];

}



-(void)buildBoxNode
{
    SCNNode *boxNode = [SCNNode node];
    boxNode.geometry = [self boxGeometry];
    

    
    
    [self initConstraint];
}



-(void)buildCustom
{
    
    SCNNode *boxNode = [SCNNode node];
    
    
    JDMMesh *meshObject = [JDMMesh makeMesh];
    SCNGeometry *myMesh =  [meshObject mesh];
    
    // SCNGeometry *mesh = [self ];
    
    boxNode.geometry = myMesh;//[self myGeo];
    
    float scale = 2.0;
    boxNode.scale = SCNVector3Make(scale,scale,scale);
    
  
    
    //boxNode.scale = SCNVector3Make(0.02, 0.02, 0.02);
    
    
//    boxNode.position = SCNVector3Make(3.25, 0.25, 8.25);
//    
//     boxNode.scale = SCNVector3Make(scale, scale, scale);
    // boxNode.position = SCNVector3Make(0, 0.20, 0);
    // boxNode.rotation = SCNVector4Make(1, 0, 0, RadiansFromDegrees(45));
    
//    boxNode.scale = SCNVector3Make(2, 2, 2);
//    boxNode.position = SCNVector3Make(0, 3, 0);
//    boxNode.rotation = SCNVector4Make(1, 0, 0, RadiansFromDegrees(45));

    [self addChildNode:boxNode];
    // self.position = SCNVector3Make(10, 3, 0);
    
    // [self randomPoints:50 rangeVector:SCNVector3Make(5, 5, 5)];

}

-(void)buildIKNode
{
    
}


-(void)doAnimation
{
    
}


#pragma mark - Geometry

-(SCNGeometry*)myGeo
{
//    [self structPointerTest:1];
//    [self pointerTest];
    
    BOOL remix = YES;
    
    SCNNode *boxNode = [SCNNode node];
    boxNode.geometry = ReturnGeometryOfType(ShapeTypeSphere, 2);
    
    NSArray *verticies = [self getVertsFromGeometry:boxNode.geometry];
    NSArray *normals =  [self getNormalsFromGeometry:boxNode.geometry];
    NSArray *textcoords =  [self getTextureCoordinatesFromGeometry:boxNode.geometry];
    
    NSLog(@"Number of Verts: %d\nNormals: %d\nTextureCoords: %d\n",(int)verticies.count,(int)normals.count,(int)textcoords.count);
    
    
    // Array of Unsigned Shorts
    NSArray *indiciesArray = [self getIndicesFromGeometry:boxNode.geometry];
    
    NSInteger vcount = verticies.count;
    NSInteger icount = indiciesArray.count;
    
    JDMVertex *vertices = malloc(sizeof(JDMVertex) * vcount);
    JDMVertex *v = vertices;
    
    for (int x=0; x<vcount; x++) {
        
        if (remix) {
            
            SCNVector3 rVert = randomVert([[verticies objectAtIndex:x] SCNVector3Value]);
            
            v->x = rVert.x;
            v->y = rVert.y;
            v->z = rVert.z;

        }
        else
        {
            v->x = [[verticies objectAtIndex:x] SCNVector3Value].x;
            v->y = [[verticies objectAtIndex:x] SCNVector3Value].y;
            v->z = [[verticies objectAtIndex:x] SCNVector3Value].z;

        }
        
        
        v->nx = [[normals objectAtIndex:x] SCNVector3Value].x;
        v->ny = [[normals objectAtIndex:x] SCNVector3Value].y;
        v->nz = [[normals objectAtIndex:x] SCNVector3Value].z;
        
        v->s = [[textcoords objectAtIndex:x] CGPointValue].x;
        v->t = [[textcoords objectAtIndex:x] CGPointValue].y;
        
        
        v++;
    }
    
    // Indices
    unsigned short *indices = malloc(sizeof(unsigned short) * icount);
    unsigned short *ind = indices;
    for (int i=0; i<icount; i++) {
       unsigned short number = [[indiciesArray objectAtIndex:i] unsignedShortValue];
        ind[i] = number;
    }
    
    
    /* NSDATA */
    
    NSData *data = [NSData dataWithBytes:vertices length:vcount * sizeof(ASCVertex)];
    free(vertices);
    
    // Geometry Data
    NSData *indicesData = [NSData dataWithBytes:indices length:icount * sizeof(unsigned short)];
    free(indices);
    
    
    /* SCNGEOMETERY */
    
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
    
    
    
    // Elements
    SCNGeometryElement *element = [SCNGeometryElement geometryElementWithData:indicesData
                                                                primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                               primitiveCount:icount/3
                                                                bytesPerIndex:sizeof(unsigned short)];
    
    // Create the geometry
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, normalSource, texcoordSource] elements:@[element]];
    
    geometry.firstMaterial.diffuse.contents = [UIColor redColor];
   
    
    return geometry;
    
}








-(NSData*)elementData:(NSArray*)newIndicies
{
  
    NSInteger numberOfIndicies = newIndicies.count;
    
    unsigned short indicies[numberOfIndicies];
    
    for (int x=0; x<numberOfIndicies; x++) {
        NSNumber *number  = [newIndicies objectAtIndex:x];
        unsigned short ind = [number unsignedShortValue];
        // NSLog(@"ind: %hu",(unsigned short)ind);
        
        indicies[x] = ind;
    }
    
    NSInteger bytes = sizeof(indicies);
    
    NSData *indicieData = [NSData dataWithBytes:&bytes length:sizeof(unsigned short)*numberOfIndicies];
    NSString *someString = [NSString stringWithFormat:@"%@", indicieData];
    
    //  NSLog(@"someString:%@",someString);
    
    [self logData:indicieData BytesPerIndex:sizeof(indicies[0])];
    
    NSData* data = [NSData data];
    return data;
}



-(SCNGeometry*)boxGeometry
{
    SCNGeometry *geo = ReturnGeometryOfType(ShapeTypeBox, 1);
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
    mat.diffuse.contents = randomColor();
    
    geo.firstMaterial = mat;
    geo.firstMaterial.doubleSided = YES;
    
    return geo;
    
}

float myRandomFloat(float start, float end)
{
    double val = floorf(((double)arc4random() / ARC4RANDOM_MAX) * 100.0f);
    
    val = (double)(val / 100.0f);
    
    if (RANDOM_BOOL) {
        val = (val * -1);
    }
    
    NSLog(@"val: %f",val);
    
    return val;
}



float mixedVertex(float vertex)
{
    float modifier = (vertex * 0.08);
    
    if (RANDOM_BOOL) {
        modifier = (modifier * -1);
    }
    
    float mixedVertex = (vertex + modifier);
    
    // NSLog(@"Incoming Vertex: %f,Mod: %f,New Vertex: %f",vertex,modifier,mixedVertex);
    
    
    return mixedVertex;
}


SCNVector3 randomVert(SCNVector3 vert)
{
    // Get an Integer between 1 and 3.
    NSInteger decider = randomInt(1, 4);
    // NSLog(@"decider: %lu",(unsigned long)decider);
    
    SCNVector3 rV;
    
//    float x = mixedVertex(vert.x);
//    float y = mixedVertex(vert.y);
//    float z = mixedVertex(vert.z);
    
    switch (decider) {
        case 1: rV = SCNVector3Make(mixedVertex(vert.x), vert.y, vert.z);
            // 1
        case 2: rV = SCNVector3Make(vert.x, mixedVertex(vert.y), vert.z);
            // 2
        case 3: rV = SCNVector3Make(vert.x, vert.y, mixedVertex(vert.z));
            // 3
            break;
            
        default: rV = SCNVector3Make(mixedVertex(vert.x), vert.y, vert.z);
            break;
    }
    
    
    return rV; //SCNVector3Make(x,y,z);
}

#pragma mark - TEST

-(void)ookie4:(SCNVector3**)vector
{
    NSLog(@"vector[1].x: %f",vector[1]->x);
    
}

-(void)ookie3:(SCNVector3[])vect
{
    NSLog(@"vect[0].x: %f",vect[0].x);
    NSLog(@"vect[1].x: %f",vect[1].x);
    NSLog(@"vect[2].x: %f",vect[2].x);
    NSLog(@"vect[10].x: %f",vect[10].x);
}

-(void)ookie:(int**)snork
{
    
}

-(void)ookie2:(int[])snork
{
    
}

-(void)logCArray:(SCNVector3[])array withLength:(int)length
{
    for (int x=0; x<length; x++) {
  
        NSLog(@"array[x].x: %f",array[x].x);
        
    }
}



#pragma mark - Randomize Components
// ?????

-(SCNVector3*)randomizeComponents:(NSArray*)components
{
    float amount = 0.25;
 
    NSUInteger vectorCount = components.count;
    SCNVector3 newVector[vectorCount];
    
     for(NSInteger i=0; i<vectorCount; i++) {
        
         SCNVector3 vector = [[components objectAtIndex:i] SCNVector3Value];
         float modifier = 1.0;
         
         if (RANDOM_BOOL) {
             modifier = -1.0;
         }
         
         float newX = vector.x + (modifier * amount);
         float newY = vector.y + (modifier * amount);
         float newZ = vector.z + (modifier * amount);
         
         newVector[i] = SCNVector3Make(newX, newY, newZ);
         
     }
    
    
       return &newVector[vectorCount];
}



#pragma mark - 



-(NSArray*)getVertsFromGeometry:(SCNGeometry*)geometry
{
    // Get the vertex sources
    NSArray *vertexSources = [geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticVertex];
    
    // Get the first source
    SCNGeometrySource *vertexSource = vertexSources[0];
    
    // TODO: Parse all the sources
    
    NSInteger stride = vertexSource.dataStride; // in bytes
    NSInteger offset = vertexSource.dataOffset; // in bytes
    
    NSInteger componentsPerVector = vertexSource.componentsPerVector;
    NSInteger bytesPerVector = componentsPerVector * vertexSource.bytesPerComponent;
    NSInteger vectorCount = vertexSource.vectorCount;
    
    SCNVector3 vertices[vectorCount];
    
    // A new array for vertices
    
    NSMutableArray *verts = [[NSMutableArray alloc]init];
    
    // for each vector, read the bytes
    for (NSInteger i=0; i<vectorCount; i++) {
        
        // Assuming that bytes per component is 4 (a float)
        // If it was 8 then it would be a double (aka CGFloat)
        float vectorData[componentsPerVector];
        
        // The range of bytes for this vector
        NSRange byteRange = NSMakeRange(i*stride + offset, // Start at current stride + offset
                                        bytesPerVector);   // and read the lenght of one vector
        
        // Read into the vector data buffer
        [vertexSource.data getBytes:&vectorData range:byteRange];
        
        // At this point you can read the data from the float array
        float x = vectorData[0];
        float y = vectorData[1];
        float z = vectorData[2];
        
        // ... Maybe even save it as an SCNVector3 for later use ...
        vertices[i] = SCNVector3Make(x, y, z);
        
        
        [verts addObject:[NSValue valueWithSCNVector3: SCNVector3Make(x, y, z)]];
        
        // ... or just log it
        // NSLog(@"Vx:%f, Vy:%f, Vz:%f", x, y, z);
    }
    
    return verts;
}


-(NSArray*)getTextureCoordinatesFromGeometry:(SCNGeometry*)geometry
{
    // Get the texcoord sources
    NSArray *texcoordSources = [geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticTexcoord];
    SCNGeometrySource *texcoordSource = texcoordSources[0];
    
    NSInteger stride = texcoordSource.dataStride; // in bytes
    NSInteger offset = texcoordSource.dataOffset; // in bytes
    
    NSInteger componentsPerVector = texcoordSource.componentsPerVector;
    NSInteger bytesPerVector = componentsPerVector * texcoordSource.bytesPerComponent;
    NSInteger vectorCount = texcoordSource.vectorCount;
    
    CGPoint texcoords[vectorCount]; // A new array for vertices
    
    // A new array for vertices
    NSMutableArray *texcoordsArrays = [[NSMutableArray alloc]init];
    
    // for each vector, read the bytes
    for (NSInteger i=0; i<vectorCount; i++) {
        
        // Assuming that bytes per component is 4 (a float)
        // If it was 8 then it would be a double (aka CGFloat)
        float vectorData[componentsPerVector];
        
        // The range of bytes for this vector
        NSRange byteRange = NSMakeRange(i*stride + offset, // Start at current stride + offset
                                        bytesPerVector);   // and read the lenght of one vector
        
        // Read into the vector data buffer
        [texcoordSource.data getBytes:&vectorData range:byteRange];
        
        // At this point you can read the data from the float array
        float x = vectorData[0];
        float y = vectorData[1];
        //float z = vectorData[2];
        
        // ... Maybe even save it as an SCNVector3 for later use ...
        texcoords[i] = CGPointMake(x, y);
        
        
        [texcoordsArrays addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        
        // ... or just log it
        //  NSLog(@"Sx:%f, Sy:%f", x, y);
    }
    
    
    return texcoordsArrays;
    
    // return @[];
}

-(NSArray*)getNormalsFromGeometry:(SCNGeometry*)geometry
{
    // Get the normal sources
    NSArray *normalSources = [geometry geometrySourcesForSemantic:SCNGeometrySourceSemanticNormal];
    
    SCNGeometrySource *normalSource = normalSources[0];
    
    NSInteger stride = normalSource.dataStride; // in bytes
    NSInteger offset = normalSource.dataOffset; // in bytes
    
    NSInteger componentsPerVector = normalSource.componentsPerVector;
    NSInteger bytesPerVector = componentsPerVector * normalSource.bytesPerComponent;
    NSInteger vectorCount = normalSource.vectorCount;
    
    SCNVector3 normals[vectorCount]; // A new array for vertices
    
    // A new array for vertices
    NSMutableArray *normalsArrays = [[NSMutableArray alloc]init];
    
    // for each vector, read the bytes
    for (NSInteger i=0; i<vectorCount; i++) {
        
        // Assuming that bytes per component is 4 (a float)
        // If it was 8 then it would be a double (aka CGFloat)
        float vectorData[componentsPerVector];
        
        // The range of bytes for this vector
        NSRange byteRange = NSMakeRange(i*stride + offset, // Start at current stride + offset
                                        bytesPerVector);   // and read the lenght of one vector
        
        // Read into the vector data buffer
        [normalSource.data getBytes:&vectorData range:byteRange];
        
        // At this point you can read the data from the float array
        float x = vectorData[0];
        float y = vectorData[1];
        float z = vectorData[2];
        
        // ... Maybe even save it as an SCNVector3 for later use ...
        normals[i] = SCNVector3Make(x, y, z);
        
        
        [normalsArrays addObject:[NSValue valueWithSCNVector3: SCNVector3Make(x, y, z)]];
        
        // ... or just log it
        //  NSLog(@"Nx:%f, Ny:%f, Nz:%f", x, y, z);
    }
    
    return normalsArrays;
}

void minus10(int *v)
{
    *v = *v - 10;
}

int jRandInt()
{
    NSInteger r = RANDOM_01;
    return (int)r ;
}

-(void)structPointerTest:(int)runTimes
{
    struct date {
        int month;
        int day;
        int year;
    };
    
    struct date *birthday;
    
    birthday = (struct date *)malloc(sizeof(struct date) * runTimes);
    
    // struct date b = *birthday;
    
    if (birthday == NULL) {
        puts("Memory Unavailible");
    }
    
    for (int x=0; x<runTimes; x++) {
        
        birthday->day = 2;
        birthday->month = 2;
        birthday->year = 1984;
        birthday++;
        
        
    }
    
    for (int x=0; x<runTimes; x++) {
         printf("You were born on %d/%d/%d\n",birthday->month,birthday->day,birthday->year);
    }
   
  
}

-(void)pointerTest2
{
    int array[] = {11,13,17,19};
    int x;
    int *aptr;
    
    aptr = array;
    
    for (x=0; x<4; x++) {
        printf("Element %d: %d\n",x+1,*aptr);
        aptr++;
    }
}

-(void)anotherPointerTest
{
    [self pointerTest2];
    NSInteger hSub = 10;
    NSInteger vSub = 10;
    NSInteger vcount = (hSub + 1) * (vSub + 1);
    NSInteger icount = (hSub * vSub) * 6;
    
    size_t sizeOfVerticies = sizeof(JDMVertex) * vcount;
    size_t sizeOfIndices = sizeof(unsigned short) * icount;
    
    JDMVertex *vertices = malloc(sizeOfVerticies);
    unsigned short *indices = malloc(sizeOfIndices);
    
    // with * its a mem loc
    // without * its th value
    
    
    JDMVertex *v = vertices;
    
    for (int i=1; i<10; i++) {
        v->x = (i*1);
        v++;
    }
    
    NSLog(@"v: %f",v->x);
    
    
    
    
    
    
    
    
    
}

-(void)simplePointerTest
{
    int year = 1967;
    int *pointer;
    pointer = &year;
    NSLog(@"%d",*pointer);
    *pointer = 1990;
    NSLog(@"%d",year);
}

-(void)pointerTest
{
    [self simplePointerTest];
    
    char model[5] = {
        'H',
        'o',
        'n',
        'd',
        'a'
    };
    
    char *modelPointer = &model[0];
    
    for (int i=0; i<5; i++,++modelPointer) {
        NSLog(@"Value at memory address %p is %c",modelPointer, *modelPointer);
        // modelPointer++;
    }
    
    LogCVar(modelPointer);
    
    NSLog(@"The first Letter is %c", *(modelPointer - 5));
    
    [self anotherPointerTest];
}


u_int num(int integer)
{
    u_int8_t number = 1;
    return number;
}

void LogCVar(void* var)
{
    unsigned long howManyBytes = sizeof(var);
    
    NSLog(@"The Variable take up %lu bytes.",howManyBytes);
}

-(void)logData:(NSData*)data BytesPerIndex:(NSInteger)bytesPerIndex
{
    size_t bytesSize = sizeof(data.bytes);
    LogCVar(bytesSize);
    NSInteger bytes = data.bytes;
    NSLog(@"bytes: %lu",(unsigned long)bytes);
    
    
    
    
    NSLog(@"#########");
    bytesPerIndex = sizeof(unsigned short);
    NSInteger length =  data.length;
    NSInteger numberOfIndices = data.length / bytesPerIndex ;

    NSLog(@"bytesPerIndex: %lu",(unsigned long)bytesPerIndex);
    NSLog(@"length: %lu",(unsigned long)length);
    NSLog(@"numberOfIndices: %lu",(unsigned long)numberOfIndices);
    
    
    int i = num(1);
    
    
    for (int x=0; x<numberOfIndices; x++) {
        
        unsigned short indy = sizeof(unsigned short);
        
        // The range of bytes for this vector
        NSRange byteRange = NSMakeRange(x * indy, // Start at current stride + offset
                                        bytesPerIndex);   // and read the lenght of one vector
        
        
        
        // Read into the vector data buffer
        [data getBytes:&indy range:byteRange];
        
        //  NSLog(@"Data-Byte: %hu",(unsigned short)indy);

    }
    
}

-(NSArray*)getIndicesFromGeometry:(SCNGeometry*)geometry
{
    SCNGeometryElement *element = [geometry geometryElementAtIndex:0];
    NSData *elementData = element.data;
    
    NSInteger bytesPerIndex = element.bytesPerIndex;
    NSInteger numberOfIndices = elementData.length / bytesPerIndex ;
    
    NSLog(@"elementData.length: %lu",(unsigned long)elementData.length);
    NSLog(@"numberOfIndices: %lu",(unsigned long)numberOfIndices);
    NSLog(@"bytesPerIndex: %lu",(unsigned long)bytesPerIndex);
    
    NSMutableArray *indicies = [[NSMutableArray alloc]init];
    
    // number of prim - triangles;
    // NSInteger primitiveCount = element.primitiveCount;
    
    for (int x = 0; x<numberOfIndices; x++) {
        
        unsigned short indice = sizeof(unsigned short);
        
        // The range of bytes for this vector
        NSRange byteRange = NSMakeRange(x * indice, // Start at current stride + offset
                                        bytesPerIndex);   // and read the lenght of one vector
        
        // Read into the vector data buffer
        [element.data getBytes:&indice range:byteRange];
        
        // NSLog(@"indice: %hu",(unsigned short)indice);
    
        [indicies addObject:[NSNumber numberWithUnsignedShort:indice]];
    }
        return indicies;
}



#pragma mark - Line & Point Geometry

-(NSArray*)randomPoints:(int)numberOfPoints rangeVector:(SCNVector3)rangeVector
{
    // starting vector 0,0,0 - center;
    
    
    NSMutableArray *points = [[NSMutableArray alloc]init];
    
    for (int x=0; x<numberOfPoints; x++) {
        
        float x = rangeVector.x * (float)(arc4random() / ARC4RANDOM_MAX ) ;
        float y = rangeVector.y * (float)(arc4random() / ARC4RANDOM_MAX ) ;
        float z = rangeVector.z * (float)(arc4random() / ARC4RANDOM_MAX ) ;
        
        SCNVector3 randomVector = SCNVector3Make(x, y, z);
       
        [points addObject:[NSValue valueWithSCNVector3:randomVector]];
        

    }
    
    
    return @[];
}


#pragma mark - Mesh








@end
