//
//  C3DObject+C3DPolyhedra.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2015-09-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "C3DObject+C3DPolyhedra.h"

#import "C3DConstants.h"
#import "C3DVertexBuffer.h"

static LIVector_t points[] = {
    phhh, p1hh, ph1h, p11h,
    phh1, p1h1, ph11, p111
};

static C3DColour_t *colours;

static C3DVertexBuffer *unitPositions;
static C3DVertexBuffer *unitColours;


@implementation C3DObject (C3DPolyhedra)

+ (void)load {
    
}

+ (instancetype)unitPolyhedronWithIndices:(C3DIndexBuffer *)indices {
    C3DObject *object = [[C3DObject alloc] initWithType:C3DObjectTypeTriangles];
    object.vertexBuffers = @[[C3DVertexBuffer unitPositions], [C3DVertexBuffer unitColours]];
    object.indexElements = indices;
    return object;
}

+ (instancetype)unitCornerTetrahedron {
    GLuint indices[] = {
        0, 1, 2,
        0, 2, 4,
        0, 4, 1,
        1, 4, 2
    };
    C3DObject *object = [self unitPolyhedronWithIndices:[C3DIndexBuffer indicesWithElements:&(indices[0]) count:3 * 4]];
    object.name = @"Corner Tetrahedron";
    return object;
}

+ (instancetype)unitRegularTetrahedron {
    GLuint indices[] = {
        0, 3, 6,
        0, 5, 3,
        0, 6, 5,
        3, 5, 6
    };
    C3DObject *object = [self unitPolyhedronWithIndices:[C3DIndexBuffer indicesWithElements:&(indices[0]) count:3 * 4]];
    object.name = @"Regular Tetrahedron";
    return object;
}

+ (instancetype)unitRectangularPrism {
    
    GLuint indices[] = {
        // bottom
        0, 1, 2,
        // left
        0, 4, 6,
        0, 6, 2,
        // back
        0, 4, 5,
        0, 5, 1,
        // front
        1, 2, 6,
        1, 6, 5,
        // top
        4, 6, 5
    };
    C3DObject *object = [self unitPolyhedronWithIndices:[C3DIndexBuffer indicesWithElements:&(indices[0]) count:3 * 8]];
    object.name = @"Rectangular Prism";
    return object;
}

+ (instancetype)unitCube {
    GLuint indices[] = {
        // back
        0, 2, 3,
        0, 3, 1,
        // left
        0, 4, 6,
        0, 6, 2,
        // bottom
        0, 1, 5,
        0, 5, 4,
        // front
        4, 5, 7,
        4, 7, 6,
        // right
        1, 3, 7,
        1, 7, 5,
        // top
        2, 6, 7,
        2, 7, 3,
    };
    C3DObject *object = [self unitPolyhedronWithIndices:[C3DIndexBuffer indicesWithElements:&(indices[0]) count:3 * 12]];
    object.name = @"Cube";
    return object;
}

+ (instancetype)equilateralTetrahedron {
    
    const GLfloat unit = 1.0f;
    const GLfloat hu = unit * 0.5f;
    
    const GLfloat faceHeightSquared = unit * unit - hu * hu;
    const GLfloat fh = sqrtf(faceHeightSquared);
    const GLfloat hfh = fh * 0.5f;
    
    const GLfloat tetrahedronHeightSquared = fh * fh + hfh * hfh;
    const GLfloat th = sqrtf(tetrahedronHeightSquared);
    
    LIVector_t points[] = {
        {  hu,  0, -hfh },
        { -hu,  0, -hfh },
        {   0,  0,  hfh },
        {   0, th,    0 }
    };
    C3DColour_t colours[] = {
        { 1.0f, 0.0f, 0.0f },
        { 0.0f, 1.0f, 0.0f },
        { 0.0f, 0.0f, 1.0f },
        { 1.0f, 1.0f, 0.0f }
    };
    GLuint indices[] = {
        0, 2, 1,
        0, 1, 3,
        1, 2, 3,
        2, 0, 3
    };
    
    C3DVertexBuffer *pBuffer = [C3DVertexBuffer positionsWithElements:&(points[0].x)  count:4];
    C3DVertexBuffer *cBuffer = [C3DVertexBuffer   coloursWithElements:&(colours[0].a) count:4];
    
    C3DObject *object = [[C3DObject alloc] initWithType:C3DObjectTypeTriangles];
    object.vertexBuffers = @[pBuffer, cBuffer];
    object.indexElements = [C3DIndexBuffer indicesWithElements:&(indices[0]) count:3 * 4];
    object.name = @"Equilateral Tetrahedron";
    
    return object;
}

+ (instancetype)equilateralRectangularPrism {
    // TODO:
    return nil;
}

+ (instancetype)octahedron {
    // TODO:
    return nil;
}

@end

@implementation C3DVertexBuffer (C3DPolyhedra)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        colours = malloc(sizeof(C3DColour_t)*8);
        
        for (NSUInteger i=0; i<8; ++i) {
            LIVector_t v = points[i];
            colours[i] = (C3DColour_t){ v.x, v.y, v.z, 1.0f };
        }
        
        unitPositions = [self positionsWithElements:&(points[0].x) count:8];
        unitColours   = [self coloursWithElements:&(colours[0].a) count:8];
    });
}

+ (instancetype)unitPositions {
    return unitPositions;
}

+ (instancetype)unitColours {
    return unitColours;
}

@end
