//
//  GridView.m
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.

#import "GridView.h"
#import "GridLayout.h"

@implementation GridView

@synthesize dataSource;
@synthesize delegate;
@synthesize page;
@synthesize hoveredLayer;

- (void)awakeFromNib {
	CALayer *rootLayer=[CALayer layer];
	CGColorRef whiteColor=CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
	rootLayer.backgroundColor=whiteColor;
	
	CGColorRelease(whiteColor);
	
	[self setLayer:rootLayer];
	[self setWantsLayer:YES];
		
	sublayers = [[NSMutableArray alloc] init];
	layout = [[GridLayout alloc] init];
	
	self.page = 0;
	[self arrangeSublayer];
	
	mouseTrackingRect = [self addTrackingRect:self.frame owner:self userData:nil assumeInside:YES];
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void) mouseUp:(NSEvent *)theEvent {
	CALayer *clickedLayer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
	if (clickedLayer == self.layer) {
		return;
	}
	
	if ([self.delegate respondsToSelector:@selector(gridView:didClickedItemAtIndex:)]) {
		[self.delegate gridView:self didClickedItemAtIndex:[sublayers indexOfObject:clickedLayer] + self.page * layout.itemsOnPage];
	}
}

- (void)mouseMoved:(NSEvent *)theEvent {
	CALayer *layer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
	if (layer != self.layer && layer != self.hoveredLayer) {
		[hoveredLayer removeFromSuperlayer];
		
		CGColorRef red = CGColorCreateGenericRGB(1, 0, 0, 1);
		
		self.hoveredLayer = [CALayer layer];
		hoveredLayer.backgroundColor = red;
		hoveredLayer.frame = layer.frame;
		
		[self.layer addSublayer:hoveredLayer];
		
		CGColorRelease(red);
	}
}

- (void) mouseEntered:(NSEvent *)theEvent {
	[[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
	[[self window] setAcceptsMouseMovedEvents:NO];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	[super resizeWithOldSuperviewSize:oldBoundsSize];

	[self removeTrackingRect:mouseTrackingRect];
	[self addTrackingRect:self.frame owner:self userData:nil assumeInside:YES];
	
	layout.viewFrame = NSRectToCGRect(self.frame);
	layout.itemSize = CGSizeMake(220, 100);
	layout.paddingVertical = 0;
	layout.paddingHorizontal = 0;
	
	[layout calculate];
	[self arrangeSublayer];
}

- (void)arrangeSublayer {
	for (CALayer *layer in sublayers) {
		[layer removeFromSuperlayer];
	}
	[sublayers removeAllObjects];
	
	NSInteger items = [dataSource numberOfItemsInGridView:self];
	NSInteger firstItem = self.page * layout.itemsOnPage;
	NSInteger lastItem = (((self.page + 1) * layout.itemsOnPage - 1) < items) ? ((self.page + 1) * layout.itemsOnPage) : items;
	
	for (int i = firstItem; i < lastItem; i++) {
		CALayer *layer = [dataSource gridView:self layerForItemAtIndex:i];
		layer.position = [layout positionForItem:i % layout.itemsOnPage];
		
		[self.layer addSublayer:layer];	
		[sublayers addObject:layer];
	}
	
	if ([delegate respondsToSelector:@selector(didUpdateGridView:)]) {
		[delegate didUpdateGridView: self];
	}
}

- (void)setPage:(NSInteger)newPage {
	[self willChangeValueForKey:@"page"];
	page = newPage;
	[self didChangeValueForKey:@"page"];
	[self arrangeSublayer];
}

- (NSInteger)pages {
	if (layout.itemsOnPage == 0) {
		return 0;
	}
	
	return ([dataSource numberOfItemsInGridView:self] / layout.itemsOnPage) + 1;
}

- (BOOL)hasNextPage {
	
}

- (BOOL)hasPreviousPage {
	
}

@end
