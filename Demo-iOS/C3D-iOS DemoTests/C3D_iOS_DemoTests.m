//
//  C3D_iOS_DemoTests.m
//  C3D-iOS DemoTests
//
//  Created by Brent Gulanowski on 2014-11-15.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface C3D_iOS_DemoTests : XCTestCase

@end

@implementation C3D_iOS_DemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
