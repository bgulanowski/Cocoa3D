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
    C3DTransform *_rotation;
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
    _legacyScene = [[LegacyScene alloc] initWithPresenter:_gl2View];
    _modernScene = [[ModernScene alloc] initWithPresenter:_gl3View];
    
    LIPoint_t p = LIPointMake(0.5, 0.0, 0.5, 1.0);
    LILine_t l = LILineMake(p, LIVectorUnitY);
    LIMatrix_t m = LIMatrixMakeWithArbitraryRotation(l, M_PI/180.0f);
    _rotation = [[C3DTransform alloc] initWithMatrix:m];
    
    [_gl2View.camera configureStyle:CameraStyleA];
    [_gl3View.camera configureStyle:CameraStyleB];

    _gl2View.camera.drawDelegate = self;
    _gl3View.camera.drawDelegate = self;
    
    _gl3View.usesDisplayLink = YES;
}

#pragma mark - C3DCameraDrawDelegate

- (void)paintForCamera:(C3DCamera *)camera {
    if (camera == _gl3View.camera) {
        [[_modernScene rootNode] visit:^(C3DNode *node) {
            if (node.object != nil && node.transform != nil) {
//                C3DTransform *xform = [rot copy];
//                [xform concatenate:node.transform];
//                [xform concatenate:rot];
//                node.transform = xform;
//                [node.transform rotate:LIRotationMake(0, 1, 0, M_PI / 100.0f)];
                [node.transform concatenate:_rotation];
            }
        }];
    }
}

- (id<C3DObjectContainer>)objectContainerForCamera:(C3DCamera *)camera {
    if (camera == _gl2View.camera) {
        return _legacyScene;
    }
    else {
        return _modernScene;
    }
}

@end
