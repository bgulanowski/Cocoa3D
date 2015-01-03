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
@class C3DTransform;

@interface C3DProgram : NSObject
#if ! C3D_GL_COMPATIBILITY
<GLKNamedEffect>
#endif

@property (nonatomic, weak) C3DCamera *camera;

- (instancetype)initWithVertexShader:(id)vertexShader fragmentShader:(id)fragmentShader;
- (instancetype)initWithName:(NSString *)name attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms;
- (GLuint)locationForAttribute:(NSString *)attribute;
- (GLuint)locationForUniform:(NSString *)uniform;

- (void)bindUniform:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath;
- (void)bindAttribute:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath;

- (void)loadMVPMatrix:(C3DTransform *)matrix;

@end
