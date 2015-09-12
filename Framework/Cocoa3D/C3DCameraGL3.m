//
//  C3DCameraGL3.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-08-23.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DCameraGL3.h"
#import "C3DCamera_Private.h"

#import "C3DObject.h"
#import "C3DProgram.h"
#import "C3DShader.h"
#import "C3DVertexBuffer.h"

#import <OpenGL/gl3.h>

@interface C3DObject (C3DCameraDebugObjectCreating)
+ (instancetype)origin;
+ (instancetype)test;
@end

@interface C3DVertexBuffer (C3DCameraDebugObjectCreating)
+ (instancetype)originColours;
+ (instancetype)originPositions;
+ (instancetype)testColours;
+ (instancetype)testPositions;
+ (instancetype)testIndices;
@end

#pragma mark -

@implementation C3DCameraGL3 {
    C3DObject *_origin;
    C3DObject *_test;
}

#pragma mark - C3DCamera

- (void)setShowOriginOn:(BOOL)showOriginOn {
    [super setShowOriginOn:showOriginOn];
    if (showOriginOn && !_origin) {
        _origin = [C3DObject origin];
    }
}

- (void)setTestOn:(BOOL)testOn {
    [super setTestOn:testOn];
    if (testOn && !_test) {
        _test = [C3DObject test];
    }
}

- (void)paint {
    [super paint];
    if (self.options.showOriginOn) {
        [_origin paintForCamera:self];
    }
    if (self.options.testOn) {
        [_test paintForCamera:self];
    }
}

@end

#pragma mark -

@implementation C3DObject (C3DCameraDebugObjectCreating)

+ (instancetype)origin {
    C3DObject *object = [[self alloc] initWithType:C3DObjectTypeLines];
    object.program = [[C3DProgram alloc] init];
    object.vertexBuffers = @[[C3DVertexBuffer originColours], [C3DVertexBuffer originPositions]];
    return object;
}

+ (instancetype)test {
    C3DObject *object = [[self alloc] initWithType:C3DObjectTypeTriangles];
    object.program = [[C3DProgram alloc] init];
    object.vertexBuffers = @[[C3DVertexBuffer testColours], [C3DVertexBuffer testPositions]];
    object.indexElements = [C3DVertexBuffer testIndices];
    return object;
}

@end

@implementation C3DVertexBuffer (C3DCameraDebugObjectCreating)

+ (instancetype)originColours {
    
    GLfloat colours[] = {
        1, 1, 1, 1,
        1, 0, 0, 1,
        1, 1, 1, 1,
        0, 1, 0, 1,
        1, 1, 1, 1,
        0, 0, 1, 1,
    };
    
    return [C3DVertexBuffer coloursWithElements:colours count:6];
}

+ (instancetype)originPositions {
    
    GLfloat points[] = {
        0, 0, 0,
        1, 0, 0,
        0, 0, 0,
        0, 1, 0,
        0, 0, 0,
        0, 0, 1
    };
    
    return [C3DVertexBuffer positionsWithElements:points count:6];
}

+ (instancetype)testColours {
    
    GLfloat colours[] = {
        1, 0, 0, 1,
        1, 1, 0, 1,
        0, 1, 0, 1,
        0, 1, 1, 1,
        0, 0, 1, 1,
        1, 0, 1, 1
    };
    
    return [C3DVertexBuffer coloursWithElements:colours count:6];
}

+ (instancetype)testPositions {
    
    GLfloat points[] = {
        -1,  0,  0,
         1,  0,  0,
         0, -1,  0,
         0,  1,  0,
         0,  0, -1,
         0,  0,  1
    };
    
    return [C3DVertexBuffer positionsWithElements:points count:6];
}

+ (instancetype)testIndices {
    
    // Octahedron
    GLuint indices[] = {
        // lower half
        4, 2, 0,
        1, 2, 4,
        5, 2, 1,
        0, 2, 5,
        
        // upper half
        1, 3, 5,
        5, 3, 0,
        0, 3, 4,
        4, 3, 1
    };
    
    return [C3DVertexBuffer indicesWithElements:indices count:3 * 8];
}

@end
