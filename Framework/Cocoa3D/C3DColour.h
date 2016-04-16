//
//  C3DColour.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-12-28.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <OpenGLES/gltypes.h>
#else
#import <OpenGL/gltypes.h>
#endif

typedef struct {
	GLfloat r;
	GLfloat g;
	GLfloat b;
	GLfloat a;
} C3DColour_t;

@interface C3DColour : NSObject

@property (nonatomic) C3DColour_t colour_t;

@end
