//
//  C3DTransform.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-08-02.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <LichenMath/LichenMath.h>

typedef struct {
	LIVector_t v;
	float a;
} LIRotation_t;

NS_INLINE LIRotation_t LIRotationMake(float x, float y, float z, float a) {
	LIRotation_t r;
	r.v = LIVectorMake(x, y, z);
	r.a = a;
	return r;
}

@interface C3DTransform : LIMatrix

// position
@property (nonatomic, strong) LIPoint *location;
@property (nonatomic, strong) LIPoint *focus;

@property (nonatomic, strong) LIVector *up;
@property (nonatomic, strong) LIVector *forward;

@property (nonatomic) LIRotation_t rotation;

@property (nonatomic) float focusDistance;

- (void)translate:(LIVector_t)translation;
- (void)rotate:(LIRotation_t)rotation;

// relative motion in local co-ordinate space
- (void)moveForward:(float)forward;
- (void)moveBack:(float)back;
- (void)moveRight:(float)right;
- (void)moveLeft:(float)left;
- (void)moveUp:(float)up;
- (void)moveDown:(float)down;

- (void)addYaw:(float)yaw;
- (void)addPitch:(float)pitch;
- (void)addRoll:(float)roll;

- (void)turnLeft:(float)left;
- (void)turnRight:(float)right;

- (void)tiltLeft:(float)left;
- (void)tiltRight:(float)right;
- (void)tiltForward:(float)forward;
- (void)tiltBack:(float)back;

+ (instancetype)perspectiveTransformWithFOV:(float)fov width:(float)width height:(float)height near:(float)near far:(float)far;
+ (instancetype)orthographicTransformWithRegion:(LIRegion *)region;

@end
