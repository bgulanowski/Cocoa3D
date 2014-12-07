//
//  C3DObject+Demo.h
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa3D/C3DObject.h>

@interface C3DObject (Demo)

+ (instancetype)demoTriangle;
+ (instancetype)demoTriangleIndexed;
// a 2x2x2 cube centered about the origin
+ (instancetype)demoCube;

@end
