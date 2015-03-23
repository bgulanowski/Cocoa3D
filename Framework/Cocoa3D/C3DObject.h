//
//  C3DObject.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Cocoa3D/C3DCamera.h>

@class C3DProgram;

@interface C3DObject : NSObject<C3DVisible>

@property (nonatomic, strong, readonly) NSArray *vertexBuffers;
@property (nonatomic, strong) C3DProgram *program;

- (instancetype)initWithType:(C3DObjectType)type vertexBuffers:(NSArray *)vertexBuffers program:(C3DProgram *)program;

@end
