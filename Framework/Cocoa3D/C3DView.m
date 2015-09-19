//
//  C3DView.m
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-27.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "C3DView.h"

#import "NSOpenGLContext+Cocoa3D.h"
#import "NSOpenGLPixelFormat+Cocoa3D.h"

#import "C3DCamera.h"

#import <LichenMath/LIVector.h>

static CVReturn C3DViewDisplayLink(CVDisplayLinkRef displayLink,
									   const CVTimeStamp *inNow,
									   const CVTimeStamp *inOutputTime,
									   CVOptionFlags flagsIn,
									   CVOptionFlags *flagsOut,
									   void *camera) {
	@autoreleasepool {
		[(__bridge C3DCamera *)camera capture];
	}
	
	return kCVReturnSuccess;
}

@implementation C3DView {
    LIVector_t _direction;
	NSPoint mouseLocation;
	CVDisplayLinkRef _displayLink;
	dispatch_source_t _drawTimer;
    BOOL _moveFast;
}

#pragma mark - Private

- (void)updateDisplayLinkScreen {
	
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
	
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
}

- (void)startDrawTimer {
	if (_drawTimer || _displayLink)
		return;
	_drawTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
	dispatch_source_set_timer(_drawTimer, dispatch_time(DISPATCH_TIME_NOW, 0), NSEC_PER_SEC/30.f, NSEC_PER_USEC/10000);
	dispatch_source_set_event_handler(_drawTimer, ^{
		[_camera updatePosition:1.0f/30.f];
		[self setNeedsDisplay:YES];
	});
	dispatch_resume(_drawTimer);
}

- (void)cancelDrawTimer {
	if (_drawTimer) {
		dispatch_source_cancel(_drawTimer);
		_drawTimer = nil;
	}
}

#pragma mark - Accessors

- (id<C3DCameraDrawDelegate>)drawDelegate {
    return self.camera.drawDelegate;
}

- (void)setDrawDelegate:(id<C3DCameraDrawDelegate>)drawDelegate {
    self.camera.drawDelegate = drawDelegate;
}

- (void)setUsesModernContext:(BOOL)usesModernContext {
    if (self.usesModernContext != usesModernContext) {
        if (usesModernContext) {
            [self useModernContext];
        }
        else {
            [self useLegacyContext];
        }
    }
}

- (BOOL)usesModernContext {
    return self.openGLContext.usesCoreProfile;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.camera = [C3DCamera cameraForGLContext:self.openGLContext];
		self.movementRate = 1.0f;
	}
	return self;
}

#pragma mark - NSResponder

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
	if ([theEvent isARepeat])
		return;
	[self processKeys:[theEvent charactersIgnoringModifiers] up:NO];
    [self updateVelocity];
	if (!_displayLink && _camera.moving) {
		[self startDrawTimer];
	}
}

- (void)keyUp:(NSEvent *)theEvent {
	[self processKeys:[theEvent charactersIgnoringModifiers] up:YES];
    [self updateVelocity];
	if (!_displayLink && !self.camera.moving) {
		[self cancelDrawTimer];
	}
}

- (void)flagsChanged:(NSEvent *)theEvent {
    BOOL moveFast = (theEvent.modifierFlags & NSShiftKeyMask) == NSShiftKeyMask;
    if (moveFast != _moveFast) {
        _moveFast = moveFast;
        [self updateVelocity];
    }
}

-(void)mouseDown:(NSEvent *)theEvent {
	[self mouseLook];
}

-(void)rightMouseDown:(NSEvent *)theEvent {
	
	BOOL dragging = YES;
	
	while(dragging) {
		theEvent = [[self window] nextEventMatchingMask:NSRightMouseUpMask | NSRightMouseDraggedMask | NSMouseExited];
		NSEventType eventType = [theEvent type];
		if (NSRightMouseUp == eventType|NSMouseExited == eventType)
			dragging = NO;
		else {
			if (eventType == NSMouseMoved) {
				[self.camera translateX:[theEvent deltaX]*0.1f y:0.0f z:[theEvent deltaY]*0.1f];
			}
			if (!_displayLink) {
				[self setNeedsDisplay:YES];
			}
		}
	}
}

-(void)otherMouseDown:(NSEvent *)theEvent {
	
	BOOL dragging = YES;
	
	while(dragging) {
		theEvent = [[self window] nextEventMatchingMask:NSOtherMouseUpMask | NSOtherMouseDraggedMask];
		if (NSOtherMouseUp == [theEvent type])
			dragging = NO;
		else {
			[self.camera translateX:[theEvent deltaX]*0.1f y:-[theEvent deltaY]*0.1f z:0.0f];
			if (!_displayLink) {
				[self setNeedsDisplay:YES];
			}
		}
	}
}

//-(void)mouseUp:(NSEvent *)theEvent {
//}

- (void)mouseMoved:(NSEvent *)theEvent {
	
	if (_tracksMouse) {
		NSPoint loc = [self convertPointFromBacking:[theEvent locationInWindow]];
//        if (fabs(mouseLocation.x - loc.x)>2 && fabs(mouseLocation.y-loc.y)>2) {
//            NSLog(@"Mouse at %@", NSStringFromPoint(loc));
//        }
		mouseLocation = loc;
		if (!_displayLink) {
			[self setNeedsDisplay:YES];
		}
	}
}

