//
//  ProgressOverlayLayer.m
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ProgressOverlayLayer.h"

#import <math.h>

@implementation ProgressOverlayLayer

- (id) init {
	self = [super init];
	if (self != nil) {
		self.text = @"Projekt wird geladen...";

		spinner = [[CALayer layer] retain];
		spinner.frame = self.frame;
		spinner.contentsGravity = kCAGravityCenter;
		spinner.contents = [NSImage imageNamed:@"spinner.png"];
				
		[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rotate) userInfo:nil repeats:YES];
		[self addSublayer: spinner];
	}
	return self;
}

- (void)rotate {
	rotation += (-2 * M_PI) / 12;

	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	spinner.transform = CATransform3DMakeRotation(rotation, 0, 0, 1);
	[CATransaction commit];
}

- (void)dealloc {
	[spinner release];
	[super dealloc];
}


@end
