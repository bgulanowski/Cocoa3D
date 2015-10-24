//
//  C3DCameraGL1.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-27.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa3D/C3DCamera.h>
#import <Cocoa3D/C3DVertexBuffer.h>

@interface C3DCameraGL1 : C3DCamera

+ (void)enableVertexBuffer:(C3DVertexBuffer *)vertexBuffer;
+ (void)disableVertexBuffer:(C3DVertexBuffer *)vertexBuffer;
+ (void)loadVertexBuffer:(C3DVertexBuffer *)vertexBuffer;

+ (void)enableVertexBuffers:(NSArray *)vertexBuffers;
+ (void)disableVertexBuffers:(NSArray *)vertexBuffers;
+ (void)loadVertexBuffers:(NSArray *)vertexBuffers;

+ (void)enableIndexBuffer;
+ (void)disableIndexBuffer;
+ (void)loadIndexBuffer:(C3DIndexBuffer *)indexBuffer;

@end
