//
//  OverlayLayer.m
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "OverlayLayer.h"
#import "HeightForWidthLayoutManager.h"


@interface OverlayLayer ()
@property (nonatomic, strong) CATextLayer *textLayer;
@end

@implementation OverlayLayer


- (id)init {
	self = [super init];
	if (self != nil) {
		
		CATextLayer *textLayer = [CATextLayer layer];
		textLayer.foregroundColor = CGColorGetConstantColor(kCGColorWhite);
		textLayer.wrapped = YES;
		textLayer.fontSize = 14;
		textLayer.font = (__bridge CFTypeRef)(@"ACSwiss-Bold");
        textLayer.delegate = self;
		
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
        self.textLayer = textLayer;
	}
	return self;
}

- (NSString *) text {
	return self.textLayer.string;
}

- (void) setText:(NSString *) newText {
	self.textLayer.string = newText;
}

- (void)setContentsScale:(CGFloat)contentsScale {
    [super setContentsScale:contentsScale];
    self.textLayer.contentsScale = contentsScale;
}

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale fromWindow:(NSWindow *)window {
    NSLog(@"TEST: textLayer of OverlayLayer is calling shouldInheritContentsScale with %f", newScale);
    return YES;
}


@end
