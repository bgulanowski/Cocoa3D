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

- (void)bindUniform:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath;
- (void)bindAttribute:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath;

- (void)enableVertexBuffer:(C3DVertexBuffer *)vertexBuffer;

- (void)loadMatrix:(LIMatrix *)matrix forUniform:(NSString *)uniform;
- (void)loadMVPMatrix:(LIMatrix *)matrix;

@end
