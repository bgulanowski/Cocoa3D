//
//  Scene.h
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2015-09-13.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Cocoa3D/Cocoa3D.h>

@protocol ScenePresenter <NSObject>
@property (nonatomic, readonly) C3DCamera *camera;
@property (nonatomic, readonly) NSOpenGLContext *openGLContext;
@property (nonatomic) BOOL usesModernContext;
@end

@protocol Scene <NSObject, C3DObjectContainer>
@property (nonatomic, readonly) C3DNode *rootNode;
@property (nonatomic, readonly, getter = isLegacy) BOOL legacy;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPresenter:(id<ScenePresenter>)presenter;
@end
