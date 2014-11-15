//
//  C3DMotion.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-10-25.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LIVector;
@class C3DTransform;

@interface C3DMotion : NSObject

@property (nonatomic, strong) LIVector *velocity;
@property (nonatomic, strong) LIVector *acceleration;
@property (nonatomic, strong) LIVector *rotationalAxis;
@property (nonatomic) CGFloat angularVelocity;

- (C3DTransform *)transformForInterval:(NSTimeInterval)interval;

@end
