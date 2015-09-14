//
//  C3DCamera.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DCamera.h"

#import "C3DCamera_Private.h"

#if TARGET_OS_IPHONE
#import "C3DCameraEAGL3.h"
#else
#import "C3DCameraGL1.h"
#import "C3DCameraGL3.h"
#endif

#import "C3DTransform.h"
#import "NSOpenGLContext+Cocoa3D.h"

#import <LichenMath/LichenMath.h>

#import <GLKit/GLKit.h>

#define LOG_UNIMPLEMENTED() NSLog(@"Unimplemented method %@", NSStringFromSelector(_cmd))

const GLenum primitiveTypes[] = {
	GL_POINTS,
	GL_LINES,
	GL_LINE_LOOP,
	GL_LINE_STRIP,
	GL_TRIANGLES,
	GL_TRIANGLE_STRIP,
	GL_TRIANGLE_FAN,
};

#if ! TARGET_OS_IPHONE
NSString *C3DStringForPolygonMode(C3DPolygonMode mode) {
    switch (mode) {
        case C3DPolygonModePoint: return @"Point"; break;
        case C3DPolygonModeLine:  return @"Line";  break;
        case C3DPolygonModeFill:
        default:			      return @"Fill";  break;
    }
}

static inline GLenum C3DPolygonModeToGL(C3DPolygonMode mode) {
	
	switch (mode) {
		case C3DPolygonModePoint: return GL_POINT; break;
		case C3DPolygonModeLine:  return GL_LINE;  break;
		case C3DPolygonModeFill:
		default:                 return GL_FILL;  break;
	}
}
#endif

NSString *C3DCameraOptionsToString(C3DCameraOptions _options) {
    NSMutableArray *optionNames = [NSMutableArray array];
    if(_options.testOn) [optionNames addObject:@"TEST"];
    if(_options.rateOn) [optionNames addObject:@"RATE"];
    if(_options.showOriginOn) [optionNames addObject:@"SHOW_ORIGIN"];
    if(_options.showFocusOn) [optionNames addObject:@"SHOW_FOCUS"];
    if(_options.revolveOn) [optionNames addObject:@"REVOLVE"];
    if(_options.blurOn) [optionNames addObject:@"BLUR"];
    if(_options.lightsOn) [optionNames addObject:@"LIGHTS"];
    if(_options.cullOn) [optionNames addObject:@"CULL"];
    if(_options.depthOn) [optionNames addObject:@"DEPTH"];
	
#if ! TARGET_OS_IPHONE
    [optionNames addObject:[NSString stringWithFormat:@"FRONT FACE:%@", C3DStringForPolygonMode(_options.frontMode)]];
    [optionNames addObject:[NSString stringWithFormat:@"BACK FACE:%@", C3DStringForPolygonMode(_options.backMode)]];
#endif
	
    return [optionNames componentsJoinedByString:@", "];
}

@interface C3DCameraGL2 : C3DCamera
@end

@interface C3DCameraGL4 : C3DCamera
@end


#pragma mark -

@implementation C3DCamera {
	NSMutableArray *_transformStack;
	NSTimeInterval *_renderTimes;
	NSUInteger _timeIndex;
	GLfloat _xRot;
	GLfloat _yRot;
	BOOL _logTime;
}

//+ (NSSet *)keyPathsForValuesAffectingNsbgColor {
//	return [NSSet setWithObject:@"bgColor"];
//}

#pragma mark - Accessors

- (void)setPosition:(LIPoint *)position {
	_transform.location = position;
}

- (LIPoint *)position {
	return _transform.location;
}

- (BOOL)areLightsOn {
    return _options.lightsOn;
}

- (BOOL)isLightsOn {
    return _options.lightsOn;
}

- (void)setLightsOn:(BOOL)flag {
    _options.lightsOn = flag;
    _changes.lightsOn = YES;
}

- (BOOL)isCullingOn {
    return _options.cullOn;
}

- (void)setCullingOn:(BOOL)flag {
    _options.cullOn = flag;
    _changes.cullOn = YES;
}

- (BOOL)isDepthOn {
    return _options.depthOn;
}

- (void)setDepthOn:(BOOL)flag {
    _options.depthOn = flag;
    _changes.depthOn = YES;
}

- (BOOL)isShowOriginOn {
    return _options.showOriginOn;
}

