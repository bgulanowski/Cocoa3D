//
//  Cocoa3DTests.m
//  Cocoa3DTests
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "C3DCamera.h"
#import "C3DTransform.h"

@interface Cocoa3DTests : XCTestCase

@end

@implementation Cocoa3DTests

- (void)testExample {
    
    C3DCamera *camera = [[C3DCamera alloc] init];
    [camera translateX:10.0f y:0.0f z:-10.0f];
    
    // Rotate 45° to the left (not down)
    [camera rotateX:-45.0f y:0];
    LILine_t l = [camera lineOfView];
    LIPoint_t p = LILineInterceptX0(l);
    XCTAssert(LIPointIsOrigin(p));
    
    p = LILineInterceptY0(l);
    XCTAssert(LIPointIsZero(p));
    
    p = LILineInterceptZ0(l);
    XCTAssert(LIPointIsOrigin(p));
}

- (void)testProjectionMatrix {
    
    LIMatrix_t m;
    C3DMatrixMakePerspective(&m, M_PI_2, 1, 1, 3);
    
    LIPoint_t testPoints[] = {
        LIPointMake( 0,  0, -1,  1), // centre, near plane
        LIPointMake(-1, -1, -1,  1), // bottom-left, near plane
        LIPointMake( 1,  1, -1,  1), // top-right, near plane
        LIPointMake( 0,  0, -2,  1), // centre of frustum
        LIPointMake(-3,  3, -3,  1), // top-left, far plane
        LIPointMake( 3, -3, -3,  1), // bottom-right, far plane
        LIPointMake( 0,  0,  0,  1), // origin (eye)
        LIPointMake( 0,  0, -4,  1), // centre, beyond far plane
        LIPointZero // terminator
    };
    
    LIPoint_t *p = testPoints;
    do {
        LIPoint_t a = LIMatrixTransformPoint(p, &m);
        LIPoint_t n = LIPointNormalize(a);
        NSLog(@"\n%@ ->\n%@ (%@)", LIPointToString(*p), LIPointToString(a), LIPointToString(n));
        ++p;
    } while (!LIPointIsZero(*p));

    XCTAssertTrue(YES);
}

@end
