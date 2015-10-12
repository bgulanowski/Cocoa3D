//
//  LegacyScene.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2015-09-13.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "LegacyScene.h"
#import "C3DObject+Demo.h"

@implementation LegacyScene {
    C3DObject *_gl1Object;
}

#pragma mark - Scene

- (instancetype)initWithPresenter:(id<ScenePresenter>)presenter {
    self = [super init];
    if (self) {
        [[presenter openGLContext] makeCurrentContext];
        _gl1Object = [C3DObject demoCubeWithProgram:nil];
        // TODO: This is weak - should happen automatically
        [C3DCameraGL1 loadVertexBuffers:_gl1Object.vertexBuffers];
    }
    return self;
}

- (BOOL)isLegacy {
    return YES;
}

- (C3DNode *)rootNode {
    return nil;
}

#pragma mark - C3DObjectContainer

- (NSArray *)sortedObjectsForCamera:(C3DCamera *)camera {
    return @[_gl1Object];
}

@end
