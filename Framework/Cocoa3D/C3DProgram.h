//
//  C3DProgram.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#if ! C3D_GL_COMPATIBILITY
#import <GLKit/GLKit.h>
#endif

@class C3DCamera;
@class C3DObject;
@class C3DShader;
@class LIMatrix;
@class C3DVertexBuffer;

@interface C3DProgram : NSObject
#if ! C3D_GL_COMPATIBILITY
<GLKNamedEffect>
#endif

@property (nonatomic, weak) C3DCamera *camera;

- (instancetype)initWithVertexShader:(C3DShader *)vertexShader fragmentShader:(C3DShader *)fragmentShader attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms;
- (instancetype)initWithName:(NSString *)name attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms;
- (GLint)locationForAttribute:(NSString *)attribute;
- (GLint)locationForUniform:(NSString *)uniform;
- (NSArray *)activeUniforms;

- (void)bindUniform:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath;
- (void)bindAttribute:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath;

- (void)enableVertexBuffer:(C3DVertexBuffer *)vertexBuffer;

- (void)loadUniformValues:(NSDictionary *)values;

@end

// Uniform loading support

extern NSString * const C3DUniformModelMatrix;
extern NSString * const C3DUniformViewMatrix;
extern NSString * const C3DUniformProjectionMatrix;
extern NSString * const C3DUniformNormalMatrix;
extern NSString * const C3DUniformModelViewMatrix;
extern NSString * const C3DUniformMVPMatrix;

extern GLint const C3DLocationUnknown;

@interface C3DUniform : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) GLint location;

@property (nonatomic, weak) id bindingTarget;
@property (nonatomic, strong) NSString *bindingKeyPath;

- (void)loadValue:(id)value;

// returns an object that implements -loadValue for the derived type and size
+ (instancetype)uniformWithName:(NSString *)name location:(GLint)location;

@end
