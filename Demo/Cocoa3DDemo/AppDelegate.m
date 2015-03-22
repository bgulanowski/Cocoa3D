//
//  AppDelegate.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "AppDelegate.h"

#import "C3DObject+Demo.h"
#import "C3DProgram+Demo.h"
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
	C3DObject *_gl1Object;
}

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];
	if (self) {
        _gl1Object = [C3DObject demoCubeWithProgram:nil];
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
	[self prepareCamera:_gl2View.camera useOrthographic:YES];
	[_gl3View useModernContext];
	[self prepareCamera:_gl3View.camera useOrthographic:NO];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	NSOpenGLContext *glContext = [_gl3View openGLContext];
	
	[glContext makeCurrentContext];
	
    // The shader created requres a working current gl3 context
    _rootNode = [C3DNode demoScene];

    [_gl2View.openGLContext makeCurrentContext];
    [C3DCameraGL1 loadVertexArrays:_gl1Object.vertexArrays];
}

#pragma mark - C3DCameraDrawDelegate

- (void)paintForCamera:(C3DCamera *)camera {}

- (id<C3DPropContainer>)propContainer {
	return self;
}

#pragma mark - C3DPropContainer

- (NSArray *)sortedPropsForCamera:(C3DCamera *)camera {
	if (camera == _gl3View.camera) {
		return @[_rootNode];
	}
	else {
		return @[_gl1Object];
	}
}

#pragma mark - Private

- (void)prepareCamera:(C3DCamera *)camera useOrthographic:(BOOL)useOrtho {
	
	camera.cullingOn = YES;
	camera.drawDelegate = self;
	camera.depthOn = YES;
	camera.lightsOn = NO;

	C3DTransform *modelView = [[C3DTransform alloc] initWithMatrix:LIMatrixIdentity];

	if (useOrtho) {
		camera.backgroundColor = (C3DColour_t){0, 1, 0, 1};
		camera.projectionStyle = C3DCameraProjectionOrthographic;
		// 1 unit in GL equals 32 points on-screen
		camera.scale = 1.0/32.0;
	}
	else {
		camera.backgroundColor = (C3DColour_t){1, 0, 0, 1};
	}
    [modelView rotate:LIRotationMake(0.5, 1, 0, M_PI_4)];
    [modelView translate:LIVectorMake(0.0, 0.0, -10.0f)];
	camera.transform = modelView;
}

@end
