//
//  C3DCameraGL3.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-08-23.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DCameraGL3.h"
#import "C3DCamera_Private.h"

#import "C3DObject.h"

#import <OpenGL/gl3.h>

extern const GLenum primitiveTypes[];

@implementation C3DCameraGL3

- (void)drawElementsWithType:(C3DObjectType)type count:(NSInteger)count {
	glDrawElements(primitiveTypes[type], (GLsizei)count, GL_UNSIGNED_INT, NULL);
}

- (void)drawArraysWithType:(C3DObjectType)type count:(NSInteger)count {
	glDrawArrays(primitiveTypes[type], 0, (GLsizei)count);
}

@end
