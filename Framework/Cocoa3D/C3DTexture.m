//
//  C3DTexture.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DTexture.h"

#ifdef TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

#if ! TARGET_OS_IPHONE

@interface NSImage (C3DTextureCreation)
- (NSBitmapImageRep *)textureBitmap;
@end

#endif

@implementation C3DTexture {
	GLuint _name;
}

- (void)dealloc {
	glDeleteTextures(1, &_name);
}

- (instancetype)initWithSize:(CGSize)size data:(NSData *)data {
	
	self = [super init];
	if(self) {
				
#if TARGET_OS_IPHONE
        _type = GL_TEXTURE_2D;
        _magFilter = _minFilter = GL_LINEAR_MIPMAP_LINEAR;
		
#else
		BOOL isPowerOfTwo = YES;
		CGFloat i;
		
		for(i=1; isPowerOfTwo && i<size.width; i*=2);
		isPowerOfTwo = i == size.width;
		for(i=1; isPowerOfTwo && i<size.height; i*=2);
		isPowerOfTwo = i == size.height;
		
		if(isPowerOfTwo) {
			_type = GL_TEXTURE_2D;
			_magFilter = _minFilter = GL_LINEAR_MIPMAP_LINEAR;
		}
		else {
			_type = GL_TEXTURE_RECTANGLE_EXT;
			_magFilter = _minFilter = GL_LINEAR;
		}
#endif
		
		glGenTextures(1, &_name);
		glBindTexture(_type, _name);
		glTexImage2D(_type, 0, GL_RGBA, size.width, size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [data bytes]);
		glGenerateMipmap(_type);
		
		_size = size;
		_mode = GL_REPLACE;
	}
	
	return self;
}

#if ! TARGET_OS_IPHONE
- (id)initWithSize:(CGSize)size color:(NSColor *)color {
    
    NSData *data = nil;
    size_t bufferSize = size.width * size.height * sizeof(GLfloat);
    GLubyte *bytes = malloc(bufferSize);
	CGFloat comps[4];
	
	[color getRed:comps green:comps+1 blue:comps+2 alpha:comps+3];
    
	GLubyte colorBytes[4];
	
	for (intptr_t i = 0; i < 4; ++i) {
		colorBytes[i] = (GLubyte)(255.0 * comps[i]);
	}
	
    for (NSUInteger i=0; i<bufferSize; i+=4) {
        bytes[i]   = colorBytes[0];
        bytes[i+1] = colorBytes[1];
        bytes[i+2] = colorBytes[2];
        bytes[i+3] = colorBytes[3];
    }
    
    data = [NSData dataWithBytesNoCopy:bytes length:bufferSize freeWhenDone:YES];
	
    return [self initWithSize:size data:data];
}
#endif

- (void)configureParameters {
	glBindTexture(_type, _name);
    glTexParameteri(_type, GL_TEXTURE_MIN_FILTER, _minFilter);
    glTexParameteri(_type, GL_TEXTURE_MAG_FILTER, _magFilter);
#if ! TARGET_OS_IPHONE
	glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, _mode );
#endif
}

- (void)updateWithData:(NSData *)data region:(CGRect)region {
    glTexSubImage2D(_type, 0, region.origin.x, (GLint)region.origin.y, (GLsizei)region.size.width, (GLsizei)region.size.height,
                    GL_RGBA, GL_UNSIGNED_BYTE, [data bytes]);
}

#if ! TARGET_OS_IPHONE
- (void)updateTexelAtX:(GLuint)x y:(GLuint)y color:(NSColor *)color {
	
}

+ (instancetype)textureWithSize:(CGSize)size data:(NSData *)data {
	return [[self alloc] initWithSize:size data:data];
}

+ (instancetype)textureWithFile:(NSString *)path {
	return [self textureWithImage:[[NSImage alloc] initWithContentsOfFile:path]];
}

+ (instancetype)textureNamed:(NSString *)imageName {
	return [self textureWithImage:[NSImage imageNamed:imageName]];
}

- (void)updateWithSubImage:(NSImage *)image location:(CGRect)location {
    
    NSBitmapImageRep *bitmap = [image textureBitmap];
    NSData *data = [NSData dataWithBytesNoCopy:[bitmap bitmapData] length:[bitmap bytesPerRow] * [bitmap pixelsHigh] freeWhenDone:NO];
    
    [self updateWithData:data region:location];
}

+ (instancetype)textureWithImage:(NSImage *)image {
	return [self textureWithBitmap:[image textureBitmap]];
}

+ (instancetype)textureWithBitmap:(NSBitmapImageRep *)bitmap {
	NSData *data = [NSData dataWithBytesNoCopy:[bitmap bitmapData] length:[bitmap bytesPerRow] * [bitmap pixelsHigh] freeWhenDone:NO];
	CGSize size = CGSizeMake([bitmap pixelsWide], [bitmap pixelsHigh]);
	return [[self alloc] initWithSize:size data:data];
}

#endif

@end

#if ! TARGET_OS_IPHONE
@implementation NSImage (C3DTextureCreation)

- (NSBitmapImageRep *)textureBitmap {
	
	NSBitmapImageRep* bitmap = nil;
    CGSize imgSize = NSSizeToCGSize([self size]);
	
//	[self setFlipped:YES];
    [self lockFocusFlipped:YES];
	bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height)];
	[self unlockFocus];
	
	return bitmap;
}

@end
#endif
