//
//  C3DVertexArray.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DVertexArray.h"

#import "C3DProgram.h"

GLsizei C3DSizeForVertexArrayType(C3DVertexArrayType type) {
	GLsizei size;
	switch (type) {
		case C3DVertexArrayColour:
		case C3DVertexArraySecondaryColour:
			size = 4;
			break;
		case C3DVertexArrayPosition:
		case C3DVertexArrayNormal:
			size = 3;
			break;
		case C3DVertexArrayTextureCoord:
		case C3DVertexArrayFogCoord:
			size = 2;
			break;
		case C3DVertexArrayIndex:
		case C3DVertexArrayEdgeFlag:
			size = 1;
			break;
	}
	
	return size;
}

NSString *C3DAttributeNameForVertexArrayType(C3DVertexArrayType type) {
	static NSArray *attributeNames;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		attributeNames = @[@"colour", @"colour2", @"position", @"normal", @"texCoord", @"FogCoord", @"Index", @"EdgeFlag"];
	});
	return attributeNames[(NSUInteger)type];
}

@interface NSData (C3DVertexArrayData)
- (NSUInteger)countForType:(C3DVertexArrayType)type;
@end

@implementation C3DVertexArray {
	GLuint _name;
}

- (NSString *)attributeName {
	return C3DAttributeNameForVertexArrayType(_type);
}

- (void)submit {
	glBindVertexArray(_name);
}

- (void)loadInBuffer:(GLuint)buffer forProgram:(C3DProgram *)program {
	
	GLenum const target = _type == C3DVertexArrayIndex ? GL_ELEMENT_ARRAY_BUFFER : GL_ARRAY_BUFFER;

	glBindBuffer(target, buffer);
	glBufferData(target, [_elements length], [_elements bytes], GL_STATIC_DRAW);

	if (_type == C3DVertexArrayIndex) {
		return;
	}

	GLuint location = [program locationForAttribute:C3DAttributeNameForVertexArrayType(_type)];
	GLboolean normalize = GL_FALSE;
	GLenum dataType = GL_FLOAT;
	
	if (_type == C3DVertexArrayNormal) {
		normalize = GL_TRUE;
		dataType = GL_INT;
	}

	glEnableVertexAttribArray(location);
	glVertexAttribPointer(location, C3DSizeForVertexArrayType(_type), dataType, normalize, 0, 0);
}

- (instancetype)initWithType:(C3DVertexArrayType)type elements:(NSData *)elements {
	self = [self init];
	if (self) {
		_type = type;
		_elements = elements;
		_count = [elements countForType:_type];
	}
	return self;
}

- (instancetype)initWithType:(C3DVertexArrayType)type elements:(void *)elements count:(NSUInteger)count {
	self = [self init];
	if (self) {
		_type = type;
		_count = count;
		_elements = [NSData dataWithBytes:elements length:_count * C3DSizeForVertexArrayType(_type) * C3DPrimitiveSizeForVertexArrayType(_type)];
	}
	return self;
}

+ (instancetype)coloursWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayColour elements:elements count:count];
}

+ (instancetype)secondaryColoursWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArraySecondaryColour elements:elements count:count];
}

+ (instancetype)positionsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayPosition elements:elements count:count];
}

+ (instancetype)normalsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayNormal elements:elements count:count];
}

+ (instancetype)texCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayTextureCoord elements:elements count:count];
}

+ (instancetype)fogCoordsWithElements:(GLfloat *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayFogCoord elements:elements count:count];
}

+ (instancetype)indicesWithElements:(GLuint *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayIndex elements:elements count:count];
}

+ (instancetype)edgeFlagsWithElements:(GLuint *)elements count:(NSUInteger)count {
	return [[self alloc] initWithType:C3DVertexArrayEdgeFlag elements:elements count:count];
}

@end

@implementation NSData (C3DVertexArrayData)

- (NSUInteger)countForType:(C3DVertexArrayType)type {
	return [self length] / (C3DSizeForVertexArrayType(type) * C3DPrimitiveSizeForVertexArrayType(type));
}

@end
