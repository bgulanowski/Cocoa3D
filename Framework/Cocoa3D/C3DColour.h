//
//  C3DColour.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-12-28.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#elif C3D_GL_COMPATIBILITY
#import <OpenGL/gl.h>
#else
#import <OpenGL/gl3.h>
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
