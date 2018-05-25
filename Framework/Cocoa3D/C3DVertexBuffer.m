//
//  C3DVertexBuffer.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DVertexBuffer.h"

#import "C3DProgram.h"


#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
    #import "C3DCameraGL1.h"
    #if C3D_GL_COMPATIBILITY
        #import <OpenGL/gl.h>
    #else
        #import <OpenGL/gl3.h>
    #endif
#endif

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
        case C3DVertexBufferPosition2D:
		case C3DVertexBufferTextureCoord:
		case C3DVertexBufferFogCoord:
			size = 2;
			break;
		case C3DVertexBufferEdgeFlag:
			size = 1;
			break;
	}
	
	return size;
}

NSUInteger const C3DVertexBufferTypeCount = C3DVertexBufferEdgeFlag + 1;

static NSArray *attributeNames;

NSArray *C3DAttributeNames( void ) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeNames = @[@"colour", @"colour2", @"position", @"normal", @"position2D", @"texCoord", @"fogCoord", @"edgeFlag"];
    });
    return attributeNames;
}

NSString *C3DAttributeNameForVertexBufferType(C3DVertexBufferType type) {
	return C3DAttributeNames()[(NSUInteger)type];
}

#pragma mark -

@interface NSData (C3DVertexBufferData)
- (NSUInteger)countForType:(C3DVertexBufferType)type;
@end

#pragma mark -

@implementation C3DBuffer {
@protected
    NSData *_elements;
    NSUInteger _count;
    GLuint _bufferName;
    GLenum _bufferTarget;
    BOOL _ownsBuffer;
}

- (instancetype)initWithData:(NSData *)data count:(NSUInteger)count target:(GLenum)target {
    self = [super init];
    if (self) {
        _count = count;
        _elements = data;
        _bufferTarget = target;
    }
    return self;
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

@end

#pragma mark -

@implementation C3DIndexBuffer

- (instancetype)init {
    return [self initWithData:nil count:0];
}

- (instancetype)initWithData:(NSData *)data count:(NSUInteger)count {
    return [super initWithData:data count:count target:GL_ELEMENT_ARRAY_BUFFER];
}

- (instancetype)initWithElements:(void *)elements count:(NSUInteger)count {
    NSData *data = [NSData dataWithBytes:elements length:count * sizeof(GLfloat)];
    return [self initWithData:data count:count];
}

+ (instancetype)indicesWithElements:(GLuint *)elements count:(NSUInteger)count {
    return [[self alloc] initWithElements:elements count:count];
}

@end

#pragma mark -

@implementation C3DVertexBuffer

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

- (instancetype)init {
    return [self initWithType:C3DVertexBufferPosition data:nil count:0];
}

- (instancetype)initWithType:(C3DVertexBufferType)type data:(nullable NSData *)data count:(NSUInteger)count {
    self = [super initWithData:data count:count target:GL_ARRAY_BUFFER];
    if (self) {
        _type = type;
    }
    return self;
}

- (instancetype)initWithType:(C3DVertexBufferType)type data:(nullable NSData *)data {
	return [self initWithType:type data:data count:[data countForType:type]];
}

- (instancetype)initWithType:(C3DVertexBufferType)type elements:(void *)elements count:(NSUInteger)count {
    NSData *data = [NSData dataWithBytes:elements length:count * C3DSizeForVertexBufferType(type) * sizeof(GLfloat)];
    return [self initWithType:type data:data count:count];
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

+ (instancetype)edgeFlagsWithElements:(GLuint *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexBufferEdgeFlag elements:elements count:count];
}

@end

@implementation NSData (C3DVertexBufferData)

- (NSUInteger)countForType:(C3DVertexBufferType)type {
	return [self length] / (C3DSizeForVertexBufferType(type) * sizeof(GLfloat));
}

@end