- (void)setShowOriginOn:(BOOL)flag {
    _options.showOriginOn = flag;
    _changes.showOriginOn = YES;
}

- (BOOL)isTestOn {
    return _options.testOn;
}

- (void)setTestOn:(BOOL)testOn {
    _options.testOn = testOn;
    _changes.testOn = YES;
}

- (BOOL)isRateOn {
    return _options.rateOn;
}

- (void)setRateOn:(BOOL)rateOn {
    _options.rateOn = rateOn;
    _changes.rateOn = YES;
    @synchronized(self) {
        if(_options.rateOn && !_renderTimes)
            _renderTimes = malloc(sizeof(NSTimeInterval)*30);
        else if(!_options.rateOn && _renderTimes)
            free(_renderTimes), _renderTimes = NULL;
    }
}

- (BOOL)isRevolveOn {
    return _options.revolveOn;
}

- (void)setRevolveOn:(BOOL)flag {
    _options.revolveOn = flag;
    _changes.revolveOn = YES;
}

- (BOOL)isShowFocusOn {
    return _options.showFocusOn;
}

- (void)setShowFocusOn:(BOOL)showFocusOn {
    _options.showFocusOn = showFocusOn;
    _changes.showFocusOn = YES;
}

- (BOOL)isBlurOn {
    return _options.blurOn;
}

- (void)setBlurOn:(BOOL)flag {
    _options.blurOn = flag;
    _changes.blurOn = YES;
}

- (C3DPolygonMode)frontMode {
    return _options.frontMode;
}

- (void)setFrontMode:(C3DPolygonMode)frontMode {
    _options.frontMode = frontMode;
    _changes.frontMode = 1;
}

- (C3DPolygonMode)backMode {
    return _options.backMode;
}

- (void)setBackMode:(C3DPolygonMode)backMode {
    _options.backMode = backMode;
    _changes.backMode = 1;
}

- (BOOL)isFrontLineModeOn {
    return _options.frontMode == C3DPolygonModeLine;
}

- (void)setFrontLineModeOn:(BOOL)flag {
    _options.frontMode = flag ? C3DPolygonModeLine : C3DPolygonModeFill;
    _changes.frontMode = 1;
}

- (BOOL)isBackLineModeOn {
    return _options.backMode == C3DPolygonModeLine;
}

- (void)setBackLineModeOn:(BOOL)flag {
    _options.backMode = flag ? C3DPolygonModeLine : C3DPolygonModeFill;
    _changes.backMode = 1;
}

- (void)setLightPosition:(LIPoint *)lightPosition {
	_lightPosition = lightPosition;
	_colorChanges.lightLoc = YES;
}

- (void)setBackgroundColor:(C3DColour_t)aColor {
    _backgroundColor = aColor;
    _colorChanges.background = YES;
}

- (void)setLightColor:(C3DColour_t)aColor {
    _lightColor = aColor;
    _colorChanges.light = YES;
}

- (void)setLightShine:(C3DColour_t)aColor {
    _lightShine = aColor;
    _colorChanges.shine = YES;
}

- (BOOL)isMoving {
	LIVector_t vector = _velocity.vector;
	return (vector.x != 0 || vector.y != 0 || vector.z != 0);
}

- (void)setTransform:(C3DTransform *)transform {
	_transform = [transform copy] ?: [C3DTransform identity];
}

//- (void)setVelocity:(LIVector *)velocity {
//	// FIXME: if velocity has a value, we need to update periodically
//}

- (void)setDrawDelegate:(id<C3DCameraDrawDelegate>)drawDelegate {
	_drawDelegate = drawDelegate;
	_container = [_drawDelegate objectContainerForCamera:self];
}

#pragma mark - NSObject

