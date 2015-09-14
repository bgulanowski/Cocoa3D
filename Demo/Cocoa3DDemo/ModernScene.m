//
//  ModernScene.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2015-09-13.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "ModernScene.h"

#import "C3DNode+Demo.h"

@implementation ModernScene {
    C3DNode *_rootNode;
}

#pragma mark - Scene

- (instancetype)initWithPresenter:(id<ScenePresenter>)presenter {
    self = [super init];
    if (self) {
        if (!presenter.usesModernContext) {
            presenter.usesModernContext = YES;
        }
        [[presenter openGLContext] makeCurrentContext];
         _rootNode = [C3DNode demoScene];
    }
    return self;
}

- (BOOL)isLegacy { return NO; }

#pragma mark - C3DObjectContainer

- (NSArray *)sortedObjectsForCamera:(C3DCamera *)camera {
    return _rootNode ? @[_rootNode] : @[];
}

@end
