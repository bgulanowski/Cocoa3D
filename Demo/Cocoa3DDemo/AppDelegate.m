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
    id<Scene> _coreScene;
    C3DTransform *_rotation;
}

#pragma mark - NSResponder

- (void)keyDown:(NSEvent *)theEvent {
    [_glCoreView keyDown:theEvent];
    [_window makeFirstResponder:_glCoreView];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _legacyScene = [[LegacyScene alloc] initWithPresenter:_glLegacyView];
    _coreScene = [[ModernScene alloc] initWithPresenter:_glCoreView];
    _coreScene.rootNode.transform = [C3DTransform identity];
    
    LIPoint_t p = LIPointMake(0.5, 0.0, 0.5, 1.0);
    LILine_t l = LILineMake(p, LIVectorUnitY);
    LIMatrix_t m = LIMatrixMakeWithArbitraryRotation(l, M_PI/180.0f);
    _rotation = [[C3DTransform alloc] initWithMatrix:m];
    
    [_glLegacyView.camera configureStyle:CameraStyleA];
    [_glCoreView.camera configureStyle:CameraStyleB];

    _glLegacyView.camera.drawDelegate = self;
    _glCoreView.camera.drawDelegate = self;
    [_glCoreView.camera updateProjectionForViewportSize:_glCoreView.bounds.size];
    
    _glCoreView.usesDisplayLink = YES;
}

#pragma mark - C3DCameraDrawDelegate

BOOL rotateScene = YES;
BOOL rotateObjects = YES;

- (void)paintForCamera:(C3DCamera *)camera {
    if (camera == _glCoreView.camera) {
        if (rotateScene) {
            C3DTransform *xform = [self->_rotation copy];
            [xform concatenate:_coreScene.rootNode.transform];
            _coreScene.rootNode.transform = xform;
        }
        if (rotateObjects) {
            [_coreScene.rootNode visit:^(C3DNode *node) {
                if (node.object != nil && node.transform != nil) {
                    [node.transform concatenate:self->_rotation];
                }
            }];
        }
    }
}

- (id<C3DObjectContainer>)objectContainerForCamera:(C3DCamera *)camera {
    if (camera == _glLegacyView.camera) {
        return _legacyScene;
    }
    else {
        return _coreScene;
    }
}

@end
