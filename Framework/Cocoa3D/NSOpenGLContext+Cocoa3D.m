//
//  NSOpenGLContext+Cocoa3D.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "NSOpenGLContext+Cocoa3D.h"

#import "NSOpenGLPixelFormat+Cocoa3D.h"

@implementation NSOpenGLContext (Cocoa3D)

+ (instancetype)C3DContext {
	return [[self alloc] initWithFormat:[NSOpenGLPixelFormat C3DFormat] shareContext:nil];
}

@end
