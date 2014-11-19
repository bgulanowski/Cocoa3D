//
//  AppDelegate.m
//  C3D-iOS Demo
//
//  Created by Brent Gulanowski on 2014-11-15.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "AppDelegate.h"

#import "C3DObject+Demo.h"

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

- (instancetype)init {
	self = [super init];
	if (self) {
		[self createModel];
	}
	return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	GLKView *glkView = (GLKView *)_window.rootViewController.view;
	[EAGLContext setCurrentContext:glkView.context];
	
	glkView.delegate = self;
	
	[self setUpGL];
	[self setUpCameraForView:glkView];
	
	_program = [[C3DProgram alloc] initWithName:@"FlatShader" attributes:[_rootNode.object.vertexArrays valueForKey:@"attributeName"] uniforms:@[@"MVP"]];
	_rootNode.object.program = _program;
	
	[glkView display];
	
	return YES;
}

- (void)createModel {

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
}

- (void)setUpCameraForView:(GLKView *)glkView {
	
	C3DTransform *modelView = [[C3DTransform alloc] initWithMatrix:LIMatrixIdentity];
	[modelView rotate:LIRotationMake(0, 1, 0, M_PI_4)];
	[modelView translate:LIVectorMake(0.0, 0.0, -20.0f)];
	
	_camera = [C3DCamera cameraForEAGLContext:glkView.context];
	_camera.drawDelegate = self;
	_camera.transform = modelView;
	[_camera updateProjectionForViewportSize:glkView.bounds.size];
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
