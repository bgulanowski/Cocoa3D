//
//  C3DShader.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-14.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DShader.h"

#ifdef TARGET_OS_IPHONE
#import <OpenGLES/ES3/gl.h>
#else
#import <OpenGL/gl3.h>
#endif

static NSArray *typeNames;

#ifdef TARGET_OS_IPHONE
static GLenum glTypes[] = { GL_VERTEX_SHADER, GL_FRAGMENT_SHADER };
#else
static GLenum glTypes[] = { GL_VERTEX_SHADER, GL_FRAGMENT_SHADER, GL_GEOMETRY_SHADER };
#endif

@interface NSBundle (Cocoa3D)
+ (NSURL *)URLForVertexShaderNamed:(NSString *)name;
+ (NSURL *)URLForFragmentShaderNamed:(NSString *)name;
@end

@interface NSString (Cocoa3D)
+ (instancetype)vertexShaderStringWithName:(NSString *)name;
+ (instancetype)fragmentShaderStringWithName:(NSString *)name;
@end

@implementation C3DShader {
	GLuint _name;
}

+ (void)initialize {
	if (!typeNames) {
		typeNames = @[@"vp", @"fp", @"gp", @"vsh", @"fsh", @"gsh"];
	}
}

- (instancetype)initWithString:(NSString *)source type:(C3DShaderType)type {
	self = [super init];
	if (self) {
		NSAssert(type < C3DShaderTypeCount, @"shader type invalid");
		_name = glCreateShader(glTypes[type]);
		const GLchar *shaderSource = [source UTF8String];
		const GLint length = (GLint)[source lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		glShaderSource(_name, 1, &shaderSource, &length);
	}
	return self;
}

- (instancetype)initWithURL:(NSURL *)url {
	return [self initWithString:[NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL] type:[[self class] typeForURL:url]];
}

- (instancetype)initWithName:(NSString *)name {
	return [self initWithURL:[[NSBundle mainBundle] URLForResource:name withExtension:nil]];
}

- (GLuint)shaderName {
	return _name;
}

- (void)compile {
	glCompileShader(_name);
	
	GLint res = 0;
	glGetShaderiv(_name, GL_COMPILE_STATUS, &res);
	
	if (res == GL_FALSE) {
		
		GLchar info[512] = "";
		GLsizei l = 511;
		glGetShaderInfoLog(_name, l, &l, info);
		
		NSString *msg = [NSString stringWithCString:info encoding:NSUTF8StringEncoding];
		NSLog(@"Compile error for shader: %@", msg);
	}
}

+ (instancetype)vertexShaderWithName:(NSString *)name {
	return [[self alloc] initWithString:[NSString vertexShaderStringWithName:name] type:C3DShaderTypeVertex];
}

+ (instancetype)fragmentShaderWithName:(NSString *)name {
	return [[self alloc] initWithString:[NSString fragmentShaderStringWithName:name] type:C3DShaderTypeFragment];
}

+ (C3DShaderType)typeForFileExtension:(NSString *)extension {
	return [typeNames indexOfObject:extension] % (int)C3DShaderTypeCount;
}

+ (C3DShaderType)typeForURL:(NSURL *)url {
	return [self typeForFileExtension:[url pathExtension]];
}

+ (NSString *)preferredExtensionForShaderType:(C3DShaderType)type {
	return [typeNames objectAtIndex:type];
}

@end

@implementation NSBundle (Cocoa3D)

+ (NSURL *)URLForVertexShaderNamed:(NSString *)name {
	return [[self mainBundle] URLForResource:name withExtension:[C3DShader preferredExtensionForShaderType:C3DShaderTypeVertex]];
}

+ (NSURL *)URLForFragmentShaderNamed:(NSString *)name {
	return [[self mainBundle] URLForResource:name withExtension:[C3DShader preferredExtensionForShaderType:C3DShaderTypeFragment]];
}

@end

@implementation NSString (Cocoa3D)

+ (instancetype)shaderStringWithURL:(NSURL *)URL {
	NSError *error = nil;
	NSString *string = [self stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&error];
	if (!string) {
		NSLog(@"Failed to read file with URL %@", URL);
	}
	return string;
}

+ (instancetype)vertexShaderStringWithName:(NSString *)name {
	return [self shaderStringWithURL:[NSBundle URLForVertexShaderNamed:name]];
}

+ (instancetype)fragmentShaderStringWithName:(NSString *)name {
	return [self shaderStringWithURL:[NSBundle URLForFragmentShaderNamed:name]];
}

@end
