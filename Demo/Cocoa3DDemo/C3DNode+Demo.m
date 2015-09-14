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

+ (instancetype)nodeWithObject:(C3DObject *)object position:(LIVector_t)position {
    
    C3DNode *node = [C3DNode new];
    node.object = object;;
    
    C3DTransform *transform = [C3DTransform identity];
    [transform translate:position];
    node.transform = transform;
    
    return node;
}

+ (instancetype)demoCubeNodeWithPosition:(LIVector_t)position {
    return [self nodeWithObject:[C3DObject demoCubeWithProgram:[C3DProgram demoProgram]] position:position];
}

+ (instancetype)unitRegularTetrahedronWithPosition:(LIVector_t)position {
    return [self nodeWithObject:[C3DObject unitRegularTetrahedron] position:position];
}

+ (instancetype)unitCornerTetrahedronWithPosition:(LIVector_t)position {
    return [self nodeWithObject:[C3DObject unitCornerTetrahedron] position:position];
}

+ (instancetype)unitCubeNodeWithPosition:(LIVector_t)position {
    return [self nodeWithObject:[C3DObject unitCube] position:position];
}

+ (instancetype)unitRectangularPrismWithPosition:(LIVector_t)position {
    return [self nodeWithObject:[C3DObject unitRectangularPrism] position:position];
}

+ (instancetype)cubeGridWithDimension:(NSUInteger)dim {
    
    NSMutableArray *children = [NSMutableArray array];
    for (float k=0; k<dim; ++k) {
        for (float j=0; j<dim; ++j) {
            for (float i=0; i<dim; ++i) {
                [children addObject:[self unitCubeNodeWithPosition:LIVectorScale(LIVectorMake(i, j, k), 2.0f)]];
            }
        }
    }
    
    const float offset = -(float)dim;
    C3DNode *node = [self nodeWithObject:nil position:LIVectorMake(offset, offset, offset)];
    node.children = children;
    
    return node;
}

+ (instancetype)tetrahedronWithPosition:(LIVector_t)position {
    return [self nodeWithObject:[C3DObject equilateralTetrahedron] position:position];
}

+ (instancetype)prismNodeWithPosition:(LIVector_t)position {
    return [self nodeWithObject:[C3DObject equilateralRectangularPrism] position:position];
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
        [children addObject:[self nodeWithObject:object position:LIVectorMake(2.0f*i-5.0f, -2.0f, 0.0f)]];
        i++;
    }
    
    rootNode.children = children;	
	return rootNode;
}

@end
