//
//  C3DCameraGL1.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-27.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DCameraGL1.h"
#import "C3DCamera_Private.h"

#import "C3DTransform.h"

#import <LichenMath/LichenMath.h>

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

GLenum C3DArrayNameForType (C3DVertexBufferType type) {
    switch (type) {
        case C3DVertexBufferColour:
        case C3DVertexBufferSecondaryColour:
            return GL_COLOR_ARRAY;
        case C3DVertexBufferPosition:
            return GL_VERTEX_ARRAY;
        case C3DVertexBufferNormal:
            return GL_NORMAL_ARRAY;
        case C3DVertexBufferTextureCoord:
            return GL_TEXTURE_COORD_ARRAY;
        case C3DVertexBufferIndex:
            return GL_INDEX_ARRAY;
        case C3DVertexBufferEdgeFlag:
            return GL_EDGE_FLAG_ARRAY;
            
        case C3DVertexBufferFogCoord:
        default:
            return 0;
    }
}

extern const GLenum objectTypes[];

static void C3DDrawOrigin( void ) {
	
	GLboolean enableLighting = NO;
	
	glGetBooleanv(GL_LIGHTING, &enableLighting);
	glDisable(GL_LIGHTING);
	
	glBegin(GL_LINES);
	glColor3f(0, 0, 1);
	glVertex3i(0, 0, 0);
	glVertex3i(1, 0, 0);
	glColor3f(0, 1, 0);
	glVertex3i(0, 0, 0);
	glVertex3i(0, 1, 0);
	glColor3f(1, 0, 0);
	glVertex3i(0, 0, 0);
	glVertex3i(0, 0, 1);
	glEnd();
	
	if(enableLighting)
		glEnable(GL_LIGHTING);
}

@implementation C3DCameraGL1

- (void)setup {
    
	glDepthFunc(GL_LESS);
	glBlendFunc(GL_SRC_ALPHA,  GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glShadeModel(GL_SMOOTH);
	glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, 1.0);
	glEnable(GL_COLOR_MATERIAL);
    glClearDepth(1.0);
	glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
	
	GLfloat diffuse[4]  = { 0.5f, 0.5f, 0.5f, 1.0f};
    
	glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse);
	glEnable(GL_LIGHT0);
    
	glEnable(GL_NORMALIZE);
}

- (C3DTransform *)applyViewTransform:(C3DTransform *)transform {
	[super applyViewTransform:transform];
	glPushMatrix();
	glMultMatrixf( transform.matrix.i );
	return transform;
}

- (void)revertViewTransform {
	glPopMatrix();
	[super revertViewTransform];
}

- (void)synch {
	
	C3DCameraOptions changes = self.changes;
	C3DCameraOptions options = self.options;
	C3DCameraColorChanges colorChanges = self.colorChanges;
	
    if(changes.lightsOn) options.lightsOn ? glEnable(GL_LIGHTING) : glDisable(GL_LIGHTING);
	
    if(colorChanges.lightLoc) {
		LIPoint_t p = self.lightPosition.point;
		glLightfv(GL_LIGHT0, GL_POSITION, (float *)&p);
	}
    if(colorChanges.light) {
		C3DColour_t lightColor = self.lightColor;
		glLightfv(GL_LIGHT0, GL_AMBIENT, &lightColor.r);
	}
    if(colorChanges.shine) {
		C3DColour_t lightShine = self.lightShine;
		glLightfv(GL_LIGHT0, GL_SPECULAR, &lightShine.r);
	}
	
	[super synch];
}

- (void)updateProjectionForViewportSize:(CGSize)size {
	[super updateProjectionForViewportSize:size];
	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(self.projection.matrix.i);
}

- (void)paint {
	
	C3DCameraOptions options = self.options;

	glMatrixMode(GL_MODELVIEW);
	glRenderMode(GL_RENDER);
	
	glLoadIdentity();
	glPushMatrix();
	
	LIMatrix_t m;
	
	if(options.revolveOn)
		m = LIMatrixFocus(self.position.point, self.focusPosition.point);
	else
		m = self.transform.matrix;
	
	glLoadMatrixf(m.i);
	
	[super paint];

#if ! TARGET_OS_IPHONE
//	if(options.testOn) {
//		static GLUquadric *quad = NULL;
//		if(NULL == quad) quad = gluNewQuadric();
//		gluSphere(quad, 4, 32, 32);
//	}
	if(options.showOriginOn)
		C3DDrawOrigin();
	if(options.showFocusOn) {
		LIPoint_t focus = self.focusPosition.point;
		glBegin(GL_POINTS);
		glColor3i(1, 1, 1);
		glVertex3fv(&focus.x);
		glEnd();
	}
#endif

	glPopMatrix();
}

