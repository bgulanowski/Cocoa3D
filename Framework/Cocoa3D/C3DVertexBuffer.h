//
//  C3DVertexBuffer.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <OpenGLES/gltypes.h>
#else
#import <OpenGL/gltypes.h>
#endif

typedef NS_ENUM(NSUInteger, C3DVertexBufferType) {
	// quadruples
	C3DVertexBufferColour,
	C3DVertexBufferSecondaryColour,
	// triples
	C3DVertexBufferPosition,
	C3DVertexBufferNormal,
	// pairs
    C3DVertexBufferPosition2D,
	C3DVertexBufferTextureCoord,
	C3DVertexBufferFogCoord,
	// scalars
	C3DVertexBufferEdgeFlag,
};

NS_ASSUME_NONNULL_BEGIN

extern NSUInteger const C3DVertexBufferTypeCount;

extern GLsizei C3DSizeForVertexBufferType(C3DVertexBufferType type);
extern NSArray *C3DAttributeNames( void );
extern NSString *C3DAttributeNameForVertexBufferType(C3DVertexBufferType type);

@class C3DProgram;

@interface C3DBuffer : NSObject

@property (nonatomic) NSData *elements;
@property (nonatomic, readonly) NSUInteger count;

- (void)bind;
- (void)delete;
- (void)loadDataForBuffer:(GLuint)buffer;

@end

@interface C3DIndexBuffer : C3DBuffer
+ (instancetype)indicesWithElements:(GLuint *)elements count:(NSUInteger)count;
@end

@interface C3DVertexBuffer : C3DBuffer

@property (nonatomic) C3DVertexBufferType type;
@property (nonatomic, readonly) NSString *attributeName;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithType:(C3DVertexBufferType)type data:(nullable NSData *)data count:(NSUInteger)count NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithType:(C3DVertexBufferType)type data:(nullable NSData *)data;
- (instancetype)initWithType:(C3DVertexBufferType)type elements:(void *)elements count:(NSUInteger)count;

+ (instancetype)coloursWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)secondaryColoursWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)positionsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)normalsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)texCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)fogCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count;
+ (instancetype)edgeFlagsWithElements:(GLuint *)elements count:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END

