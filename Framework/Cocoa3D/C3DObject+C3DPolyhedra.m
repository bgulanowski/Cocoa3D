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

+ (instancetype)unitPolyhedronWithIndices:(C3DVertexBuffer *)indices {
    C3DObject *object = [[C3DObject alloc] initWithType:C3DObjectTypeTriangles];
    object.vertexBuffers = @[[C3DVertexBuffer unitPositions], [C3DVertexBuffer unitColours]];
    object.indexElements = indices;
    return object;
}

+ (instancetype)unitTetrahedron {
    GLuint indices[] = {
        0, 1, 2,
        0, 2, 4,
        0, 4, 1,
        1, 4, 2
    };
    return [self unitPolyhedronWithIndices:[C3DVertexBuffer indicesWithElements:&(indices[0]) count:3 * 4]];
}

+ (instancetype)unitRectangularPrism {
    
    GLuint indices[] = {
        // bottom
        0, 1, 2,
        // left
        0, 2, 6,
        0, 6, 4,
        // back
        0, 4, 5,
        0, 5, 1,
        // front
        1, 2, 6,
        1, 6, 5,
        // top
        4, 6, 5
    };
    return [self unitPolyhedronWithIndices:[C3DVertexBuffer indicesWithElements:&(indices[0]) count:3 * 8]];
}

+ (instancetype)unitCube {
    GLuint indices[] = {
        // bottom
        0, 1, 3,
        0, 3, 2,
        // left
        0, 2, 6,
        0, 6, 4,
        // back
        0, 4, 5,
        0, 5, 1,
        // right
        1, 5, 7,
        1, 7, 3,
        // front
        2, 3, 7,
        2, 7, 6,
        // top
        4, 5, 7,
        4, 7, 6,
    };
    return [self unitPolyhedronWithIndices:[C3DVertexBuffer indicesWithElements:&(indices[0]) count:3 * 12]];
}

+ (instancetype)tetrahedron {
    // TODO:
    return nil;
}

+ (instancetype)rectangularPrism {
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
