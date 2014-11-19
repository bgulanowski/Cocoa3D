//
//  AppDelegate.m
//  C3D-iOS Demo
//
//  Created by Brent Gulanowski on 2014-11-15.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "AppDelegate.h"

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/EAGLDrawable.h>

@import UIKit;
@import OpenGLES;
@import GLKit;

#import <Cocoa3D/Cocoa3D.h>

@interface AppDelegate () <C3DCameraDrawDelegate, C3DPropContainer, GLKViewDelegate>
@end

@implementation AppDelegate {
	C3DCamera *_camera;
	C3DNode *_rootNode;
	C3DProgram *_program;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	GLKView *glkView = (GLKView *)_window.rootViewController.view;
	EAGLContext *context = glkView.context;
	[EAGLContext setCurrentContext:context];
	
	glkView.delegate = self;
	
	[self setUpGL];
	
	_camera = [C3DCamera cameraForEAGLContext:context];
	_camera.drawDelegate = self;
	
	C3DTransform *modelView = [[C3DTransform alloc] initWithMatrix:LIMatrixIdentity];
	
	[modelView rotate:LIRotationMake(0, 1, 0, M_PI_4)];
	[modelView translate:LIVectorMake(0.0, 0.0, -10.0f)];
	_camera.transform = modelView;
	
	_rootNode = [C3DNode new];
	_rootNode.object = [self demoTriangle];
	
	[_camera updateProjectionForViewportSize:glkView.bounds.size];
	
	[glkView display];
	
	return YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	[_camera capture];
	glFlush();
}

- (void)setUpGL {
	glClearColor(0, 1, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT);
	glEnable(GL_CULL_FACE);
}

- (C3DObject *)demoTriangle {
	
	GLfloat points[3][3] = {
		{ -1, -1, 0 },
		{  1, -1, 0 },
		{  0,  1, 0 }
	};
	
	GLfloat colours[3][4] = {
		{ 1, 0, 1, 1},
		{ 0, 1, 1, 1},
		{ 1, 1, 0, 1}
	};
	
	C3DVertexArray *positionArray = [[C3DVertexArray alloc] initWithType:C3DVertexArrayPosition elements:points count:3];
	C3DVertexArray *colourArray = [[C3DVertexArray alloc] initWithType:C3DVertexArrayColour elements:colours count:3];
	NSArray *vertexArrays = @[positionArray, colourArray];
	_program = [[C3DProgram alloc] initWithName:@"FlatShader" attributes:[vertexArrays valueForKey:@"attributeName"] uniforms:@[@"MVP"]];
	
	return [[C3DObject alloc] initWithType:C3DObjectTypeTriangles vertexArrays:vertexArrays program:_program];
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
