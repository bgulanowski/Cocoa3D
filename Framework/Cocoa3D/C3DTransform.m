//
//  C3DTransform.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-08-02.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DTransform.h"

LIRotation_t LIMatrixGetRotation(LIMatrix_t *m) {

	LIRotation_t r;

	float *e = m->i;
	
	// see http://electroncastle.com/wp/?p=416
	
	float cosa = (e[0] + e[5] + e[10] - 1)/2.0f; // trace(m) = e00 + e11 + e22 = 1 + 2*cosa
	float a = acosf(cosa);
	float sina = sinf(a);
	
	float e01 = e[4]; // = uvccosa - wsina
	float e10 = e[1]; // = uvccosa + wsina
	float uvccosa = (e01 + e10)/2.0f; // e01 + e10 = uvccosa - wsina + uvccosa + wsina = 2 * uvccosa
	float wsina = e10 - uvccosa; // e10 = uvccosa + wsina
	float w = wsina/sina;
	
	float e02 = e[8]; // = uwccosa + vsina
	float e20 = e[2]; // = uwccosa - vsina
	float uwccosa = (e02 + e20)/2.0f; // e02 + e20 = uwccosa + vsina + uwccosa - vsina = 2 * uwccosa
	float vsina = e02 - uwccosa; // e02 = uwccosa + vsina
	float v = vsina/sina;
	
	float e21 = e[6]; // = vwccosa + usina
	float e12 = e[8]; // = vwccosa - usina
	float vwccosa = (e21 + e12)/2.0f; // e21 + e12 = vwccosa + usina + vwccosa - usina = 2 * vwccosa
	float usina = e21 - vwccosa; // e21 = vwccosa + usina
	float u = usina/sina;
	
	r.a = a;
	r.v = LIVectorMake(u, v, w);
	
	return r;
}

void C3DMatrixMakePerspective(LIMatrix_t *m, float fFov, float fAspect, float zMin, float zMax) {
	
	float yMax = zMin * tanf(fFov * 0.5f);
    float yMin = -yMax;
	float xMin = yMin * fAspect;
    float xMax = -xMin;
	float dX = xMax - xMin;
	float dY = yMax - yMin;
	float dZ = zMax - zMin;
    
	m->i[0] = (2.0f * zMin) / dX;
	m->i[1] = 0;
	m->i[2] = 0;
	m->i[3] = 0;
	
	m->i[4] = 0;
	m->i[5] = (2.0f * zMin) / dY;
	m->i[6] = 0;
	m->i[7] = 0;
	
	m->i[8] = (xMax + xMin) / dX;
	m->i[9] = (yMax + yMin) / dY;
	m->i[10] = -((zMax + zMin) / dZ);
	m->i[11] = -1.0f;
	
	m->i[12] = 0;
	m->i[13] = 0;
	m->i[14] = -((2.0f * (zMax*zMin))/dZ);
	m->i[15] = 0.0f;
}

void C3DMatrixMakeOrthographic(LIMatrix_t *m, float xMin, float xMax, float yMin, float yMax, float zMin, float zMax) {
	
	float dX = xMax - xMin;
	float dY = yMax - yMin;
	float dZ = zMax - zMin;

	m->i[0] = 2.0f / dX;
	m->i[1] = 0;
	m->i[2] = 0;
	m->i[3] = 0;
	
	m->i[4] = 0;
	m->i[5] = 2.0f / dY;
	m->i[6] = 0;
	m->i[7] = 0;

	m->i[8] = 0;
	m->i[9] = 0;
	m->i[10] = -2.0f / dZ;
	m->i[11] = 0;

	m->i[12] = -((xMax + xMin)/dX);
	m->i[13] = -((yMax + yMin)/dY);
	m->i[14] = -((zMax + zMin)/dZ);
	m->i[15] = 1.0f;
}


@implementation C3DTransform

- (LIRotation_t)rotation {
	return LIMatrixGetRotation(self.r_matrix);
}

