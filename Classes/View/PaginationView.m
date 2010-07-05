//
//  PaginationView.m
//  ACShell
//
//  Created by Robert Palmer on 02.07.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PaginationView.h"

@interface PaginationView ()

- (void)prepareDots;
- (void)calculateDotPositions;
- (void)setActiveDot;

@end

@implementation PaginationView

@synthesize pages;
@synthesize activePage;

@synthesize activeDot;
@synthesize inactiveDot;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.pages = 5;
		self.activePage = 0;
		dots = [[NSMutableArray alloc] initWithCapacity:self.pages];
		
		self.layer = [CALayer layer];
		
		[self setWantsLayer:YES];
		[self prepareDots];
		[self setActiveDot];
	}
	
    return self;
}

- (void) dealloc {
	[activeDot release];
	[inactiveDot release];
	
	[super dealloc];
}


- (void)setActivePage: (NSInteger)newActivePage {
	activePage = newActivePage;
	
	[self setActiveDot]; 
	[self calculateDotPositions];
}


- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	[super resizeWithOldSuperviewSize:oldBoundsSize];
	
	[self prepareDots];
	[self setActiveDot];
	[self calculateDotPositions];
}

- (void)calculateDotPositions {
	if (!(self.activePage < self.pages)) {
		return;
		//[NSException raise:@"IndexOutOfBound" format:@"PaginationView is setup for %d pages but %d was selected" arguments:self.pages];
	}
	
	NSInteger i = 0;
	for (i = 0; i < self.dotsOnTop; i++) {
		CALayer *layer = [dots objectAtIndex:i];
		layer.frame = CGRectMake(0, (self.frame.size.height - 10 * i - 6), 6, 6);
	}
	
	for (; i < self.pages; i++) {
		CALayer *layer = [dots objectAtIndex:i];
		layer.frame = CGRectMake(0, ((self.pages - i - 1) * 10), 6, 6);		
	}
}

- (void)setActiveDot {
	for (CALayer *layer in dots) {
		layer.contents = self.inactiveDot;
	}

	CALayer *layer = [dots objectAtIndex:self.activePage];
	layer.contents = self.activeDot;
}

- (void)prepareDots {
	
	for (CALayer *dotLayer in dots) {
		[dotLayer removeFromSuperlayer];
	}
	[dots removeAllObjects];
	
	for (NSInteger i = 0; i < self.pages; i++) {
		CALayer *dotLayer = [CALayer layer];
		[self.layer addSublayer:dotLayer];
		[dots addObject:dotLayer];
	}
}

- (NSInteger) dotsOnTop {
	return self.activePage + 1;
}

- (NSInteger )dotsOnBottom {
	return self.pages - self.dotsOnTop;
}

- (NSImage *)activeDot {
	if (activeDot == nil) {
		self.activeDot = [NSImage imageNamed:@"icn_pagnation_active.png"];
	}

	return activeDot;
}

- (NSImage *)inactiveDot {
	if (inactiveDot == nil) {
		self.inactiveDot = [NSImage imageNamed:@"icn_pagnation.png"];
	}
	
	return inactiveDot;
}

@end
