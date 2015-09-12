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

#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

static NSString *attributeKVO = @"C3DProgramAttribute";
static NSString *uniformKVO = @"C3DProgramUniform";

@implementation C3DProgram {
	GLuint _name;
	NSMutableDictionary *_attributes;
	NSMutableDictionary *_uniforms;
	NSMutableDictionary *_attributeBindings;
	NSMutableDictionary *_uniformBindings;
}

#pragma mark - Designated Initializer

- (instancetype)initWithVertexShader:(id)vertexShader fragmentShader:(id)fragmentShader {
	self = [super init];
	if (self) {
		_attributes = [NSMutableDictionary dictionary];
		_uniforms = [NSMutableDictionary dictionary];
		_attributeBindings = [NSMutableDictionary dictionary];
		_uniformBindings = [NSMutableDictionary dictionary];
		_name = glCreateProgram();
		
		[vertexShader compile];
		[fragmentShader compile];
		
		glAttachShader(_name, [vertexShader shaderName]);
		glAttachShader(_name, [fragmentShader shaderName]);
		glLinkProgram(_name);
	}
	
	return self;
}

#pragma mark - NSObject

- (void)dealloc {
    glDeleteProgram(_name);
	[self removeAllBindings];
}

#pragma mark - C3DProgram

- (instancetype)initWithName:(NSString *)name attributes:(NSArray *)attributes uniforms:(NSArray *)uniforms {
	C3DShader *vs = [C3DShader vertexShaderWithName:name];
	C3DShader *fs = [C3DShader fragmentShaderWithName:name];
	if(! vs || !fs) return nil;
	self = [self initWithVertexShader:vs fragmentShader:fs];
	if (self) {
		for (NSString *attributeName in attributes) {
			_attributes[attributeName] = @(glGetAttribLocation(_name, [attributeName UTF8String]));
		}
		for (NSString *uniformName in uniforms) {
			_uniforms[uniformName] = @(glGetUniformLocation(_name, [uniformName UTF8String]));
		}
	}
	return self;
}

- (void)prepareToDraw {
	glUseProgram(_name);
}

- (GLuint)locationForAttribute:(NSString *)attribute {
	return (GLuint)[_attributes[attribute] unsignedIntValue];
}

- (GLuint)locationForUniform:(NSString *)uniform {
	return (GLuint)[_uniforms[uniform] unsignedIntValue];
}

- (void)bindAttribute:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath {
	
}

- (void)bindUniform:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath {
	
}

- (void)removeAllBindings {
	
}

- (void)loadMVPMatrix:(C3DTransform *)matrix {
	glUniformMatrix4fv([self locationForUniform:@"MVP"], 1, GL_FALSE, matrix.r_matrix->i);
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
}

@end
