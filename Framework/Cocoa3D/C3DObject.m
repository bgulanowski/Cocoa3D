//
//  C3DObject.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DObject.h"

#import "C3DCameraGL1.h"
#import "C3DProgram.h"
#import "C3DTransform.h"
#import "C3DVertexBuffer.h"

#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#elif C3D_GL_COMPATIBILITY
#import <OpenGL/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

@implementation C3DObject {
    // ???: separate classes for each type?
	C3DObjectType _type;
	GLuint _vao;
    // FIXME: These buffers should be in the vertex arrays, not in here
	GLuint *_buffers;
	GLsizei _bufferCount;
	NSUInteger _elementCount;
	BOOL _indexed;
}

#pragma mark - Accessors

- (void)setProgram:(C3DProgram *)program {
    // FIXME: Should this only release if removing program, and allocate if adding program? Or not at all?
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

#pragma mark - NSObject

- (void)dealloc {
	[self releaseBuffers];
}

#pragma mark - C3DVisible

- (void)paintForCamera:(C3DCamera *)camera {
    
    [_program prepareToDraw];
    [_program loadMVPMatrix:[camera currentTransform]];
    
    if (_vao) {
        // Binding the vertex array automatically binds all the individual arrays (VBOs)
        glBindVertexArray(_vao);
    }
    else {
        [C3DCameraGL1 enableVertexBuffers:_vertexBuffers];
        [C3DCameraGL1 loadVertexBuffers:_vertexBuffers];
    }
    if (_indexed) {
        [camera drawElementsWithType:_type count:_elementCount];
    }
    else {
        [camera drawArraysWithType:_type count:_elementCount];
    }
    if (!_vao) {
        [C3DCameraGL1 disableVertexBuffers:_vertexBuffers];
    }
}

// FIXME: this is too simple-minded
// position array should be explicitly specified (it's mandatory)
// index array should be explicitly specified (it's optional)
// additional arrays should be length checked to match position array
// should support interleaved arrays for vertex attributes
// should support dynamic_draw (see c3dvertexarray class which is only static_draw)
// should support adding and removing additional vertex attributes (normals, fog, secondary colour etc)
- (instancetype)initWithType:(C3DObjectType)type vertexBuffers:(NSArray *)vertexBuffers program:(C3DProgram *)program {

	self = [super init];
	if (self) {
		_type = type;
		_vertexBuffers = vertexBuffers;
		_program = program;
        NSUInteger vCount = 0, iCount = 0;
        for (C3DVertexBuffer *vertexBuffer in _vertexBuffers) {
            if (vertexBuffer.type == C3DVertexBufferPosition) {
                vCount = [vertexBuffer count];
            }
            else if (vertexBuffer.type == C3DVertexBufferIndex) {
                iCount = [vertexBuffer count];
                _indexed = YES;
            }
        }
        _elementCount = iCount ?: vCount;
		if (_program) {
			[self allocateBuffers];
			[self refreshBuffers];
		}
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
}

- (void)allocateBuffers {
	_bufferCount = (GLsizei)[_vertexBuffers count];
	_buffers = malloc(sizeof(GLuint) * _bufferCount);
	glGenBuffers(_bufferCount, _buffers);
	glGenVertexArrays(1, &_vao);
}

- (void)refreshBuffers {
	
	glBindVertexArray(_vao);
	
	NSUInteger i = 0;
	for (C3DVertexBuffer *vertexBuffer in _vertexBuffers) {
		[vertexBuffer loadInBuffer:_buffers[i++] forProgram:_program];
	}
		
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);
}

@end
