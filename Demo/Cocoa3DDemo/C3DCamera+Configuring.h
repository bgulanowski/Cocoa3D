//
//  C3DCamera+Configuring.h
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2015-09-13.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import <Cocoa3D/Cocoa3D.h>

typedef NS_ENUM(NSUInteger, CameraStyle) {
    CameraStyleA,
    CameraStyleB
};

@interface C3DCamera (Configuring)
- (void)configureStyle:(CameraStyle)style;
@end

@interface C3DTransform (DemoCameraConfiguring)
+ (C3DTransform *)newDemoTransform;
@end
