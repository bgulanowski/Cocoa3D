//
//  C3DNode.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-10-24.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DNode.h"

#import "C3DMotion.h"
#import "C3DObject.h"
#import "C3DTransform.h"

@implementation C3DNode

#pragma mark - Accessors

- (void)setObject:(C3DObject *)object
{
    if (self.object) {
        self.object.node = nil;
    }
    object.node = self;
    _object = object;
}

- (void)setChildren:(NSArray *)children
{
    if (self.children.count) {
        for (C3DNode *child in self.children) {
            child.parent = nil;
        }
    }
    for (C3DNode *newChild in children) {
        newChild.parent = self;
    }
    _children = children;
}

#pragma mark - NSObject

- (id)copy
{
    C3DNode *copy = [super copy];
    
    copy.parent = self.parent;
    copy.object = self.object;
    copy.transform = [self.transform copy];
    copy.children = [self.children valueForKey:@"copy"];
    
    return copy;
}

#pragma mark - C3DVisible

- (void)paintForCamera:(C3DCamera *)camera
{
	if (_transform) {
		[camera applyViewTransform:self.transform];
	}
	[_object paintForCamera:camera];
	for (C3DNode *node in _children) {
		[node paintForCamera:camera];
	}
	if (_transform) {
		[camera revertViewTransform];
	}
}

#pragma mark - C3DNode

- (void)visit:(void (^)(C3DNode *))block {
    block(self);
    for (C3DNode *child in _children) {
        [child visit:block];
    }
}

/*
 This won't work as desired in most cases. For example, it would make the moon follow the Earth's axial rotation. This can
 be overcome by not attaching any objects to nodes that have children. Instead, each object should have its own node, and
 then those nodes can be assembled by a common node representing the group. An object's rotation should be set on its own
 node, not the group, which would represent the system.
 However, it does support multiple objects rotating about one another, as long as the node is positioned at the centroid.
 Except for the fact that it doesn't support elliptical orbits, only perfectly circular ones. Nor does it preserve angular
 momentum, so all objects will rotate about the centroid at the same rate, which is completely wrong for orbital mechanics.
 */
- (void)update:(NSTimeInterval)interval {
	for (C3DNode *node in _children) {
		[node update:interval];
	}
	C3DTransform *t = [_motion transformForInterval:interval];
	[t concatenate:_transform];
	_transform = t;
}

@end
