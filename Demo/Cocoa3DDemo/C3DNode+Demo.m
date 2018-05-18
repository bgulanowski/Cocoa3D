//
//  C3DNode+Demo.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-11-18.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DNode+Demo.h"

#import "C3DProgram+Demo.h"
#import "C3DObject+Demo.h"

@implementation C3DNode (Demo)

+ (instancetype)nodeWithObject:(C3DObject *)object position:(LIVector_t)position rotation:(LIRotation_t)rotation {
    
    C3DNode *node = [C3DNode new];
    node.object = object;
    
    C3DTransform *transform = [C3DTransform identity];
    [transform rotate:rotation];
    [transform translate:position];
    node.transform = transform;
    
    return node;
}

+ (instancetype)nodeWithObject:(C3DObject *)object position:(LIVector_t)position {
    return [self nodeWithObject:object position:position rotation:LIRotationMake(1, 0, 0, 0)];
}

+ (instancetype)cubeGridWithDimension:(NSUInteger)dim {
    
    NSMutableArray *children = [NSMutableArray array];
    for (float k=0; k<dim; ++k) {
        for (float j=0; j<dim; ++j) {
            for (float i=0; i<dim; ++i) {
                [children addObject:[self nodeWithObject:[C3DObject unitCube] position:LIVectorScale(LIVectorMake(i, j, k), 2.0f)]];
            }
        }
    }
    
    const float offset = -(float)dim;
    C3DNode *node = [self nodeWithObject:nil position:LIVectorMake(offset, offset, offset)];
    node.children = children;
    
    return node;
}

+ (instancetype)demoScene {
	
	C3DNode *rootNode = [C3DNode new];
    C3DProgram *program = [C3DProgram demoProgram];
    NSArray *objects = @[
                         [C3DObject unitRegularTetrahedron],
                         [C3DObject unitCornerTetrahedron],
                         [C3DObject unitRectangularPrism],
                         [C3DObject equilateralTetrahedron],
                         ];
    
    NSUInteger i=0;
    NSMutableArray *children = [NSMutableArray array];
    for (C3DObject *object in objects) {
        object.program = program;
        [children addObject:[self nodeWithObject:object position:LIVectorMake(-2.0f * i, 0, 0)]];
        i++;
    }
    
    rootNode.children = children;	
	return rootNode;
}

+ (instancetype)testScene {
    
    C3DNode *rootNode = [C3DNode new];
    rootNode.object = [C3DObject demoTriangleWithProgram:[C3DProgram demoProgram]];
    return rootNode;
}

@end
