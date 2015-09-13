//
//  NSOpenGLPixelFormat+Cocoa3D.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "NSOpenGLPixelFormat+Cocoa3D.h"

@implementation NSOpenGLPixelFormat (Cocoa3D)

+ (instancetype)C3DPixelFormatWithProfile:(NSOpenGLPixelFormatAttribute)profile {
	
    NSParameterAssert(profile == NSOpenGLProfileVersion3_2Core || profile == NSOpenGLProfileVersionLegacy);
    
	NSOpenGLPixelFormatAttribute attributes[] = {
		NSOpenGLPFAOpenGLProfile,
		profile,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAColorSize, 32,
		NSOpenGLPFADepthSize, 32,
		0
	};
	return [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
}

+ (instancetype)C3DModernPixelFormat {
    return [self C3DPixelFormatWithProfile:NSOpenGLProfileVersion3_2Core];
}

+ (instancetype)C3DLegacyPixelFormat {
    return [self C3DPixelFormatWithProfile:NSOpenGLProfileVersionLegacy];
}

+ (instancetype)C3DFormat {
    return [self C3DModernPixelFormat];
}

- (GLint)profile {
	GLint profile;
	[self getValues:&profile forAttribute:NSOpenGLPFAOpenGLProfile forVirtualScreen:0];
	return profile;
}

@end
