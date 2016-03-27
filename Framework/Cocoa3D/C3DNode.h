//
//  C3DNode.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-10-24.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Cocoa3D/C3DCamera.h>

@class C3DColour;
@class C3DMotion;
@class C3DObject;
@class C3DTransform;

@interface C3DNode : NSObject<C3DVisible>

@property (nonatomic, weak) C3DNode *parent;
@property (nonatomic, strong) C3DColour *colour;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, strong) C3DMotion *motion;
@property (nonatomic, strong) C3DObject *object;
@property (nonatomic, strong) C3DTransform *transform;

- (void)visit:(void(^)(C3DNode *node))block;

- (void)update:(NSTimeInterval)interval;

@end
