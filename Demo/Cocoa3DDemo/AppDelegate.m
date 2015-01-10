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
	[_gl3View keyDown:theEvent];
	[_window makeFirstResponder:_gl3View];
}

#pragma mark - NSNibAwaking

- (void)awakeFromNib {
	[self.window makeFirstResponder:_gl3View];
	[self.window setNextResponder:self];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	NSOpenGLContext *glContext = [_gl3View openGLContext];

	[glContext makeCurrentContext];
	
	// FIXME: the attributes should come from somewhere else (metadata about shader?)
	_program = [[C3DProgram alloc] initWithName:@"FlatShader" attributes:[_rootNode.object.vertexArrays valueForKey:@"attributeName"] uniforms:@[@"MVP"]];
	_rootNode.object.program = _program;

	[self prepareCameraUseOrthographic:YES];
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

- (void)prepareCameraUseOrthographic:(BOOL)useOrtho {
	
	C3DCamera *camera = _gl3View.camera;
	camera.backgroundColor = (C3DColour_t){0, 1, 0, 1};
	camera.cullingOn = YES;
	camera.drawDelegate = self;
	camera.depthOn = YES;

	C3DTransform *modelView = [[C3DTransform alloc] initWithMatrix:LIMatrixIdentity];

	if (useOrtho) {
		camera.projectionStyle = C3DCameraProjectionOrthographic;
		// 1 unit in GL equals 32 points on-screen
		camera.scale = 1.0/32.0;
		
		[camera updateProjectionForViewportSize:_gl3View.bounds.size];
		[modelView translate:LIVectorMake(0, 0, -5.0f)];
	}
	else {
		[modelView rotate:LIRotationMake(0, 1, 0, M_PI_4)];
		[modelView translate:LIVectorMake(0.0, 0.0, -10.0f)];
	}
	camera.transform = modelView;
}

@end
