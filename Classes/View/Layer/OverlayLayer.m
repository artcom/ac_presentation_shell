//
//  OverlayLayer.m
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "OverlayLayer.h"
#import "HeightForWidthLayoutManager.h"

@implementation OverlayLayer


- (id)init {
	self = [super init];
	if (self != nil) {
		
		textLayer = [CATextLayer layer];
		textLayer.foregroundColor = CGColorGetConstantColor(kCGColorWhite);
		textLayer.wrapped = YES;
		textLayer.fontSize = 14;
		textLayer.font = (__bridge CFTypeRef)(@"AC Swiss Bold");
		
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
    
        self.backgroundColor = [NSColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f].CGColor;
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






@end
