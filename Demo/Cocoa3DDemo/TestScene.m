//
//  TestScene.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2018-05-18.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "TestScene.h"

#import "C3DNode+Demo.h"

@implementation TestScene

@synthesize legacy=_legacy;

@synthesize rootNode=_rootNode;

- (instancetype)initWithPresenter:(id<ScenePresenter>)presenter {
    self = [super init];
    if (self) {
        _legacy = NO;
        if (!presenter.usesModernContext) {
            presenter.usesModernContext = YES;
        }
        [[presenter openGLContext] makeCurrentContext];
        _rootNode = [C3DNode testScene];
    }
    return self;
}

- (NSArray<id<C3DVisible>> *)sortedObjectsForCamera:(C3DCamera *)camera { 
    return _rootNode ? @[_rootNode] : @[];
}

@end
