//
//  C3DProgram.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DProgram.h"

#import "C3DShader.h"
#import "C3DTransform.h"
#import "C3DVertexBuffer.h"

#import "NSOpenGLContext+Cocoa3D.h"

#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

void * attributeKVOContext = &attributeKVOContext;
void *   uniformKVOContext = &uniformKVOContext;

#pragma mark -

@implementation C3DProgram {
	GLuint _name;
	NSDictionary *_attributeLocations;
	NSDictionary *_uniformLocations;
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
            _uniformLocations = [self locationsForUniforms:uniforms];
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
        if (location > -1) {
            locations[attributeName] = @(location);
        }
    }
    return locations;
}

- (NSDictionary *)locationsForUniforms:(NSArray *)uniforms {
    NSMutableDictionary *locations = [NSMutableDictionary dictionary];
    for (NSString *uniformName in uniforms) {
        GLint const location = glGetUniformLocation(_name, [uniformName UTF8String]);
        if (location > -1) {
            locations[uniformName] = @(location);
        }
    }
    return locations;
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
    return [self initWithVertexShader:vertShader fragmentShader:fragShader attributes:C3DAttributeNames() uniforms:@[@"MVP"]];
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
    glGetShaderInfoLog(_name, bufferLength, NULL, logs);
    return [NSString stringWithUTF8String:logs];
}

- (GLint)locationForAttribute:(NSString *)attribute {
    NSNumber *location = _attributeLocations[attribute];
    return location != nil ? [location intValue] : -1;
}

- (GLint)locationForUniform:(NSString *)uniform {
    NSNumber *location = _uniformLocations[uniform];
    return location != nil ? [location intValue] : -1;
}

- (void)bindAttribute:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath {
	
}

- (void)bindUniform:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath {
	
}

- (void)removeAllBindings {
	
}

- (void)loadMVPMatrix:(C3DTransform *)matrix {
    GLint location = [self locationForUniform:@"MVP"];
    if (location != -1) {
        glUniformMatrix4fv(location, 1, GL_FALSE, matrix.r_matrix->i);
    }
}

@end