- (void)capture {
	
	NSTimeInterval start =  self.rateOn ? [NSDate timeIntervalSinceReferenceDate] : 0;
	
	[super capture];
	
	if(self.rateOn)
		[self logFramerate:start];
}

- (void)logGLState {
    
#define STRING(bool) ((bool)?@"ON":@"OFF")
    
    GLboolean lightingOn;
    GLboolean cullingOn;
    GLboolean depthOn;
    GLint polygonModes[2];
    
    CGLContextObj cglContext = CGLGetCurrentContext();
    
    CGLLockContext(cglContext);
    
    glGetBooleanv(GL_LIGHTING, &lightingOn);
    glGetBooleanv(GL_CULL_FACE, &cullingOn);
    glGetBooleanv(GL_DEPTH_TEST, &depthOn);
    glGetIntegerv(GL_POLYGON_MODE, polygonModes);
    
    CGLUnlockContext(cglContext);
    
    NSLog(@"Lighting:   %@", STRING(lightingOn));
    NSLog(@"Cull face:  %@", STRING(cullingOn));
    NSLog(@"Depth test: %@", STRING(depthOn));
    NSLog(@"Front mode: %@", C3DStringForPolygonMode(polygonModes[0]));
    NSLog(@"Back mode:  %@", C3DStringForPolygonMode(polygonModes[1]));
	
	LIMatrix_t matrix;
	glGetFloatv(GL_MODELVIEW_MATRIX, matrix.i);
	NSLog(@"Model View Matrix:\n%@", LIMatrixToString(matrix));
	
	glGetFloatv(GL_PROJECTION_MATRIX, matrix.i);
	NSLog(@"Projection Matrix:\n%@", LIMatrixToString(matrix));
}

+ (void)enableVertexBuffer:(C3DVertexBuffer *)vertexBuffer {
    glEnableClientState(C3DArrayNameForType(vertexBuffer.type));
}

+ (void)disableVertexBuffer:(C3DVertexBuffer *)vertexBuffer {
    glDisableClientState(C3DArrayNameForType(vertexBuffer.type));
}

+ (void)enableVertexBuffers:(NSArray *)vertexBuffers {
    for (C3DVertexBuffer *vertexBuffer in vertexBuffers) {
        if (vertexBuffer.type != C3DVertexBufferIndex) {
            [self enableVertexBuffer:vertexBuffer];
        }
    }
}

+ (void)disableVertexBuffers:(NSArray *)vertexBuffers {
    for (C3DVertexBuffer *vertexBuffer in vertexBuffers) {
        if (vertexBuffer.type != C3DVertexBufferIndex) {
            [self disableVertexBuffer:vertexBuffer];
        }
    }
}

+ (void)loadVertexBuffer:(C3DVertexBuffer *)vertexBuffer {
    [vertexBuffer bind];
    switch (vertexBuffer.type) {
        case C3DVertexBufferColour:
            glColorPointer(4, GL_FLOAT, 0, NULL);
            break;
        case C3DVertexBufferPosition:
            glVertexPointer(3, GL_FLOAT, 0, NULL);
            break;
        case C3DVertexBufferNormal:
            glNormalPointer(3, GL_FLOAT, NULL);
            break;
        case C3DVertexBufferTextureCoord:
            glTexCoordPointer(3, GL_FLOAT, 0, NULL);
            break;
        case C3DVertexBufferIndex:
        case C3DVertexBufferEdgeFlag:
        case C3DVertexBufferSecondaryColour:
        case C3DVertexBufferFogCoord:
        default:
            break;
    }
}

+ (void)loadVertexBuffers:(NSArray *)vertexBuffers {
    for (C3DVertexBuffer *vertexBuffer in vertexBuffers) {
        [self loadVertexBuffer:vertexBuffer];
    }
}

@end
