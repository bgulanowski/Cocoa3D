//
//  C3DCameraEAGL3.m
//  Cocoa3D-iOS
//
//  Created by Brent Gulanowski on 2014-11-16.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DCameraEAGL3.h"
#import "C3DCamera_Private.h"

#import <OpenGLES/ES3/gl.h>

@implementation C3DCameraEAGL3

- (void)drawElementsWithType:(C3DObjectType)type count:(NSInteger)count {
	glDrawElements(primitiveTypes[type], (GLsizei)count, GL_UNSIGNED_INT, NULL);
}

- (void)drawArraysWithType:(C3DObjectType)type count:(NSInteger)count {
	glDrawArrays(primitiveTypes[type], 0, (GLsizei)count);
}

@end
