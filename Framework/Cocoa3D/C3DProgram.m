//
//  C3DProgram.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DProgram.h"

#import "C3DCamera.h"
#import "C3DObject.h"
#import "C3DShader.h"
#import "C3DTransform.h"
#import "C3DVertexBuffer.h"

#import "NSOpenGLContext+Cocoa3D.h"

GLint const C3DLocationUnknown = -1;

#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

void * attributeKVOContext = &attributeKVOContext;
void *   uniformKVOContext = &uniformKVOContext;

NSString * const C3DUniformModelMatrix = @"modelMatrix";
NSString * const C3DUniformViewMatrix = @"viewMatrix";
NSString * const C3DUniformProjectionMatrix = @"projectionMatrix";
NSString * const C3DUniformNormalMatrix = @"normalMatrix";
NSString * const C3DUniformModelViewMatrix = @"modelViewMatrix";
NSString * const C3DUniformMVPMatrix = @"MVP"; // modelViewProjectionMatrix

#pragma mark -

@implementation C3DProgram {
	GLuint _name;
	NSDictionary *_attributeLocations;
	NSDictionary *_uniforms;
	NSMutableDictionary *_attributeBindings;
	NSMutableDictionary *_uniformBindings;
}

#pragma mark - Designated Initializer

- (instancetype)initWithVertexShader:(C3DShader *)vertexShader fragmentShader:(C3DShader *)fragmentShader attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms {
    
    NSParameterAssert(vertexShader);
    NSParameterAssert(fragmentShader);
    
	self = [super init];
	if (self) {
        
        BOOL success = [vertexShader compile] && [fragmentShader compile];
        if (success) {
            _name = glCreateProgram();
            glAttachShader(_name, [vertexShader shaderName]);
            glAttachShader(_name, [fragmentShader shaderName]);
            glLinkProgram(_name);
            success = [self linkStatus];
        }
        if(success) {
            _attributeLocations = [self locationsForAttributes:attributes];
            _uniforms = [self locationsForUniforms:uniforms];
            _attributeBindings = [NSMutableDictionary dictionary];
            _uniformBindings = [NSMutableDictionary dictionary];
        }
        else {
            NSLog(@"Failed to link program: %@", [self linkLog]);
            self = nil;
        }
    }
	
	return self;
}

#pragma mark - NSObject

- (void)dealloc {
    glDeleteProgram(_name);
	[self removeAllBindings];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
}

#pragma mark - C3DProgram

- (NSDictionary *)locationsForAttributes:(NSArray *)attributes {
    NSMutableDictionary *locations = [NSMutableDictionary dictionary];
    for (NSString *attributeName in attributes) {
        GLint const location = glGetAttribLocation(_name, [attributeName UTF8String]);
        if (location != C3DLocationUnknown) {
            locations[attributeName] = @(location);
        }
    }
    return locations;
}

- (NSDictionary *)locationsForUniforms:(NSArray *)uniforms {
    NSMutableDictionary *locations = [NSMutableDictionary dictionary];
    for (NSString *uniformName in uniforms) {
        GLint const location = glGetUniformLocation(_name, [uniformName UTF8String]);
        if (location != C3DLocationUnknown) {
            locations[uniformName] = [C3DUniform uniformWithName:uniformName location:location];
        }
    }
    return locations;
}

- (void)enableVertexBuffer:(C3DVertexBuffer *)vertexBuffer {
    
    C3DVertexBufferType type = vertexBuffer.type;
    
    GLuint location = [self locationForAttribute:C3DAttributeNameForVertexBufferType(type)];
    if (location == C3DLocationUnknown) {
        return;
    }
    
    GLboolean normalize = GL_FALSE;
    GLenum dataType = GL_FLOAT;
    if (type == C3DVertexBufferNormal) {
        normalize = GL_TRUE;
        // ???: normals are floats; (indices are ints, but they aren't vertex buffers)
        // Where is the function to enable index buffers?
//        dataType = GL_INT;
    }
    
    glEnableVertexAttribArray(location);
    glVertexAttribPointer(location, C3DSizeForVertexBufferType(type), dataType, normalize, 0, 0);
}

