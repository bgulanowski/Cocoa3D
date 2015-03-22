//
//  C3DNode+Demo.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-11-18.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DNode+Demo.h"

#import "C3DProgram+Demo.h"
#import "C3DObject+Demo.h"

@implementation C3DNode (Demo)

+ (instancetype)demoScene {
	
	C3DNode *rootNode = [C3DNode new];
	
	C3DObject *object = [C3DObject demoCubeWithProgram:[C3DProgram demoProgram]];
	rootNode.object = object;
	
	C3DNode *node = [C3DNode new];
	node.object = object;
	
	C3DTransform *transform = [C3DTransform identity];
	[transform translate:LIVectorMake(2, 2, 2)];
	node.transform = transform;
	
	C3DNode *node1 = [C3DNode new];
	node1.object = object;
	
	transform = [C3DTransform identity];
	[transform translate:LIVectorMake(-2, -2, -2)];
	node1.transform = transform;
	
	rootNode.children = @[node, node1];
	
	return rootNode;
}

@end
