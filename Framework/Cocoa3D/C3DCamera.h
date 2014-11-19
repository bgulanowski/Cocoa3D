//
//  C3DCamera.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <LichenMath/LIPoint_t.h>
#import <LichenMath/LIMatrix_t.h>

#if  TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#endif

#import <CoreGraphics/CoreGraphics.h>

@class C3DTransform, C3DCamera, LIPoint, LIVector, LIMatrix;

typedef struct {
	float r;
	float g;
	float b;
	float a;
} C3DColor_t;

typedef NS_ENUM(NSUInteger, C3DObjectType) {
	C3DObjectTypePoints,
	C3DObjectTypeLines,
	C3DObjectTypeLineLoop,
	C3DObjectTypeLineStrip,
	C3DObjectTypeTriangles,
	C3DObjectTypeTriangleStrip,
	C3DObjectTypeTriangleFan,
};

typedef NS_ENUM(NSUInteger, C3DPolygonMode) {
    C3DPolygonModeFill = 0,
    C3DPolygonModeLine = 1,
    C3DPolygonModePoint = 2
};

typedef NS_ENUM(NSUInteger, C3DCameraProjectionStyle) {
	C3DCameraProjectionPerspective,
	C3DCameraProjectionOrthographic
};


@protocol C3DPropContainer<NSObject>
- (NSArray *)sortedPropsForCamera:(C3DCamera *)camera;
@end

@protocol C3DVisible<NSObject>
- (void)paintForCamera:(C3DCamera *)camera;
@end

@protocol C3DCameraDrawDelegate<NSObject>
- (void)paintForCamera:(C3DCamera *)camera;
- (id<C3DPropContainer>)propContainer;
@end

@class C3DTransform;
@protocol GLKNamedEffect;

@interface C3DCamera : NSObject

@property (nonatomic, strong) id<GLKNamedEffect> effect;

@property (nonatomic, assign) id<C3DCameraDrawDelegate> drawDelegate;

@property (nonatomic, copy) C3DTransform *transform;
@property (nonatomic, copy) C3DTransform *projection;

@property (nonatomic) C3DPolygonMode frontMode;
@property (nonatomic) C3DPolygonMode backMode;

@property (nonatomic) C3DCameraProjectionStyle projectionStyle;

@property (nonatomic, copy) LIPoint *position;
@property (nonatomic, copy) LIPoint *lightPosition;
@property (nonatomic, copy) LIPoint *focusPosition;
@property (nonatomic, copy) LIVector *velocity;

@property (nonatomic) C3DColor_t backgroundColor;
@property (nonatomic) C3DColor_t lightColor;
@property (nonatomic) C3DColor_t lightShine;

@property (nonatomic, getter = isTestOn) BOOL testOn;
@property (nonatomic, getter = isRateOn) BOOL rateOn;
@property (nonatomic, getter = isShowOriginOn) BOOL showOriginOn;
@property (nonatomic, getter = isShowFocusOn) BOOL showFocusOn;
@property (nonatomic, getter = isRevolveOn) BOOL revolveOn;
@property (nonatomic, getter = areLightsOn) BOOL lightsOn;
@property (nonatomic, getter = isCullingOn) BOOL cullingOn;
@property (nonatomic, getter = isDepthOn) BOOL depthOn;
@property (nonatomic, getter = isBlurOn) BOOL blurOn;

@property (nonatomic, getter = isFrontLineModeOn) BOOL frontLineModeOn;
@property (nonatomic, getter = isBackLineModeOn) BOOL backLineModeOn;

@property (nonatomic) GLfloat nearPlane;
@property (nonatomic) GLfloat farPlane;
@property (nonatomic) GLfloat fieldOfView;

@property (nonatomic) GLfloat frameRate;

@property (nonatomic) GLfloat lightX;
@property (nonatomic) GLfloat lightY;
@property (nonatomic) GLfloat lightZ;

@property (readonly, getter = isMoving) BOOL moving;

// move relative to the current position in absolute coordinates
- (void)translateX:(GLfloat)dx y:(GLfloat)dy z:(GLfloat)dz;

// rotate relative to the current rotation in absolute values
-(void)rotateX:(GLfloat)x y:(GLfloat)y;

// These can only be called during -paintWithCamera:
- (C3DTransform *)applyViewTransform:(LIMatrix *)transform;
- (void)revertViewTransform;
- (C3DTransform *)currentTransform;

- (void)updatePosition:(NSTimeInterval)interval;
- (void)updateProjectionForViewportSize:(CGSize)size;

#if TARGET_OS_IPHONE
+ (Class)classForEAGLContext:(id)context;
+ (C3DCamera *)cameraForEAGLContext:(id)context;
#else
+ (Class)classForGLContext:(NSOpenGLContext *)context;
+ (C3DCamera *)cameraForGLContext:(NSOpenGLContext *)context;
#endif

- (void)capture;

- (void)logCameraState;
- (void)logFramerate:(NSTimeInterval)start;

// all the following methods must be implemented by subclasses
- (void)setup;
- (void)updateGLState;

- (void)drawElementsWithType:(C3DObjectType)type count:(NSInteger)count;
- (void)drawArraysWithType:(C3DObjectType)type count:(NSInteger)count;

// This is only useful for GL1 and GL2 cameras
// TODO: move to NSOpenGLContext?
- (void)logGLState;

@end