- (instancetype)initWithName:(NSString *)name attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms {
    NSParameterAssert(name);
	C3DShader *vs = [C3DShader vertexShaderWithName:name];
	C3DShader *fs = [C3DShader fragmentShaderWithName:name];
	return [self initWithVertexShader:vs fragmentShader:fs attributes:attributes uniforms:uniforms];
}

- (instancetype)init {
    C3DShader *vertShader = nil;
    C3DShader *fragShader = nil;
    if ([NSOpenGLContext currentContext].usesCoreProfile) {
        vertShader = [C3DShader basic33VertexShader];
        fragShader = [C3DShader basic33FragmentShader];
    }
    else {
        vertShader = [C3DShader basicLegacyVertexShader];
        fragShader = [C3DShader basicLegacyFragmentShader];
    }
    return [self initWithVertexShader:vertShader fragmentShader:fragShader attributes:C3DAttributeNames() uniforms:@[C3DUniformMVPMatrix]];
}

- (void)prepareToDraw {
	glUseProgram(_name);
}

- (BOOL)linkStatus {
    GLint res = 0;
    glGetProgramiv(_name, GL_LINK_STATUS, &res);
    return res == GL_TRUE;
}

- (NSString *)linkLog {
    const int bufferLength = 1000;
    GLchar logs[bufferLength];
    logs[0] = '\0';
    glGetProgramInfoLog(_name, bufferLength, NULL, logs);
    return [NSString stringWithUTF8String:logs];
}

- (GLint)locationForAttribute:(NSString *)attribute {
    NSNumber *location = _attributeLocations[attribute];
    return location != nil ? [location intValue] : C3DLocationUnknown;
}

- (C3DUniform *)uniformWithName:(NSString *)name {
    return _uniforms[name];
}

- (GLint)locationForUniform:(NSString *)uniformName {
    C3DUniform *uniform = [self uniformWithName:uniformName];
    return uniform ? uniform.location : C3DLocationUnknown;
}

- (NSArray *)activeUniforms {
    return [_uniforms allKeys];
}

- (void)loadUniformValues:(NSDictionary *)values {
    glUseProgram(_name);
    for (NSString *name in values) {
        C3DUniform *uniform = [self uniformWithName:name];
        [uniform loadValue:values[name]];
    }
}

- (void)bindAttribute:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath {
	
}

- (void)bindUniform:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath {
	
}

- (void)removeAllBindings {

}

@end

#pragma mark -

@interface C3DUniformMatrix4 : C3DUniform
@end

#pragma mark -

static NSDictionary *uniformIndex;

@implementation C3DUniform

- (instancetype)initWithName:(NSString *)name location:(GLint)location {
    self = [super init];
    if (self) {
        _name = name;
        _location = location;
    }
    return self;
}

/*
 * Every uniform has a name, type, and location, defined in the program.
 * The value is acquired from a source that recognizes the name and type.
 */

- (void)loadValue:(id)value {}

+ (instancetype)uniformWithName:(NSString *)name location:(GLint)location {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uniformIndex = @{
                         C3DUniformModelMatrix : [C3DUniformMatrix4 class],
                         C3DUniformViewMatrix : [C3DUniformMatrix4 class],
                         C3DUniformProjectionMatrix : [C3DUniformMatrix4 class],
                         C3DUniformNormalMatrix : [C3DUniformMatrix4 class],
                         C3DUniformModelViewMatrix : [C3DUniformMatrix4 class],
                         C3DUniformMVPMatrix : [C3DUniformMatrix4 class],
                         };
    });
    
    Class class = uniformIndex[name];
    return [[class alloc] initWithName:name location:location];
}

@end

#pragma mark -

#define C3DAssertValue(_obj, _class) NSAssert([_obj isKindOfClass:[_class class]], @"Unsupported value type %@ for %@", [_obj class], self)

@implementation C3DUniformMatrix4

- (void)loadValue:(LIMatrix *)matrix {
    C3DAssertValue(matrix, LIMatrix);
    glUniformMatrix4fv(self.location, 1, GL_FALSE, matrix.r_matrix->i);
}

@end
