//
//  C3DVertexBuffer.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DVertexBuffer.h"

#import "C3DProgram.h"

// ???: separate vertex array classes for each type?

GLsizei C3DSizeForVertexBufferType(C3DVertexBufferType type) {
	GLsizei size;
	switch (type) {
		case C3DVertexBufferColour:
		case C3DVertexBufferSecondaryColour:
			size = 4;
			break;
		case C3DVertexBufferPosition:
		case C3DVertexBufferNormal:
			size = 3;
			break;
		case C3DVertexBufferTextureCoord:
		case C3DVertexBufferFogCoord:
			size = 2;
			break;
		case C3DVertexBufferIndex:
		case C3DVertexBufferEdgeFlag:
			size = 1;
			break;
	}
	
	return size;
}

static NSArray *attributeNames;

NSArray *C3DAttributeNames( void ) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeNames = @[@"colour", @"colour2", @"position", @"normal", @"texCoord", @"fogCoord", @"index", @"edgeFlag"];
    });
    return attributeNames;
}

NSString *C3DAttributeNameForVertexBufferType(C3DVertexBufferType type) {
	return C3DAttributeNames()[(NSUInteger)type];
}

@interface NSData (C3DVertexBufferData)
- (NSUInteger)countForType:(C3DVertexBufferType)type;
@end

@implementation C3DVertexBuffer {
	GLuint _bufferName;
    GLenum _bufferTarget;
    BOOL _ownsBuffer;
}

#pragma mark - NSObject

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"[%@ %p] %@ %tu", [self class], self, C3DAttributeNameForVertexBufferType(_type), _count];
}

- (void)dealloc {
    if (_bufferName > 0) {
        [self delete];
    }
}

#pragma mark - C3DVertexBuffer

- (NSString *)attributeName {
	return C3DAttributeNameForVertexBufferType(_type);
}

- (void)genBuffer {
    NSAssert(_bufferName == 0, @"Attempt to regenerate vertex buffer");
    glGenBuffers(1, &_bufferName);
    _ownsBuffer = YES;
}

- (void)loadDataForBuffer:(GLuint)buffer {
    glBindBuffer(_bufferTarget, buffer);
    glBufferData(_bufferTarget, [_elements length], [_elements bytes], GL_STATIC_DRAW);
}

- (void)bind {
    if (_bufferName == 0) {
        [self genBuffer];
        [self loadDataForBuffer:_bufferName];
    }
    else {
        glBindBuffer(_bufferTarget, _bufferName);
    }
}

- (void)delete {
    NSAssert(_bufferName > 0, @"Attempt to delete vertex buffer twice");
    glDeleteBuffers(1, &_bufferName);
    _bufferName = 0;
    _ownsBuffer = NO;
}

- (void)loadInBuffer:(GLuint)buffer forProgram:(C3DProgram *)program {
    
    [self loadDataForBuffer:buffer];

    // FIXME: responsibility of the program, not the array?
    if (program && _type != C3DVertexBufferIndex) {

        GLboolean normalize = GL_FALSE;
        GLenum dataType = GL_FLOAT;
        
        if (_type == C3DVertexBufferNormal) {
            normalize = GL_TRUE;
            dataType = GL_INT;
        }
        
        GLuint location = [program locationForAttribute:C3DAttributeNameForVertexBufferType(_type)];
        
        glEnableVertexAttribArray(location);
        glVertexAttribPointer(location, C3DSizeForVertexBufferType(_type), dataType, normalize, 0, 0);
    }
}

- (instancetype)initWithType:(C3DVertexBufferType)type data:(NSData *)data count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _type = type;
        _count = count;
        _elements = data;
        _bufferTarget = _type == C3DVertexBufferIndex ? GL_ELEMENT_ARRAY_BUFFER : GL_ARRAY_BUFFER;
    }
    return self;
}

- (instancetype)initWithType:(C3DVertexBufferType)type data:(NSData *)data {
	return [self initWithType:type data:data count:[data countForType:type]];
}

- (instancetype)initWithType:(C3DVertexBufferType)type elements:(void *)elements count:(NSUInteger)count {
    NSData *data = [NSData dataWithBytes:elements length:count * C3DSizeForVertexBufferType(type) * C3DPrimitiveSizeForVertexBufferType(type)];
    return [self initWithType:type data:data count:count];
}

- (instancetype)init {
    return [self initWithType:C3DVertexBufferPosition elements:NULL count:0];
}

+ (instancetype)coloursWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferColour elements:elements count:count];
}

+ (instancetype)secondaryColoursWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferSecondaryColour elements:elements count:count];
}

+ (instancetype)positionsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferPosition elements:elements count:count];
}

+ (instancetype)normalsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferNormal elements:elements count:count];
}

+ (instancetype)texCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferTextureCoord elements:elements count:count];
}

+ (instancetype)fogCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferFogCoord elements:elements count:count];
}

+ (instancetype)indicesWithElements:(GLuint *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferIndex elements:elements count:count];
}

+ (instancetype)edgeFlagsWithElements:(GLuint *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferEdgeFlag elements:elements count:count];
}

@end

@implementation NSData (C3DVertexBufferData)

- (NSUInteger)countForType:(C3DVertexBufferType)type {
	return [self length] / (C3DSizeForVertexBufferType(type) * C3DPrimitiveSizeForVertexBufferType(type));
}

@end
