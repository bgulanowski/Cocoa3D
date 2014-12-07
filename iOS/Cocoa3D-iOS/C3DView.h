//
//  C3DView.h
//  Cocoa3D-iOS
//
//  Created by Brent Gulanowski on 2014-11-16.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class C3DCamera;

@interface C3DView : UIView

@property (nonatomic, strong) C3DCamera *camera;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) GLfloat movementRate;

@end
