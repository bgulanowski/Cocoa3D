//
//  C3DView.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2014-07-27.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : unsigned char {
    kMoveNone = UCHAR_MAX,
    kMoveLeft = 0x0,
    kMoveRight,
    kMoveForward,
    kMoveBack,
    kMoveUp,
    kMoveDown,
    kYawLeft,
    kYawRight,
    kPitchForward,
    kPitchBack,
    kRollLeft,
    kRollRight
} BAMotion;

typedef enum : NSUInteger {
    kMoveLeftFlag = 1 << kMoveLeft,
    kMoveRightFlag = 1 << kMoveRight,
    kMoveForwardFlag = 1 << kMoveForward,
    kMoveBackFlag = 1 << kMoveBack,
    kMoveUpFlag = 1 << kMoveUp,
    kMoveDownFlag = 1 << kMoveDown,
    kYawLeftFlag = 1 << kYawLeft,
    kYawRightFlag = 1 << kYawRight,
    kPitchForwardFlag = 1 << kPitchForward,
    kPitchBackFlag = 1 << kPitchBack,
    kRollLeftFlag = 1 << kRollLeft,
    kRollRightFlag = 1 << kRollRight
} BAMotionFlag;

@class C3DCamera;
@protocol C3DCameraDrawDelegate;
@protocol C3DObjectContainer;

@interface C3DView : NSOpenGLView

@property (nonatomic, strong) C3DCamera *camera;
@property (nonatomic) GLfloat movementRate;
@property (nonatomic) BOOL drawsInBackground;
@property (nonatomic) BOOL tracksMouse;
@property (nonatomic) BOOL usesModernContext;
@property (nonatomic) BOOL usesDisplayLink;

@property (nonatomic) IBOutlet id<C3DCameraDrawDelegate>drawDelegate;

- (void)enableDisplayLink;
- (void)disableDisplayLink;

@end