- (void)setRotation:(LIRotation_t)rotation {
	
	LIMatrix_t r = LIMatrixMakeWithVectorRotation(rotation.v, rotation.a);
	LIMatrix_t m = self.matrix;
	
	m.i[0] = r.i[0];
	m.i[1] = r.i[1];
	m.i[2] = r.i[2];
	m.i[4] = r.i[4];
	m.i[5] = r.i[5];
	m.i[6] = r.i[6];
	m.i[8] = r.i[8];
	m.i[9] = r.i[9];
	m.i[11] = r.i[11];
	
	self.matrix = m;
}

- (LIPoint *)location {
	LIMatrix_t *m = self.r_matrix;
	return [LIPoint pointWithPoint:m->v[3]];
}

- (void)setLocation:(LIPoint *)location {
	LIMatrix_t m = self.matrix;
	m.v[3] = location.point;
	self.matrix = m;
}

- (void)translate:(LIVector_t)translation {
	LIMatrix_t m = self.matrix;
	LIVector_t v = translation;
	LIPoint_t t = m.v[3];
	LIPoint_t p = LIPointMake(t.x + v.x, t.y + v.y, t.z+v.z, 1.0f);
	m.v[3] = p;
	self.matrix = m;
}

- (void)rotate:(LIRotation_t)rotation {
	LIMatrix_t r = LIMatrixMakeWithVectorRotation(rotation.v, rotation.a);
	LIMatrix_t m = self.matrix;
	self.matrix = LIMatrixConcatenate(&r, &m);
}

- (void)moveForward:(float)forward {
	[self translate:LIVectorMake(0, 0, -forward)];
}

- (void)moveBack:(float)back {
	[self translate:LIVectorMake(0, 0, back)];
}

- (void)moveRight:(float)right {
	[self translate:LIVectorMake(right, 0, 0)];
}

- (void)moveLeft:(float)left {
	[self translate:LIVectorMake(-left, 0, 0)];
}

- (void)moveUp:(float)up {
	[self translate:LIVectorMake(0, up, 0)];
}

- (void)moveDown:(float)down {
	[self translate:LIVectorMake(0, -down, 0)];
}


- (void)addPitch:(float)pitch {
	[self rotate:LIRotationMake(1.0f, 0, 0, pitch)];
}

- (void)addYaw:(float)yaw {
	[self rotate:LIRotationMake(0, 1.0f, 0, yaw)];
}

- (void)addRoll:(float)roll {
	[self rotate:LIRotationMake(0, 0, 1.0f, roll)];
}

- (void)tiltForward:(float)forward {
	[self rotate:LIRotationMake(1.0f, 0, 0, -forward)];
}

- (void)tiltBack:(float)back {
	[self rotate:LIRotationMake(1.0f, 0, 0, back)];
}

- (void)turnLeft:(float)left {
	[self rotate:LIRotationMake(0, 1.0f, 0, left)];
}

- (void)turnRight:(float)right {
	[self rotate:LIRotationMake(0, 1.0f, 0, -right)];
}


- (void)tiltLeft:(float)left {
	[self rotate:LIRotationMake(0, 0, 1.0f, -left)];
}

- (void)tiltRight:(float)right {
	[self rotate:LIRotationMake(0, 0, 1.0f, right)];
}

+ (instancetype)perspectiveTransformWithFOV:(float)fov width:(float)width height:(float)height near:(float)near far:(float)far {
	C3DTransform *t = [[self alloc] init];
	LIMatrix_t m = t.matrix;
	C3DMatrixMakePerspective(&m, fov, width/height, near, far);
	t.matrix = m;
	return t;
}

+ (instancetype)orthographicTransformWithRegion:(LIRegion *)region {
	C3DTransform *t = [[self alloc] init];
	LIMatrix_t m = t.matrix;
	LIRegion_t r = region.region;
	LIPoint_t *o = &r.origin.p;
	LISize_t *s = &r.volume.s;
	C3DMatrixMakeOrthographic(&m, o->x, o->x + s->w, o->y, o->y + s->h, o->z, o->z + s->d);
	t.matrix = m;
	return t;
}

@end
