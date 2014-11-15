//
//  NSOpenGLPixelFormat+Cocoa3D.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSOpenGLPixelFormat (Cocoa3D)

@property (nonatomic, readonly) GLint profile;

+ (instancetype)C3DFormat;

@end