- (BOOL)resignFirstResponder {
	_camera.velocity = [LIVector vectorWithVector:LIVectorZero];
	return YES;
}

#pragma mark - NSView

- (void)drawRect:(NSRect)rect {
	if(!_displayLink) {
		CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
		
		CGLLockContext(cglContext);
		CGLSetCurrentContext(cglContext);
		
		[_camera capture];
        CGLUnlockContext(cglContext);
	}
}

#pragma mark - NSOpenGLView

- (void)setOpenGLContext:(NSOpenGLContext *)openGLContext {
    [super setOpenGLContext:openGLContext];
    self.camera = [C3DCamera cameraForGLContext:openGLContext];
}

#pragma mark - Input Handlers

- (void)processKeys:(NSString *)characters up:(BOOL)up {
	
	NSUInteger len = [characters length];
	BOOL forward = NO;
	BOOL back = NO;
	BOOL left = NO;
	BOOL right = NO;
	
	for(NSUInteger i=0; i<len; ++i) {
		switch ([characters characterAtIndex:i]) {
			case 's':
            case 'S':
				back = YES;
				forward = NO;
				break;
			case 'w':
            case 'W':
				forward = YES;
				back = NO;
				break;
			case 'a':
            case 'A':
				left = YES;
				right = NO;
				break;
			case 'd':
            case 'D':
				right = YES;
				left = NO;
				break;
			default:
				break;
		}
	}
	
	if (up) {
		if (forward || back) {
			_direction.z = 0;
		}
		if (left || right) {
			_direction.x = 0;
		}
	}
	else {
		if (forward) {
			if (left) {
				_direction.z = 1;
				_direction.x = 1;
			}
			else if (right) {
				_direction.z = 1;
				_direction.x = -1;
			}
			else {
				_direction.z = 1;
			}
		}
		else if (back) {
			if (left) {
				_direction.z = -1;
				_direction.x = 1;
			}
			else if (right) {
				_direction.z = -1;
				_direction.x = -1;
			}
			else {
				_direction.z = -1;
			}
		}
		else if (left) {
			_direction.x = 1;
		}
		else if (right) {
			_direction.x = -1;
		}
	}
}

- (void)updateVelocity {
    LIVector_t vector = LIVectorNormalize(_direction);
    float rate = _moveFast ? _movementRate * 8.0 : _movementRate;
    vector = LIVectorScale(vector, rate);
    _camera.velocity = [LIVector vectorWithVector:vector];
}

- (void)mouseLook {
	
	BOOL dragging = YES;
	NSWindow *window = [self window];
	
	while(dragging) {
		static NSUInteger eventMask = NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSKeyDownMask | NSKeyUpMask;
		NSEvent *event = [window nextEventMatchingMask:eventMask untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
		
		if (!event)
			continue;
		
		switch ([event type]) {
			case NSKeyDown:
				[self keyDown:event];
				break;
			case NSKeyUp:
				[self keyUp:event];
				break;
			case NSLeftMouseUp:
				dragging = NO;
				break;
			default:
			{
				LIVector_t v = LIVectorMake([event deltaX], [event deltaY], 0);
				if (LIVectorLength(v) > 0) {
					[_camera rotateX:v.x y:v.y];
				}
			}
				if (!_displayLink) {
					[self setNeedsDisplay:YES];
				}
				break;
		}
	}
}

#pragma mark - NSOpenGLView

- (void)reshape {

	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	
	CGLLockContext(cglContext);
	CGLSetCurrentContext(cglContext);
	
	NSRect bounds = [self bounds];
	
	[_camera updateProjectionForViewportSize:bounds.size];
	[_camera capture];
	
	CGLUpdateContext(cglContext);
	CGLUnlockContext(cglContext);
}

#pragma mark - Notifications

- (void)windowDidBecomeMain:(NSNotification *)notif {
	if (!_drawsInBackground && _displayLink)
		CVDisplayLinkStart(_displayLink);
}

- (void)windowDidResignMain:(NSNotification *)notif {
	if (!_drawsInBackground && _displayLink)
		CVDisplayLinkStop(_displayLink);
}

- (void)windowChangedScreen:(NSNotification*)inNotification {
	[self updateDisplayLinkScreen];
}


#pragma mark - New Facilities

- (void)enableDisplayLink {
	if (_displayLink)
		return;
	CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
	CVDisplayLinkSetOutputCallback(_displayLink, C3DViewDisplayLink, (__bridge void *)(_camera));
	[self updateDisplayLinkScreen];
	CVDisplayLinkStart(_displayLink);
}

- (void)disableDisplayLink {
	if (!_displayLink)
		return;
	CVDisplayLinkRelease(_displayLink), _displayLink = NULL;
}

- (void)useModernContext {
    self.openGLContext = [NSOpenGLContext C3DContext];
}

- (void)useLegacyContext {
    self.openGLContext = [NSOpenGLContext C3DLegacyContext];
}

@end
