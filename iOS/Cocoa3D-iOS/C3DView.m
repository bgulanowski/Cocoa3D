//
//  C3DView.m
//  Cocoa3D-iOS
//
//  Created by Brent Gulanowski on 2014-11-16.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DView.h"

#import "C3DCamera.h"

@implementation C3DView {
	GLfloat _diagRate;
}

- (void)setMovementRate:(GLfloat)rate {
	_movementRate = rate;
	_diagRate = _movementRate*M_SQRT1_2;
}

#pragma mark - NSResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self C3DView_commonInit];
	}
	return self;
}

+ (Class)layerClass {
	return [CAEAGLLayer class];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self C3DView_commonInit];
	}
	return self;
}

#pragma mark - Private

- (void)C3DView_commonInit {
	_displayLink = [CADisplayLink displayLinkWithTarget:_camera selector:@selector(capture)];
}

@end
