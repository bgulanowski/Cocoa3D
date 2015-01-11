//
//  C3DView.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-27.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class C3DCamera;

@interface C3DView : NSOpenGLView

@property (nonatomic, strong) C3DCamera *camera;
@property (nonatomic) GLfloat movementRate;
@property (nonatomic) BOOL drawInBackground;
@property (nonatomic) BOOL trackMouse;

- (void)useModernContext;

@end
