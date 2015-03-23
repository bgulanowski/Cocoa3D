//
//  C3DObject+Demo.h
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-09-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa3D/C3DObject.h>

@interface C3DObject (Demo)

+ (instancetype)demoTriangleWithProgram:(C3DProgram *)program;
+ (instancetype)demoTriangleIndexedWithProgram:(C3DProgram *)program;
// a 2x2x2 cube centered about the origin
+ (instancetype)demoCubeWithProgram:(C3DProgram *)program;

@end
