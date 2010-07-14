//
//  OverlayLayer.m
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "OverlayLayer.h"
#import "HeightForWidthLayoutManager.h"

@implementation OverlayLayer


- (id)init {
	self = [super init];
	if (self != nil) {
		
		textLayer = [[CATextLayer layer] retain];
		textLayer.foregroundColor = CGColorGetConstantColor(kCGColorWhite);
		textLayer.wrapped = YES;
		textLayer.fontSize = 14;
		textLayer.font = @"AC Swiss Bold";
		
		[textLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX
															relativeTo:@"superlayer"
															 attribute:kCAConstraintMaxX
																offset:-10]];
		
		[textLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX
															relativeTo:@"superlayer"
															 attribute:kCAConstraintMinX
																offset:10]];
		
		[textLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY
															relativeTo:@"superlayer"
															 attribute:kCAConstraintMinY 
																offset:10]];
		
		
		self.contents = [NSImage imageNamed: @"gfx_project_overlay.png"];
		self.frame = CGRectMake(0, 0, 220, 100);
		self.layoutManager = [HeightForWidthLayoutManager layoutManager];
		
		[self addSublayer: textLayer];
	}
	return self;
}

- (NSString *) text {
	return textLayer.string;
}

- (void) setText:(NSString *) newText {
	textLayer.string = newText;
}

- (void) dealloc {
	[textLayer release];
	[super dealloc];
}





@end