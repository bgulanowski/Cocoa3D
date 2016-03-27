//
//  Cocoa3DTests.m
//  Cocoa3DTests
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "C3DCamera.h"

@interface Cocoa3DTests : XCTestCase

@end

@implementation Cocoa3DTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    C3DCamera *camera = [[C3DCamera alloc] init];
    
    [camera translateX:10.0f y:0.0f z:-10.0f];
    [camera rotateX:-45.0f y:0];
    LILine_t l = [camera lineOfView];
    
    XCTAssert(LILineIsZero(l));
}

@end
