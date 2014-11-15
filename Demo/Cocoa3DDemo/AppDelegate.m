//
//  AppDelegate.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "AppDelegate.h"

#import "C3DObject+Demo.h"
#import <Cocoa3D/C3DCamera.h>
#import <Cocoa3D/C3DNode.h>
#import <Cocoa3D/C3DProgram.h>
#import <Cocoa3D/C3DTransform.h>
#import <Cocoa3D/C3DView.h>

@interface AppDelegate () <C3DCameraDrawDelegate, C3DPropContainer>

@end

#pragma mark -

@implementation AppDelegate {
	C3DCamera *_camera;
	C3DNode *_rootNode;
	C3DProgram *_program;
}

- (void)testMatrix {
	
//	LIMatrix_t i = LIMatrixIdentity;
	LIMatrix_t i = LIMatrixMakeWithXAxisRotation(M_PI);
	LIPoint_t p = LIPointMake(1, 1, 1, 1);
	LIPoint_t pt = LIMatrixTransformPoint(&p, &i);
	
	NSLog(@"PT: %@", LIPointToString(pt));
}

- (void)setUpGL {
	glClearColor(0, 1, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT);
	glEnable(GL_CULL_FACE);
}

- (void)createObjects {
	
	_rootNode = [C3DNode new];

	C3DObject *object = [C3DObject demoCube];
	_rootNode.object = object;
	
	C3DNode *node = [C3DNode new];
	node.object = object;
	
	C3DTransform *transform = [C3DTransform identity];
	[transform translate:LIVectorMake(2, 2, 2)];
	node.transform = transform;
	
	C3DNode *node1 = [C3DNode new];
	node1.object = object;
	
	transform = [C3DTransform identity];
	[transform translate:LIVectorMake(-2, -2, -2)];
	node1.transform = transform;
				   
	_rootNode.children = @[node, node1];
	
	// FIXME: the attributes should come from somewhere else (metadata about shader?)
	_program = [[C3DProgram alloc] initWithName:@"FlatShader" attributes:[_rootNode.object.vertexArrays valueForKey:@"attributeName"] uniforms:@[@"MVP"]];
	node.object.program = _program;
}

- (void)prepareCamera {
	
	_camera = _openGLView.camera;
	_camera.drawDelegate = self;
	_camera.depthOn = YES;
	
	C3DTransform *modelView = [[C3DTransform alloc] initWithMatrix:LIMatrixIdentity];
	
	[modelView rotate:LIRotationMake(0, 1, 0, M_PI_4)];
	[modelView translate:LIVectorMake(0.0, 0.0, -10.0f)];
	_camera.transform = modelView;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	NSOpenGLContext *glContext = [_openGLView openGLContext];

	[glContext makeCurrentContext];

	[self setUpGL];
	[self createObjects];
	[self prepareCamera];

	_openGLView.camera = _camera;
	
	[_camera capture];
}

#pragma mark - C3DCameraDrawDelegate

- (void)paintForCamera:(C3DCamera *)camera {}

- (id<C3DPropContainer>)propContainer {
	return self;
}

#pragma mark - C3DPropContainer

- (NSArray *)sortedPropsForCamera:(C3DCamera *)camera {
	return @[_rootNode];
}

@end
