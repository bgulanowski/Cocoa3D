//
//  NSOpenGLPixelFormat+Cocoa3D.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "NSOpenGLPixelFormat+Cocoa3D.h"

@implementation NSOpenGLPixelFormat (Cocoa3D)

+ (instancetype)C3DFormat {
	
	NSOpenGLPixelFormatAttribute attributes[] = {
		NSOpenGLPFAOpenGLProfile,
		NSOpenGLProfileVersion3_2Core,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAColorSize, 32,
		NSOpenGLPFADepthSize, 32,
		0
	};
	return [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
}

- (GLint)profile {
	GLint profile;
	[self getValues:&profile forAttribute:NSOpenGLPFAOpenGLProfile forVirtualScreen:0];
	return profile;
}

@end
