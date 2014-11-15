//
//  C3DShader.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, C3DShaderType) {
	C3DShaderTypeVertex,
	C3DShaderTypeFragment,
	C3DShaderTypeGeometry,
	C3DShaderTypeCount
};

@interface C3DShader : NSObject

- (instancetype)initWithString:(NSString *)source type:(C3DShaderType)type;
- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithName:(NSString *)name;

- (GLuint)shaderName;
- (void)compile;

+ (instancetype)vertexShaderWithName:(NSString *)name;
+ (instancetype)fragmentShaderWithName:(NSString *)name;
+ (C3DShaderType)typeForFileExtension:(NSString *)extension;
+ (C3DShaderType)typeForURL:(NSURL *)url;
+ (NSString *)preferredExtensionForShaderType:(C3DShaderType)type; // "vp", "fp", "gp"

@end
