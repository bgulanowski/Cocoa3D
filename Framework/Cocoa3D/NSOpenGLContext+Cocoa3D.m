//
//  NSOpenGLContext+Cocoa3D.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "NSOpenGLContext+Cocoa3D.h"

#import "C3DView.h"
#import "NSOpenGLPixelFormat+Cocoa3D.h"

@implementation NSOpenGLContext (Cocoa3D)

- (C3DView *)c3dView {
    C3DView *c3dView = (C3DView *)self.view;
    return [c3dView isKindOfClass:[C3DView class]] ? c3dView : nil;
}

#if ! TARGET_OS_IPHONE
- (CGLOpenGLProfile)C3D_profile {
    
    CGLContextObj cglContext = [self CGLContextObj];
    CGLPixelFormatObj cglPixelFormat = CGLGetPixelFormat(cglContext);
    GLint format = 0;
    CGLError cglError = CGLDescribePixelFormat(cglPixelFormat, 0, kCGLPFAOpenGLProfile, &format);
    
    if (cglError != 0) {
        NSLog(@"Error reading pixel format for NSOpenGLContext");
    }
    
    return (CGLOpenGLProfile)format;
}
#endif

- (BOOL)usesCoreProfile {
#if TARGET_OS_IPHONE
    return YES;
#else
    CGLOpenGLProfile profile = [self C3D_profile];
    return profile == NSOpenGLProfileVersion3_2Core || profile == NSOpenGLProfileVersion4_1Core;
#endif
}

+ (instancetype)C3DModernContext {
	return [[self alloc] initWithFormat:[NSOpenGLPixelFormat C3DModernPixelFormat] shareContext:nil];
}

+ (instancetype)C3DLegacyContext {
    return [[self alloc] initWithFormat:[NSOpenGLPixelFormat C3DLegacyPixelFormat] shareContext:nil];
}

+ (instancetype)C3DContext {
    return [self C3DModernContext];
}

@end
