//
//  C3DTexture.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface C3DTexture : NSObject

@property (readonly) CGSize size;
@property (assign) GLenum minFilter;
@property (assign) GLenum magFilter;
@property (assign) GLenum target;

- (instancetype)initWithSize:(CGSize)size format:(GLenum)format type:(GLenum)type data:(NSData *)data;

- (void)configureParameters;

- (void)updateWithData:(NSData *)data region:(CGRect)region;

#if ! TARGET_OS_IPHONE
- (void)updateTexelAtX:(GLuint)x y:(GLuint)y color:(NSColor *)color;

+ (instancetype)textureWithSize:(CGSize)size format:(GLenum)format type:(GLenum)type data:(NSData *)data;
+ (instancetype)textureWithSize:(CGSize)size data:(NSData *)data;
+ (instancetype)textureWithFile:(NSString *)path;
+ (instancetype)textureNamed:(NSString *)imageName;

- (void)updateWithSubImage:(NSImage *)image location:(CGRect)location;

+ (instancetype)textureWithImage:(NSImage *)image;
+ (instancetype)textureWithBitmap:(NSBitmapImageRep *)bitmap;
#endif

@end
