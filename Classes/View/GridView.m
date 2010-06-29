//
//  GridView.m
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.

#import "GridView.h"


@implementation GridView

@synthesize dataSource;

- (void)awakeFromNib {
	CALayer *rootLayer=[CALayer layer];
	CGColorRef whiteColor=CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
	rootLayer.backgroundColor=whiteColor;
	
	CGColorRelease(whiteColor);
	
	[self setLayer:rootLayer];
	[self setWantsLayer:YES];
	
	[self arrangeSublayer];
}

- (void) mouseUp:(NSEvent *)theEvent {
	NSLog(@"%@", [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])]);
}


- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
}

- (void)arrangeSublayer {

	NSInteger items = [dataSource numberOfItemsInGridView:self]; 
	for (int i = 0; i < items; i++) {
		CALayer *layer = [dataSource gridView:self layerForItemAtIndex:i];
		layer.position = CGPointMake(150, 150*i);
		
		[self.layer addSublayer:layer];		
	}
	

	
}

@end
