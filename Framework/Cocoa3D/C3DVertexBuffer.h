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

typedef NS_ENUM(NSUInteger, C3DVertexArrayType) {
	// quadruples
	C3DVertexArrayColour,
	C3DVertexArraySecondaryColour,
	// triples
	C3DVertexArrayPosition,
	C3DVertexArrayNormal,
	// pairs
	C3DVertexArrayTextureCoord,
	C3DVertexArrayFogCoord,
	// scalars
    // FIXME: this is colour index array, not vertex indices
	C3DVertexArrayIndex,
	C3DVertexArrayEdgeFlag
};

extern GLsizei C3DSizeForVertexArrayType(C3DVertexArrayType type);
extern NSArray *C3DAttributeNames( void );

NS_INLINE GLenum C3DPrimitiveTypeForVertexArrayType(C3DVertexArrayType type) {
	return type == C3DVertexArrayIndex ? GL_UNSIGNED_INT : GL_FLOAT;
}

NS_INLINE GLsizei C3DPrimitiveSizeForVertexArrayType(C3DVertexArrayType type) {
	return type == C3DVertexArrayIndex ? sizeof(GLuint) : sizeof(GLfloat);
}

@class C3DProgram;

@interface C3DVertexBuffer : NSObject

@property (nonatomic) C3DVertexArrayType type;
@property (nonatomic) NSData *elements;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSString *attributeName;

- (void)bind;
- (void)delete;
- (void)loadInBuffer:(GLuint)buffer forProgram:(C3DProgram *)program;

- (instancetype)initWithType:(C3DVertexArrayType)type data:(NSData *)data count:(NSUInteger)count NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithType:(C3DVertexArrayType)type data:(NSData *)data;
- (instancetype)initWithType:(C3DVertexArrayType)type elements:(void *)elements count:(NSUInteger)count;

+ (instancetype)coloursWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)secondaryColoursWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)positionsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)normalsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)texCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)fogCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)indicesWithElements:(GLuint *)elements count:(NSUInteger)count;
+ (instancetype)edgeFlagsWithElements:(GLuint *)elements count:(NSUInteger)count;

@end
