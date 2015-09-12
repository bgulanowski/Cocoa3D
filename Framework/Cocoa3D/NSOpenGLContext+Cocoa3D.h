//
//  NSOpenGLContext+Cocoa3D.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class C3DView;

@interface NSOpenGLContext (Cocoa3D)

@property (nonatomic, readonly) C3DView *c3dView;
@property (nonatomic, readonly) BOOL usesCoreProfile;

#if ! TARGET_OS_IPHONE
- (CGLOpenGLProfile)C3D_profile;
#endif

+ (instancetype)C3DContext;

@end
