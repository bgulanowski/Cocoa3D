//
//  C3DObject+Demo.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DObject+Demo.h"

#import <Cocoa3D/C3DProgram.h>
#import <Cocoa3D/C3DVertexArray.h>

#import <LichenMath/LichenMath.h>

#import <OpenGL/gl.h>

#define p000 {-1.0f,-1.0f,-1.0f}
#define p00h {-1.0f,-1.0f,0.0f}
#define p001 {-1.0f,-1.0f,1.0f}
#define p0h0 {-1.0f,0.0f,-1.0f}
#define p0hh {-1.0f,0.0f,0.0f}
#define p0h1 {-1.0f,0.0f,1.0f}
#define p010 {-1.0f,1.0f,-1.0f}
#define p01h {-1.0f,1.0f,0.0f}
#define p011 {-1.0f,1.0f,1.0f}

#define ph00 {0.0f,-1.0f,-1.0f}
#define ph0h {0.0f,-1.0f,0.0f}
#define ph01 {0.0f,-1.0f,1.0f}
#define phh0 {0.0f,0.0f,-1.0f}
#define phhh {0.0f,0.0f,0.0f}
#define phh1 {0.0f,0.0f,1.0f}
#define ph10 {0.0f,1.0f,-1.0f}
#define ph1h {0.0f,1.0f,0.0f}
#define ph11 {0.0f,1.0f,1.0f}

#define p100 {1.0f,-1.0f,-1.0f}
#define p10h {1.0f,-1.0f,0.0f}
#define p101 {1.0f,-1.0f,1.0f}
#define p1h0 {1.0f,0.0f,-1.0f}
#define p1hh {1.0f,0.0f,0.0f}
#define p1h1 {1.0f,0.0f,1.0f}
#define p110 {1.0f,1.0f,-1.0f}
#define p11h {1.0f,1.0f,0.0f}
#define p111 {1.0f,1.0f,1.0f}

static GLfloat trianglePoints[3][3] = {
	{ -1, -1, 0 },
	{  1, -1, 0 },
	{  0,  1, 0 }
};
static GLuint triangleIndices[] = { 0, 1, 2 };

#pragma mark -

@interface C3DObjectGL1 : C3DObject

@end

@implementation C3DObject (Demo)

+ (instancetype)demoTriangle {
	
	GLfloat colours[3][4] = {
		{ 1, 0, 1, 1},
		{ 0, 1, 1, 1},
		{ 1, 1, 0, 1}
	};
	
	C3DVertexArray *positionArray = [[C3DVertexArray alloc] initWithType:C3DVertexArrayPosition elements:trianglePoints count:3];
	C3DVertexArray *colourArray = [[C3DVertexArray alloc] initWithType:C3DVertexArrayColour elements:colours count:3];
	NSArray *vertexArrays = @[positionArray, colourArray];
	C3DProgram *program = [[C3DProgram alloc] initWithName:@"FlatShader" attributes:[vertexArrays valueForKey:@"attributeName"] uniforms:@[@"MVP"]];
	
	return [[[self class] alloc] initWithType:C3DObjectTypeTriangles vertexArrays:vertexArrays program:program];
}

+ (instancetype)demoTriangleIndexed {
	
	C3DVertexArray *positionArray = [C3DVertexArray positionsWithElements:trianglePoints[0] count:3];
	C3DVertexArray *indexArray = [C3DVertexArray indicesWithElements:&triangleIndices[0] count:3];
	NSArray *vertexArrays = @[positionArray, indexArray];
	C3DProgram *program = [[C3DProgram alloc] initWithName:@"FlatShader" attributes:[vertexArrays valueForKey:@"attributeName"] uniforms:@[@"MVP"]];
	
	return [[[self class] alloc] initWithType:C3DObjectTypeTriangles vertexArrays:vertexArrays program:program];
}

+ (instancetype)demoCube {
	
	LIVector_t points[] = { p000, p001, p010, p011, p100, p101, p110, p111 };
	// quads
	LIPoint_t colours[] = { { 0,0,0,1 }, { 0,0,1,1 }, { 0,1,0,1 }, { 0,1,1,1 }, { 1,0,0,1 }, { 1,0,1,1 }, { 1,1,0,1 }, { 1,1,1,1 } };
	GLuint indices[] = { 0,1,3, 3,2,0,  0,2,6, 6,4,0,  0,4,5, 5,1,0,  1,5,7, 7,3,1,  2,3,7, 7,6,2,  4,6,7, 7,5,4 };

	C3DVertexArray *positionArray = [C3DVertexArray positionsWithElements:&points[0].x count:8];
	C3DVertexArray *coloursArray = [C3DVertexArray coloursWithElements:&colours[0].x count:8];
	C3DVertexArray *indexArray = [C3DVertexArray indicesWithElements:&indices[0] count:36];
	NSArray *vertexArrays = @[positionArray, indexArray, coloursArray];
	
	return [[[self class] alloc] initWithType:C3DObjectTypeTriangles vertexArrays:vertexArrays program:nil];
}

+ (instancetype)demoTriangleGL1 {
	return [C3DObjectGL1 demoTriangle];
}

@end

@implementation C3DObjectGL1

- (void)paintForCamera:(C3DCamera *)camera {
	
	glColor3f(1, 1, 1);
	
	glBegin(GL_TRIANGLES);
	
	for (int i=0; i<3; ++i) {
		glVertex3f(trianglePoints[i][0], trianglePoints[i][1], trianglePoints[i][2]);
	}
	
	glEnd();
}

- (instancetype)initWithType:(C3DObjectType)type vertexArrays:(NSArray *)vertexArrays program:(C3DProgram *)program {
	return [super initWithType:type vertexArrays:vertexArrays program:nil];
}

@end