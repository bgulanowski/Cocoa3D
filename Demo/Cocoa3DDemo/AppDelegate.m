//
//  AppDelegate.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "AppDelegate.h"

#import "C3DObject+Demo.h"
#import "C3DNode+Demo.h"

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

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];
	if (self) {
		_rootNode = [C3DNode demoScene];
	}
	return self;
}

#pragma mark - NSResponder

- (void)keyDown:(NSEvent *)theEvent {
	[_openGLView keyDown:theEvent];
	[_window makeFirstResponder:_openGLView];
}

#pragma mark - NSNibAwaking

- (void)awakeFromNib {
	[self.window makeFirstResponder:_openGLView];
	[self.window setNextResponder:self];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	NSOpenGLContext *glContext = [_openGLView openGLContext];

	[glContext makeCurrentContext];
	
	// FIXME: the attributes should come from somewhere else (metadata about shader?)
	_program = [[C3DProgram alloc] initWithName:@"FlatShader" attributes:[_rootNode.object.vertexArrays valueForKey:@"attributeName"] uniforms:@[@"MVP"]];
	_rootNode.object.program = _program;

	[self setUpGL];
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

#pragma mark - Private

- (void)setUpGL {
	glClearColor(0, 1, 0, 1);
	glClear(GL_COLOR_BUFFER_BIT);
	glEnable(GL_CULL_FACE);
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

@end
