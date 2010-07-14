//
//  GridView.m
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.

#import "GridView.h"
#import "GridLayout.h"

@interface GridView () 
- (void)setupView;
- (void)updateMouseTrackingRect;
- (void)updateLayout;
- (NSInteger)lastItemOnPage;
@end


@implementation GridView

@synthesize dataSource;
@synthesize delegate;
@synthesize page;
@synthesize hoveredLayer;

-(id) initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self != nil) {
		[self setupView];
	}
	return self;
}

- (void)awakeFromNib {
	[self setupView];
}

- (void)setupView {
	CALayer *rootLayer=[CALayer layer];
	rootLayer.backgroundColor= CGColorGetConstantColor(kCGColorWhite);
	[self setLayer:rootLayer];
	[self setWantsLayer:YES];
	
	sublayers = [[NSMutableArray alloc] init];
	layout = [[GridLayout alloc] init];
	
	self.page = 0;
	
	[self updateLayout];
	[self updateMouseTrackingRect];
	[self arrangeSublayer];
}


- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void) mouseUp:(NSEvent *)theEvent {
	CALayer *clickedLayer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
	if (clickedLayer == self.layer) {
		return;
	}
	
	NSInteger selectedItem = -1;
	if (clickedLayer == self.hoveredLayer) {
		selectedItem = hoveredItem;
	} else {
		selectedItem = [self indexOfItemOnPage:[sublayers indexOfObject: clickedLayer]];
	}
	
	if ([self.delegate respondsToSelector:@selector(gridView:didClickedItemAtIndex:)]) {
		[self.delegate gridView:self didClickedItemAtIndex:selectedItem];
	}
}

- (void)mouseMoved:(NSEvent *)theEvent {
	if (![dataSource respondsToSelector: @selector(gridView:hoverLayerForItemAtIndex:)]) {
		return;
	}
	
	CALayer *layer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];

	if (layer == self.layer) {
		[self.hoveredLayer removeFromSuperlayer];
		self.hoveredLayer == nil;
		return;
	}
	
	if (![sublayers containsObject:layer] || layer == self.hoveredLayer) {
		return;
	}

	[self.hoveredLayer removeFromSuperlayer];
	hoveredItem = [self indexOfItemOnPage:[sublayers indexOfObject:layer]];
		
	self.hoveredLayer = [dataSource gridView:self hoverLayerForItemAtIndex:hoveredItem];
	self.hoveredLayer.frame = layer.frame;
		
	[self.layer addSublayer: self.hoveredLayer];
}


- (void) mouseEntered:(NSEvent *)theEvent {
	[[self window] setAcceptsMouseMovedEvents:YES];
}


- (void)mouseExited:(NSEvent *)theEvent {
	[self.hoveredLayer removeFromSuperlayer];

	[[self window] setAcceptsMouseMovedEvents:NO];
}


- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	[super resizeWithOldSuperviewSize:oldBoundsSize];

	[self updateMouseTrackingRect];
	[self updateLayout];
	
	[self arrangeSublayer];
}


- (void)arrangeSublayer {
	for (CALayer *layer in sublayers) {
		[layer removeFromSuperlayer];
	}
	
	[sublayers removeAllObjects];
	
	NSInteger firstItem = [self firstItemOnPage];
	NSInteger lastItem = [self lastItemOnPage];
	
	for (int i = firstItem; i <= lastItem; i++) {
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
	
	return ceil(([dataSource numberOfItemsInGridView:self] / (float)layout.itemsOnPage));
}

- (void)addOverlay: (CALayer *)newOverlay forItem: (NSInteger)index {
	[self.hoveredLayer removeFromSuperlayer];
	
	newOverlay.position = [layout positionForItem: index % layout.itemsOnPage];
	self.hoveredLayer = newOverlay;

	[self.layer addSublayer:self.hoveredLayer];
}


- (BOOL)hasNextPage {
	return (self.page + 1 < self.pages);
}


- (BOOL)hasPreviousPage {
	return (self.page - 1 >= 0);
}

- (NSInteger)lastItemOnPage {
	NSInteger items = [dataSource numberOfItemsInGridView:self];
	
	return (((self.page + 1) * layout.itemsOnPage - 1) < items) ? ((self.page + 1) * layout.itemsOnPage) - 1 : items -1;
}

- (NSInteger)firstItemOnPage; {
	return self.page * layout.itemsOnPage;
}

- (NSInteger)indexOfItemOnPage: (NSInteger)index {
	return index + self.page * layout.itemsOnPage;
}


#pragma mark -
#pragma mark Setter/Getter 
- (void)setDataSource:(id <GridViewDataSource>)newDataSource {
	dataSource = newDataSource;
	[self updateLayout];
}


#pragma mark -
#pragma mark Private Methods
- (void)updateMouseTrackingRect {
	[self removeTrackingRect:mouseTrackingRectTag];
	NSRect trackingRect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
	mouseTrackingRectTag = [self addTrackingRect:trackingRect owner:self userData:nil assumeInside:YES];
}

- (void)updateLayout {
	layout.viewFrame = NSRectToCGRect(self.frame);
	layout.border = 10;	

	if ([dataSource respondsToSelector:@selector(sizeForItemInGridView:)]) {
		layout.itemSize = [dataSource sizeForItemInGridView:self];		
	}
		 
	[layout calculate];
}






@end
