//
//  C3DObject.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DObject.h"

#import "C3DVertexArray.h"
#import "C3DProgram.h"
#import "C3DTransform.h"

#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

@implementation C3DObject {
	C3DObjectType _type;
	GLuint _vao;
	GLuint *_buffers;
	GLsizei _bufferCount;
	NSUInteger _elementCount;
	BOOL _indexed;
}

#pragma mark - Accessors

- (void)setProgram:(C3DProgram *)program {
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
		glBindVertexArray(_vao);
	}
	else {
		[_vertexArrays makeObjectsPerformSelector:@selector(submit)];
	}
	if (_indexed) {
		[camera drawElementsWithType:_type count:_elementCount];
	}
	else {
		[camera drawArraysWithType:_type count:_elementCount];
	}
}

// FIXME: this is too simple-minded
// position array should be explicitly specified (it's mandatory)
// index array should be explicitly specified (it's optional)
// additional arrays should be length checked to match position array
// should support interleaved arrays for vertex attributes
// should support dynamic_draw (see c3dvertexarray class which is only static_draw)
// should support adding and removing additional vertex attributes (normals, fog, secondary colour etc)
- (instancetype)initWithType:(C3DObjectType)type vertexArrays:(NSArray *)vertexArrays program:(C3DProgram *)program {

	self = [super init];
	if (self) {
		_type = type;
		_vertexArrays = vertexArrays;
		_program = program;
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
	_bufferCount = (GLsizei)[_vertexArrays count];
	_buffers = malloc(sizeof(GLuint) * _bufferCount);
	glGenBuffers(_bufferCount, _buffers);
	glGenVertexArrays(1, &_vao);
}

- (void)refreshBuffers {
	
	glBindVertexArray(_vao);
	
	NSUInteger i = 0;
	NSUInteger vCount = 0, iCount = 0;
	for (C3DVertexArray *vertexArray in _vertexArrays) {
		if (vertexArray.type == C3DVertexArrayPosition) {
			vCount = [vertexArray count];
		}
		else if (vertexArray.type == C3DVertexArrayIndex) {
			iCount = [vertexArray count];
			_indexed = YES;
		}
		[vertexArray loadInBuffer:_buffers[i++] forProgram:_program];
	}
	
	_elementCount = iCount ?: vCount;
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);
}

@end
