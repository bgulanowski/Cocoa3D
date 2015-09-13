//
//  Cocoa3D.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Cocoa3D/C3DCamera.h>
#if TARGET_OS_IPHONE
#import <Cocoa3D/C3DCameraEAGL3.h>
#else
#import <Cocoa3D/C3DCameraGL1.h>
#import <Cocoa3D/C3DCameraGL3.h>
#endif

#import <Cocoa3D/C3DColour.h>
#import <Cocoa3D/C3DLight.h>
#import <Cocoa3D/C3DMotion.h>
#import <Cocoa3D/C3DNode.h>
#import <Cocoa3D/C3DObject.h>
#import <Cocoa3D/C3DObject+C3DPolyhedra.h>
#import <Cocoa3D/C3DProgram.h>
#import <Cocoa3D/C3DShader.h>
#import <Cocoa3D/C3DTexture.h>
#import <Cocoa3D/C3DTransform.h>
#import <Cocoa3D/C3DVertex.h>
#import <Cocoa3D/C3DVertexBuffer.h>
#import <Cocoa3D/C3DView.h>

#import <Cocoa3D/NSOpenGLContext+Cocoa3D.h>
#import <Cocoa3D/NSOpenGLPixelFormat+Cocoa3D.h>

@interface Cocoa3D : NSObject

@end