- (id)init {
	self = [super init];
	if([self isMemberOfClass:[C3DCamera class]]) {
		static NSString *selectorName;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			SEL selector;
#if TARGET_OS_IPHONE
			selector = @selector(cameraForEAGLContext:);
#else
			selector = @selector(cameraForGLContext:);
#endif
			selectorName = NSStringFromSelector(selector);
		});
		NSLog(@"C3DCamera is an abstract class. Create cameras with %@", selectorName);
	}
	if(self) {
        _transform = [C3DTransform identity];
        _projection = [C3DTransform identity];
		_focusPosition = [LIPoint pointWithX:0 y:0 z:0 w:0];
		_backgroundColor = (C3DColour_t){.r = 0.0f, .g = 0.0f, .b = 0.0f, .a = 1.0f};
		_lightColor = (C3DColour_t){.r = 0.5f, .g = 0.5f, .b = 0.5f, .a = 1.0f};
		_lightShine = (C3DColour_t){.r = 0.8f, .g = 0.8f, .b = 0.8f, .a = 1.0f};
		
		_fieldOfView = M_PI_4;
		_nearPlane = 0.1f;
		_farPlane = 100.0f;
		_scale = 1.0f;
		
		self.lightPosition = [LIPoint pointWithX:0 y:0 z:0 w:1.0f];
		self.frontMode = self.backMode = C3DPolygonModeFill;
		
		self.lightsOn = YES;
        self.cullingOn = YES;
        self.depthOn = YES;
		
		[self setup];
	}
	return self;
}

#pragma mark - C3DCamera

- (void)translateWithVector:(LIVector_t)vector {
	LIPoint *l = _transform.location;
	LIPoint_t p = l.point;
	l.point = LIPointTranslate(p, vector);
	self.position = l;
}

- (void)translateX:(GLfloat)dx y:(GLfloat)dy z:(GLfloat)dz {
	[self translateWithVector:LIVectorMake(dx, dy, dz)];
}

- (void)rotateBy:(GLfloat)degrees about:(LIVector *)axis {
	LIVector_t v = axis.vector;
	[_transform rotate:LIRotationMake(v.x, v.y, v.z, degrees * M_PI/180.0f)];
}

-(void)rotateX:(GLfloat)xDeg y:(GLfloat)yDeg {

	// X rotation goes about Y axis, and vice versa
    // unwide the pitch before applying yaw, to prevent unintentional roll (avoid left/right tilt)
    // not 100% sure why this (applying the new pitch amount first) works
    // I get a bit confused by the significance of the concatenation order
    LIMatrix_t m = LIMatrixMakeWithXAxisRotation((_yRot+yDeg) * M_PI/180.0f);
    LIMatrix_t t = LIMatrixMakeWithYAxisRotation(xDeg * M_PI/180.0f);
    m = LIMatrixConcatenate(&m, &t);
    t = LIMatrixMakeWithXAxisRotation(-_yRot * M_PI/180.0f);
    m = LIMatrixConcatenate(&m, &t);
	m = LIMatrixConcatenate(&m, _transform.r_matrix);
	_transform = [C3DTransform matrixWithMatrix:m];
	
	_xRot += xDeg;
	_yRot += yDeg;
}

- (C3DTransform *)applyViewTransform:(C3DTransform *)transform {
	NSParameterAssert(transform != nil);
	transform = [transform copy];
	if ([_transformStack count]) {
		[transform concatenate:[_transformStack lastObject]];
	}
	[_transformStack addObject:transform];
	return transform;
}

- (void)revertViewTransform {
	NSAssert([_transformStack count] > 0, @"Attempt to revert transform when none present");
	[_transformStack removeLastObject];
}

- (C3DTransform *)currentTransform {
	// TODO: cache this
	C3DTransform *transform = [_projection copy];
	[transform concatenate:_transform];
	if ([_transformStack count]) {
		[transform concatenate:[_transformStack lastObject]];
	}
	return transform;
}

- (void)updatePosition:(NSTimeInterval)interval {
	LIVector_t v = _velocity.vector;
	[self translateWithVector:LIVectorMake(v.x*interval, v.y*interval, v.z*interval)];
}

- (void)updateProjectionForViewportSize:(CGSize)size {
	switch (_projectionStyle) {
		case C3DCameraProjectionPerspective:
			self.projection = [C3DTransform perspectiveTransformWithFOV:_fieldOfView width:size.width height:size.height near:_nearPlane far:_farPlane];
			break;
		case C3DCameraProjectionOrthographic:
			self.projection = [C3DTransform orthographicTransformWithRegion:[LIRegion regionWithRegion:LIRegionMake(-size.width/2.0f*_scale, -size.height/2.0f*_scale, _nearPlane, size.width*_scale, size.height*_scale, _farPlane)]];
			break;
	}
	glViewport( 0, 0, size.width, size.height );
}

- (void)setup {
}

- (void)drawElementsWithType:(C3DObjectType)type count:(NSInteger)count {
    glDrawElements(primitiveTypes[type], (GLsizei)count, GL_UNSIGNED_INT, NULL);
}

