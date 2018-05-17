//
//  AppDelegate.h
//  Cocoa3DDemo
//
//  Created by Brent Gulanowski on 2014-07-11.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class C3DView;

@interface AppDelegate : NSResponder <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet C3DView *glLegacyView;
@property (weak) IBOutlet C3DView *glCoreView;

@end
