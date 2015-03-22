//
//  C3DVertexArray.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DVertexArray.h"

#import "C3DProgram.h"

// ???: separate vertex array classes for each type?

GLsizei C3DSizeForVertexArrayType(C3DVertexArrayType type) {
	GLsizei size;
	switch (type) {
		case C3DVertexArrayColour:
		case C3DVertexArraySecondaryColour:
			size = 4;
			break;
		case C3DVertexArrayPosition:
		case C3DVertexArrayNormal:
			size = 3;
			break;
		case C3DVertexArrayTextureCoord:
		case C3DVertexArrayFogCoord:
			size = 2;
			break;
		case C3DVertexArrayIndex:
		case C3DVertexArrayEdgeFlag:
			size = 1;
			break;
	}
	
	return size;
}

static NSArray *attributeNames;

NSArray *C3DAttributeNames( void ) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeNames = @[@"colour", @"colour2", @"position", @"normal", @"texCoord", @"FogCoord", @"Index", @"EdgeFlag"];
    });
    return attributeNames;
}

NSString *C3DAttributeNameForVertexArrayType(C3DVertexArrayType type) {
	return C3DAttributeNames()[(NSUInteger)type];
}

@interface NSData (C3DVertexArrayData)
- (NSUInteger)countForType:(C3DVertexArrayType)type;
@end

@implementation C3DVertexArray {
	GLuint _bufferName;
    GLenum _bufferTarget;
}

- (NSString *)attributeName {
	return C3DAttributeNameForVertexArrayType(_type);
}

// FIXME: this method is bullshit
- (void)bind {
    BOOL createAndLoad = 0 == _bufferName;
    if (createAndLoad) {
        glGenBuffers(1, &_bufferName);
    }
    glBindBuffer(_bufferTarget, _bufferName);
    if (createAndLoad) {
        glBufferData(_bufferTarget, [_elements length], [_elements bytes], GL_STATIC_DRAW);
    }
}

- (void)delete {
    if (_bufferName) {
        glDeleteBuffers(1, &_bufferName);
        _bufferName = 0;
    }
}

- (void)loadInBuffer:(GLuint)buffer forProgram:(C3DProgram *)program {
	
    if (0 == _bufferName) {
        _bufferName = buffer;
    }
    
    glBindBuffer(_bufferTarget, _bufferName);
    glBufferData(_bufferTarget, [_elements length], [_elements bytes], GL_STATIC_DRAW);
    
    if (_type == C3DVertexArrayIndex) {
		return;
	}

    // FIXME: responsibility of the program, not the array?
    if (program) {

        GLboolean normalize = GL_FALSE;
        GLenum dataType = GL_FLOAT;
        
        if (_type == C3DVertexArrayNormal) {
            normalize = GL_TRUE;
            dataType = GL_INT;
        }
        
        GLuint location = [program locationForAttribute:C3DAttributeNameForVertexArrayType(_type)];
        
        glEnableVertexAttribArray(location);
        glVertexAttribPointer(location, C3DSizeForVertexArrayType(_type), dataType, normalize, 0, 0);
    }
}

- (instancetype)initWithType:(C3DVertexArrayType)type data:(NSData *)data count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _type = type;
        _count = count;
        _elements = data;
        _bufferTarget = _type == C3DVertexArrayIndex ? GL_ELEMENT_ARRAY_BUFFER : GL_ARRAY_BUFFER;
    }
    return self;
}

- (instancetype)initWithType:(C3DVertexArrayType)type data:(NSData *)data {
	return [self initWithType:type data:data count:[data countForType:type]];
}

- (instancetype)initWithType:(C3DVertexArrayType)type elements:(void *)elements count:(NSUInteger)count {
    NSData *data = [NSData dataWithBytes:elements length:count * C3DSizeForVertexArrayType(type) * C3DPrimitiveSizeForVertexArrayType(type)];
    return [self initWithType:type data:data count:count];
}

+ (instancetype)coloursWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayColour elements:elements count:count];
}

+ (instancetype)secondaryColoursWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArraySecondaryColour elements:elements count:count];
}

+ (instancetype)positionsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayPosition elements:elements count:count];
}

+ (instancetype)normalsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayNormal elements:elements count:count];
}

+ (instancetype)texCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayTextureCoord elements:elements count:count];
}

+ (instancetype)fogCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayFogCoord elements:elements count:count];
}

+ (instancetype)indicesWithElements:(GLuint *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayIndex elements:elements count:count];
}

+ (instancetype)edgeFlagsWithElements:(GLuint *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayEdgeFlag elements:elements count:count];
}

@end

@implementation NSData (C3DVertexArrayData)

- (NSUInteger)countForType:(C3DVertexArrayType)type {
	return [self length] / (C3DSizeForVertexArrayType(type) * C3DPrimitiveSizeForVertexArrayType(type));
}

@end
