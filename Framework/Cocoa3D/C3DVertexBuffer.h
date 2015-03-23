//
//  C3DVertexBuffer.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#elif C3D_GL_COMPATIBILITY
#import <OpenGL/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

typedef NS_ENUM(NSUInteger, C3DVertexBufferType) {
	// quadruples
	C3DVertexBufferColour,
	C3DVertexBufferSecondaryColour,
	// triples
	C3DVertexBufferPosition,
	C3DVertexBufferNormal,
	// pairs
	C3DVertexBufferTextureCoord,
	C3DVertexBufferFogCoord,
	// scalars
    // FIXME: this is colour index array, not vertex indices
	C3DVertexBufferIndex,
	C3DVertexBufferEdgeFlag
};

extern GLsizei C3DSizeForVertexBufferType(C3DVertexBufferType type);
extern NSArray *C3DAttributeNames( void );

NS_INLINE GLenum C3DPrimitiveTypeForVertexBufferType(C3DVertexBufferType type) {
	return type == C3DVertexBufferIndex ? GL_UNSIGNED_INT : GL_FLOAT;
}

NS_INLINE GLsizei C3DPrimitiveSizeForVertexBufferType(C3DVertexBufferType type) {
	return type == C3DVertexBufferIndex ? sizeof(GLuint) : sizeof(GLfloat);
}

@class C3DProgram;

@interface C3DVertexBuffer : NSObject

@property (nonatomic) C3DVertexBufferType type;
@property (nonatomic) NSData *elements;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSString *attributeName;

- (void)bind;
- (void)delete;
- (void)loadInBuffer:(GLuint)buffer forProgram:(C3DProgram *)program;

- (instancetype)initWithType:(C3DVertexBufferType)type data:(NSData *)data count:(NSUInteger)count NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithType:(C3DVertexBufferType)type data:(NSData *)data;
- (instancetype)initWithType:(C3DVertexBufferType)type elements:(void *)elements count:(NSUInteger)count;

+ (instancetype)coloursWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)secondaryColoursWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)positionsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)normalsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)texCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)fogCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)indicesWithElements:(GLuint *)elements count:(NSUInteger)count;
+ (instancetype)edgeFlagsWithElements:(GLuint *)elements count:(NSUInteger)count;

@end