- (void)drawArraysWithType:(C3DObjectType)type count:(NSInteger)count {
    glDrawArrays(primitiveTypes[type], 0, (GLsizei)count);
}

- (void)synch {
	
	if(_changes.cullOn)   _options.cullOn   ? glEnable(GL_CULL_FACE)  : glDisable(GL_CULL_FACE);
	if(_changes.depthOn)  _options.depthOn  ? glEnable(GL_DEPTH_TEST) : glDisable(GL_DEPTH_TEST);
	
#if ! TARGET_OS_IPHONE
    // OpenGL 3+ requires changing both frant and back together, but GL2 supports different values
    BOOL restoreBackMode = NO;
    if(_changes.frontMode) {
        glPolygonMode(GL_FRONT_AND_BACK, C3DPolygonModeToGL(self.frontMode));
        restoreBackMode = _options.frontMode != _options.backMode;
    }
    if (_changes.backMode || restoreBackMode) {
        glPolygonMode(GL_BACK, C3DPolygonModeToGL(self.backMode));
    }
#endif
	
	if(_colorChanges.background) {
		C3DColour_t backgroundColor = self.backgroundColor;
		glClearColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a);
	}

	_changes = (C3DCameraOptions){};
	_colorChanges = (C3DCameraColorChanges) {};
}

- (void)clear {
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
}

- (NSArray *)sortedObjects {
	return [_container sortedObjectsForCamera:self];
}

- (void)paint {
	_transformStack = [NSMutableArray array];
	[[self sortedObjects] makeObjectsPerformSelector:@selector(paintForCamera:) withObject:self];
	[_drawDelegate paintForCamera:self];
	_transformStack = nil;
}

- (void)flush {
#if ! TARGET_OS_IPHONE
	CGLFlushDrawable(CGLGetCurrentContext());
#endif
}

- (void)capture {
	[self synch];
	[self clear];
	[self paint];
	[self flush];
}

- (void)logCameraState {
    NSLog(@"Settings: %@", C3DCameraOptionsToString(self.options));
    NSLog(@"Out of date: %@", C3DCameraOptionsToString(self.changes));
}

- (void)logGLState {
	LOG_UNIMPLEMENTED();
}

- (void)logFramerate:(NSTimeInterval)start {
	
	_renderTimes[_timeIndex] = [NSDate timeIntervalSinceReferenceDate] - start;
	if(_logTime) {
		NSLog(@"Frame took %.5f", _renderTimes[_timeIndex]);
		_logTime = NO;
	}
	if(++_timeIndex > 30) {
		_timeIndex = 0;
		
		NSTimeInterval total = 0;
		for(NSUInteger index = 0; index<30; ++index)
			total += _renderTimes[index];
		
		self.frameRate = 30.0f/total;
		
		NSLog(@"Last thirty renders took %f seconds total", total);
	}
}

#if TARGET_OS_IPHONE
+ (Class)classForEAGLContext:(EAGLContext *)context {
	Class C3DCameraClass = self;
	switch ([context API]) {
		case kEAGLRenderingAPIOpenGLES1:
		case kEAGLRenderingAPIOpenGLES2:
			// TODO: backwards compatibility
		case kEAGLRenderingAPIOpenGLES3:
		default:
			C3DCameraClass = [C3DCameraEAGL3 class]; break;
	}
	return C3DCameraClass;
}

+ (C3DCamera *)cameraForEAGLContext:(id)context {
	return [[[self classForEAGLContext:context] alloc] init];
}

#else
+ (Class)classForGLContext:(NSOpenGLContext *)context {
	
	Class C3DCameraClass = self;
	switch ([context C3D_profile]) {
		case kCGLOGLPVersion_Legacy:
			C3DCameraClass = [C3DCameraGL1 class]; break;
		case kCGLOGLPVersion_GL3_Core:
		case kCGLOGLPVersion_GL4_Core:
			C3DCameraClass = [C3DCameraGL3 class]; break;
		default:
			C3DCameraClass = [C3DCameraGL1 class]; break;
	}
	return C3DCameraClass;
}

+ (C3DCamera *)cameraForGLContext:(NSOpenGLContext *)context {
	C3DCamera *camera = [[[self classForGLContext:context] alloc] init];
	[context makeCurrentContext];
	return camera;
}
#endif

@end

@implementation C3DCameraGL2
@end

@implementation C3DCameraGL4
@end
