//
//  C3DCamera+Configuring.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2015-09-13.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import "C3DCamera+Configuring.h"
#import <objc/message.h>

@implementation C3DCamera (Configuring)

- (void)configureOptions {
    self.cullingOn = NO;
    self.depthOn = YES;
    self.lightsOn = NO;
}

- (void)configureStyleA {
    self.backgroundColor = (C3DColour_t){0, 0.5f, 0, 1};
    self.projectionStyle = C3DCameraProjectionOrthographic;
    // 1 unit in GL equals 32 points on-screen
    self.scale = 1.0/32.0;
}

- (void)configureStyleB {
    self.backgroundColor = (C3DColour_t){0.5f, 0, 0, 1};
    self.showOriginOn = YES;
}

- (SEL)configurationSelectorForStyle:(CameraStyle)style {
    SEL selectors[] = { @selector(configureStyleA), @selector(configureStyleB) };
    return selectors[style];
}

- (void)configureStyle:(CameraStyle)style {
    self.transform = [C3DTransform newDemoTransform];
    [self configureOptions];
    objc_msgSend(self, [self configurationSelectorForStyle:style]);
}

@end

@implementation C3DTransform (DemoCameraConfiguring)

+ (instancetype)newDemoTransform {
    C3DTransform *transform = [self identity];
    [transform rotate:LIRotationMake(0.5, 1, 0, M_PI_4)];
    [transform translate:LIVectorMake(0.0, 0.0, -10.0f)];
    return transform;
}

@end
