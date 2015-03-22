//
//  C3DProgram+Demo.m
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2015-03-21.
//  Copyright (c) 2015 Lichen Labs. All rights reserved.
//

#import "C3DProgram+Demo.h"

@implementation C3DProgram (Demo)

+ (instancetype)demoProgram {
    static dispatch_once_t onceToken;
    static C3DProgram *program;
    dispatch_once(&onceToken, ^{
        program = [[C3DProgram alloc] initWithName:@"FlatShader" attributes:C3DAttributeNames() uniforms:@[@"MVP"]];
    });
    return program;
}

@end
