//
//  ViewController.m
//  C3D-iOS Demo
//
//  Created by Brent Gulanowski on 2014-11-15.
//  Copyright (c) 2014 Lichen Labs. All rights reserved.
//

#import "ViewController.h"

#import <GLKit/GLKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	GLKView *glkView = (GLKView *) self.view;
	glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
