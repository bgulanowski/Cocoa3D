//
//  C3DCamera_Private.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-27.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa3D/C3DCamera.h>

typedef struct {
	// Utility options
	unsigned int testOn:1;
	unsigned int rateOn:1;
	unsigned int showOriginOn:1;
	unsigned int showFocusOn:1;
	unsigned int revolveOn:1;
	unsigned int blurOn:1;
	unsigned int reserved:10;
	// OpenGL options
	unsigned int lightsOn:1;
	unsigned int cullOn:1;
	unsigned int depthOn:1;
	C3DPolygonMode frontMode:2;
	C3DPolygonMode backMode:2;
	unsigned int reserved2:9;
} C3DCameraOptions;

#if ! TARGET_OS_IPHONE
extern NSString *C3DStringForPolygonMode(C3DPolygonMode mode);
extern NSString *C3DCameraOptionsToString(C3DCameraOptions options);
#endif

typedef struct {
	unsigned int background:1;
	unsigned int lightLoc:1;
	unsigned int light:1;
	unsigned int shine:1;
	unsigned int reserved:12;
} C3DCameraColorChanges;

@interface C3DCamera ()

@property (nonatomic) C3DCameraColorChanges colorChanges;
@property (nonatomic) C3DCameraOptions options;
@property (nonatomic) C3DCameraOptions changes;
@property (nonatomic, retain) id<C3DPropContainer>container;

@end
