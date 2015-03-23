//
//  C3DCameraGL1.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-27.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa3D/C3DCamera.h>
#import <Cocoa3D/C3DVertexBuffer.h>

extern GLenum C3DArrayNameForType (C3DVertexArrayType type);

@interface C3DCameraGL1 : C3DCamera

+ (void)enableVertexArray:(C3DVertexBuffer *)vertexArray;
+ (void)disableVertexArray:(C3DVertexBuffer *)vertexArray;
+ (void)loadVertexArray:(C3DVertexBuffer *)vertexArray;

+ (void)enableVertexArrays:(NSArray *)vertexArrays;
+ (void)disableVertexArrays:(NSArray *)vertexArrays;
+ (void)loadVertexArrays:(NSArray *)vertexArrays;

@end
