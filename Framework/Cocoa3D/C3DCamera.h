//
//  C3DCamera.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <OpenGLES/gltypes.h>
#else
#import <OpenGL/gltypes.h>
#endif

#import <LichenMath/LIPoint_t.h>
#import <LichenMath/LIMatrix_t.h>

#import <Cocoa3D/C3DColour.h>

@class NSOpenGLContext, C3DTransform, C3DCamera, LIPoint, LIVector, LIMatrix;

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


@protocol C3DVisible<NSObject>
- (void)paintForCamera:(C3DCamera *)camera;
@end

@protocol C3DObjectContainer<NSObject>
- (NSArray<id<C3DVisible>> *)sortedObjectsForCamera:(C3DCamera *)camera;
@end

@protocol C3DCameraDrawDelegate<NSObject>
- (void)paintForCamera:(C3DCamera *)camera;
- (id<C3DObjectContainer>)objectContainerForCamera:(C3DCamera *)camera;
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

@property (nonatomic) C3DColour_t backgroundColor;
@property (nonatomic) C3DColour_t lightColor;
@property (nonatomic) C3DColour_t lightShine;

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
@property (nonatomic) GLfloat scale;

@property (nonatomic) GLfloat frameRate;

@property (nonatomic) GLfloat lightX;
@property (nonatomic) GLfloat lightY;
@property (nonatomic) GLfloat lightZ;

@property (readonly, getter = isMoving) BOOL moving;

// move relative to the current position in absolute coordinates
- (void)translateX:(GLfloat)dx y:(GLfloat)dy z:(GLfloat)dz;

- (void)rotateBy:(GLfloat)degrees about:(LIVector *)axis;

// rotate relative to the current rotation in absolute values
-(void)rotateX:(GLfloat)x y:(GLfloat)y;

// These can only be called during -paintWithCamera:
- (C3DTransform *)applyViewTransform:(LIMatrix *)transform;
- (void)revertViewTransform;
- (C3DTransform *)currentTransform;
- (C3DTransform *)currentRelativeTransform;
//- (C3DTransform *)inverseTransform;
- (C3DTransform *)rotation;

- (LIVector *)viewDirection;
- (LILine_t)lineOfView;

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

- (void)drawElementsWithType:(C3DObjectType)type count:(NSInteger)count;
- (void)drawArraysWithType:(C3DObjectType)type count:(NSInteger)count;

// This is only useful for GL1 and GL2 cameras
// TODO: move to NSOpenGLContext?
- (void)logGLState;

@end
