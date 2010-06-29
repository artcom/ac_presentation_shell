//
//  GridView.m
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "GridView.h"


@implementation GridView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
	
	}
    return self;
}

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
	CGColorRef blackColor=CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);

	NSImage *image = [NSImage imageNamed:@"demo_image.jpg"];
	
	CALayer *firstLayer = [CALayer layer];
	firstLayer.backgroundColor = blackColor;
	firstLayer.frame = CGRectMake(100, 100, image.size.width, image.size.height);
	firstLayer.contents = image;

	[self.layer addSublayer:firstLayer];
	
	CGColorRelease(blackColor);
}

@end
