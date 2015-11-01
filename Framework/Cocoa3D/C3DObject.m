//
//  C3DObject.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DObject.h"

#import "C3DProgram.h"
#import "C3DTransform.h"
#import "C3DVertexBuffer.h"

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

@implementation C3DObject {
    // ???: separate classes for each type?
	C3DObjectType _type;
	GLuint _vao;
    // FIXME: These buffers should be in the vertex arrays, not in here
	GLuint *_buffers;
	GLsizei _bufferCount;
}

#pragma mark - Accessors

- (void)setProgram:(C3DProgram *)program {
    // FIXME: Should this only release if removing program, and allocate if adding program? Or not at all?
    if (_vertexBuffers.count == 0) {
        NSLog(@"WARNING: No vertex buffers available when setting program; nothing to draw!");
    }
	if (_program != program) {
		if (_program) {
			[self releaseBuffers];
		}
		_program = program;
		if (_program) {
			[self allocateBuffers];
			[self refreshBuffers];
		}
	}
}

- (void)setIndexElements:(C3DIndexBuffer *)indexElements
{
    _indexElements = indexElements;
}

#pragma mark - NSObject

- (void)dealloc {
	[self releaseBuffers];
}

#pragma mark - C3DVisible

- (NSDictionary *)uniformValuesWithCamera:(C3DCamera *)camera {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    NSArray *uniforms = [_program activeUniforms];
    if ([uniforms containsObject:C3DUniformMVPMatrix]) {
        values[C3DUniformMVPMatrix] = _ignoresTransform ? [camera currentRelativeTransform] : [camera currentTransform];
    }
    if ([uniforms containsObject:C3DUniformProjectionMatrix]) {
        values[C3DUniformProjectionMatrix] = camera.projection;
    }
    return values;
}

- (void)paintForCamera:(C3DCamera *)camera {
    
    [_program loadUniformValues:[self uniformValuesWithCamera:camera]];

    if (_vao) {
        // Binding the vertex array automatically binds all the individual arrays (VBOs)
        glBindVertexArray(_vao);
    }
#if ! TARGET_OS_IPHONE
    else {
        // FIXME: update for iOS!
        [C3DCameraGL1 enableVertexBuffers:_vertexBuffers];
        [C3DCameraGL1 loadVertexBuffers:_vertexBuffers];
        [C3DCameraGL1 enableIndexBuffer];
        [C3DCameraGL1 loadIndexBuffer:_indexElements];
    }
#endif
    if (_indexElements) {
        [camera drawElementsWithType:_type count:_indexElements.count];
    }
    else {
        [camera drawArraysWithType:_type count:[[_vertexBuffers firstObject] count]];
    }
#if ! TARGET_OS_IPHONE
    if (!_vao) {
        [C3DCameraGL1 disableVertexBuffers:_vertexBuffers];
    }
#endif
}

#pragma mark - Designated Initializer

// FIXME: this is too simple-minded
// position array should be explicitly specified (it's mandatory)
// index array should be explicitly specified (it's optional)
// additional arrays should be length checked to match position array
// should support interleaved arrays for vertex attributes
// should support dynamic_draw (see c3dvertexarray class which is only static_draw)
// should support adding and removing additional vertex attributes (normals, fog, secondary colour etc)
- (instancetype)initWithType:(C3DObjectType)type {
	self = [super init];
	if (self) {
		_type = type;
	}
    return self;
}

#pragma mark - Private

- (void)releaseBuffers {
	if (_bufferCount > 0) {
		glDeleteBuffers(_bufferCount, _buffers);
		free(_buffers);
		_bufferCount = 0;
		_buffers = NULL;
	}
    if (_vao) {
        glDeleteVertexArrays(1, &_vao);
        _vao = 0;
    }
}

- (void)allocateBuffers {
	_bufferCount = (GLsizei)[_vertexBuffers count];
    if (_indexElements) {
        ++_bufferCount;
    }
	_buffers = malloc(sizeof(GLuint) * _bufferCount);
	glGenBuffers(_bufferCount, _buffers);
	glGenVertexArrays(1, &_vao);
}

- (void)refreshBuffers {
	
	glBindVertexArray(_vao);
	
	NSUInteger i = 0;
	for (C3DVertexBuffer *vertexBuffer in _vertexBuffers) {
		[vertexBuffer loadDataForBuffer:_buffers[i++]];
        [_program enableVertexBuffer:vertexBuffer];
	}
    
    [_indexElements loadDataForBuffer:_buffers[i]];
    
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);
}

@end
