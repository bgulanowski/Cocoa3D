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

- (BOOL)usesCoreProfile {
    GLint profile = self.c3dView.pixelFormat.profile;
    return profile == NSOpenGLProfileVersion3_2Core || profile == NSOpenGLProfileVersion4_1Core;
}

+ (instancetype)C3DContext {
	return [[self alloc] initWithFormat:[NSOpenGLPixelFormat C3DFormat] shareContext:nil];
}

@end
