//
//  PaginationView.m
//  ACShell
//
//  Created by Robert Palmer on 02.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
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
		self.layer = [CALayer layer];
		[self setWantsLayer:YES];
		
		dots = [[NSMutableArray alloc] init];
        
		self.pages = 1;
		self.activePage = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:)
													 name:NSViewFrameDidChangeNotification object:self];
	}
	
    return self;
}

- (void)updateView {
	[self prepareDots];
	[self setActiveDot];
	[self calculateDotPositions];
}


- (void)setPages: (NSInteger)newPages {
	pages = newPages;
	
	if (self.activePage >= pages) {
		self.activePage = MAX(0, pages - 1);
	}
	
	[self updateView];
}


- (void)setActivePage: (NSInteger)newActivePage {
	activePage = newActivePage;
    
	[self calculateDotPositions];
	[self setActiveDot];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	[super resizeWithOldSuperviewSize:oldBoundsSize];
	
	[self updateView];
}

- (void)calculateDotPositions {
	if (self.pages < 1) {
		return;
	}
	
	if ((self.activePage >= self.pages)) {
		return;
		//[NSException raise:@"IndexOutOfBound" format:@"PaginationView is setup for %d pages but %d was selected" arguments:self.pages, self.activePage];
	}
    
	[CATransaction begin];
	NSInteger i = 0;
	for (i = 0; i < self.dotsOnTop; i++) {
		CALayer *layer = [dots objectAtIndex:i];
		layer.frame = CGRectMake(0, (self.frame.size.height - 10 * i - 6), 6, 6);
	}
	
	for (; i < self.pages; i++) {
		CALayer *layer = [dots objectAtIndex:i];
		layer.frame = CGRectMake(0, ((self.pages - i - 1) * 10), 6, 6);
	}
	[CATransaction commit];
}

- (void)setActiveDot {
	for (CALayer *layer in dots) {
		layer.contents = self.inactiveDot;
	}
	
    if (dots.count > 0) {
        CALayer *layer = [dots objectAtIndex:self.activePage];
        layer.contents = self.activeDot;
    }
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
		self.activeDot = [NSImage imageNamed:@"icn_pagination_active.png"];
	}
    
	return activeDot;
}

- (NSImage *)inactiveDot {
	if (inactiveDot == nil) {
		self.inactiveDot = [NSImage imageNamed:@"icn_pagination.png"];
	}
	
	return inactiveDot;
}

- (void)viewDidResize: (NSNotification *)notification {
	[self updateView];
}

@end
