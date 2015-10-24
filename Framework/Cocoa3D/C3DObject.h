//
//  C3DObject.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Cocoa3D/C3DCamera.h>

@class C3DIndexBuffer, C3DNode, C3DProgram, C3DVertexBuffer;

@interface C3DObject : NSObject<C3DVisible>

@property (nonatomic, weak) C3DNode *node;
@property (nonatomic, strong) C3DProgram *program;
@property (nonatomic, strong) C3DIndexBuffer *indexElements;
@property (nonatomic, strong) NSArray *vertexBuffers;
@property (nonatomic) BOOL ignoresTransform;

- (instancetype)initWithType:(C3DObjectType)type;

@end
