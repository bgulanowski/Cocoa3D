//
//  AppDelegate.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "AppDelegate.h"

#import "C3DCamera+Configuring.h"
#import "C3DView+ScenePresenting.h"
#import "LegacyScene.h"
#import "ModernScene.h"

@interface AppDelegate () <C3DCameraDrawDelegate /*, C3DObjectContainer*/>

@end

#pragma mark -

@implementation AppDelegate {
    id<Scene> _legacyScene;
    id<Scene> _modernScene;
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
    
    [_gl2View.camera configureStyle:CameraStyleA];
    [_gl3View.camera configureStyle:CameraStyleB];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _legacyScene = [[LegacyScene alloc] initWithPresenter:_gl2View];
    _modernScene = [[ModernScene alloc] initWithPresenter:_gl3View];

    _gl2View.camera.drawDelegate = self;
    _gl3View.camera.drawDelegate = self;
}

#pragma mark - C3DCameraDrawDelegate

- (void)paintForCamera:(C3DCamera *)camera {}

- (id<C3DObjectContainer>)objectContainerForCamera:(C3DCamera *)camera {
    if (camera == _gl2View.camera) {
        return _legacyScene;
    }
    else {
        return _modernScene;
    }
}

@end
