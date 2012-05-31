//
//  PresentationView.m
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.

#import "PresentationView.h"
#import "GridLayout.h"
#import "PaginationView.h"

#define GRID_BORDER 10

@interface PresentationView () 
- (void)setUpAccessorieViews;
- (void)setupView;
- (void)updateMouseTrackingRect;
- (void)updateLayout;
- (NSInteger)lastItemOnPage;
- (void)didUpdatePages;

- (void)viewDidResize: (NSNotification *)aNotification;
@end

@implementation PresentationView

@synthesize dataSource;
@synthesize delegate;
@synthesize page;
@synthesize hoveredLayer;
@synthesize mouseTracking;
@synthesize layout;

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
	rootLayer.frame = NSRectToCGRect(self.frame);
	rootLayer.backgroundColor = CGColorGetConstantColor(kCGColorWhite);
	[self setLayer:rootLayer];
	[self setWantsLayer:YES];
	
	sublayers = [[NSMutableArray alloc] init];
	layout = [[GridLayout alloc] init];
	
	self.page = 0;	
	self.mouseTracking = YES;
	
	[self setUpAccessorieViews];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidResize:) 
												 name:NSViewFrameDidChangeNotification object:self];	
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (void) mouseUp:(NSEvent *)theEvent {
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	CALayer *clickedLayer = nil;
	for (CALayer *layer in sublayers) {
		if ([layer hitTest:NSPointToCGPoint(location)]) {
			clickedLayer = layer;
		} 
	}
	
	if (clickedLayer == nil) {
		return;
	}
	
	NSInteger selectedItem = [self indexOfItemOnPage:[sublayers indexOfObject: clickedLayer]];
	if ([self.delegate respondsToSelector:@selector(presentationView:didClickedItemAtIndex:)]) {
		[self.delegate presentationView:self didClickedItemAtIndex:selectedItem];
	}
}

- (void)mouseMoved:(NSEvent *)theEvent {
	if (!self.mouseTracking || ![dataSource respondsToSelector: @selector(presentationView:hoverLayerForItemAtIndex:)]) {
		return;
	}
	
	CALayer *layer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];

	if (layer == self.layer) {
		[self.hoveredLayer removeFromSuperlayer];
		self.hoveredLayer = nil;
        
		return;
	}
	
	if (![sublayers containsObject:layer] || layer == self.hoveredLayer) {
		return;
	}

	[self.hoveredLayer removeFromSuperlayer];
	hoveredItem = [self indexOfItemOnPage:[sublayers indexOfObject:layer]];
		
	self.hoveredLayer = [dataSource presentationView:self hoverLayerForItemAtIndex:hoveredItem];
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


- (void)moveUp:(id)sender {
	if ([self hasPreviousPage]) {
		self.page -= 1;
	}
}

- (void)moveDown:(id)sender {
	if ([self hasNextPage]) {
		self.page += 1;	
	}
}

- (void)arrangeSublayer {
	[self updateLayout];
	for (CALayer *layer in sublayers) {
		[layer removeFromSuperlayer];
	}
	
	[sublayers removeAllObjects];
	
	NSInteger firstItem = [self firstItemOnPage];
	NSInteger lastItem = [self lastItemOnPage];
	
	for (int i = firstItem; i <= lastItem; i++) {
		CALayer *layer = [dataSource presentationView:self layerForItemAtIndex:i];
		layer.position = [layout positionForItem:i % layout.itemsOnPage];
		
		[self.layer addSublayer:layer];	
		[sublayers addObject:layer];
	}

	[self didUpdatePages];
}


- (void)setPage:(NSInteger)newPage {
	[self.hoveredLayer removeFromSuperlayer];
	self.hoveredLayer = nil;
	
	[self willChangeValueForKey:@"page"];
	page = newPage;
	[self didChangeValueForKey:@"page"];
	[self arrangeSublayer];
}


- (NSInteger)pages {
	if (layout.itemsOnPage == 0) {
		return 0;
	}
	
	return ceil(([dataSource numberOfItemsInPresentationView:self] / (float)layout.itemsOnPage));
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
	NSInteger items = [dataSource numberOfItemsInPresentationView:self];
	
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
- (void)setDataSource:(id <PresentationViewDataSource>)newDataSource {
	dataSource = newDataSource;
	[self updateLayout];
}

- (void) setMouseTracking:(BOOL)newMouseTracking {
	mouseTracking = newMouseTracking;
	
	[self updateMouseTrackingRect];
}


#pragma mark -
#pragma mark Resizing
- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize {
	[super resizeWithOldSuperviewSize:oldBoundsSize];
	[self viewDidResize:nil];
}

- (void)viewDidResize: (NSNotification *)aNotification {
	[self arrangeSublayer];
	
	NSRect screenFrame = self.frame;

	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	CGFloat verticalMargin = (screenFrame.size.height - layout.viewPort.size.height) * 0.5;
	CGFloat logoYOrigin = (verticalMargin * 1.5) + layout.viewPort.size.height - logo.frame.size.height / 2;
	logo.frame = CGRectMake(layout.viewPort.origin.x, logoYOrigin, logo.frame.size.width, logo.frame.size.height);
	[CATransaction commit];	

	CGFloat pagerButtonsXOrigin = layout.viewPort.origin.x + layout.viewPort.size.width - pageButtons.frame.size.width;
	[pageButtons setFrameOrigin: NSMakePoint(pagerButtonsXOrigin, layout.viewPort.origin.y - 23 - pageButtons.frame.size.height)];
	
	[paginationView setFrameOrigin:NSMakePoint(layout.viewPort.origin.x + layout.viewPort.size.width + 20, layout.viewPort.origin.y)];
	[paginationView setFrameSize:NSMakeSize(paginationView.frame.size.width, layout.viewPort.size.height)];
	
	[self updateMouseTrackingRect];
}

#pragma mark -
#pragma mark Set Up Accessorie Views

- (void)setUpAccessorieViews {
	NSImage *logoImage = [NSImage imageNamed:@"gfx_ac_logo.png"];
	logo = [[CALayer layer] retain];
	logo.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
	logo.contents = logoImage;
	[self.layer addSublayer: logo];
	
	paginationView = [[PaginationView alloc] initWithFrame:NSMakeRect(0, 0, 6, 100)];
	paginationView.pages = 1;
	paginationView.activePage = 0;
	[self addSubview:paginationView];
	
	pageButtons = (NSButton*) [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 32, 10)];
	
	NSButton *upButtons = [[[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 15, 10)] autorelease];
	[upButtons setImage: [NSImage imageNamed:@"icn_prev_page.png"]];
	[upButtons setBordered:NO];
	[upButtons setTarget:self];
	[upButtons setAction:@selector(moveUp:)];
	[pageButtons addSubview:upButtons];
	
	NSButton *downButtons = [[[NSButton alloc] initWithFrame: NSMakeRect(17, 0, 15, 10)] autorelease];
	[downButtons setImage:[NSImage imageNamed:@"icn_next_page.png"]];
	[downButtons setBordered:NO];
	[downButtons setTarget:self];
	[downButtons setAction:@selector(moveDown:)];
	[pageButtons addSubview:downButtons];
	
	[self addSubview:pageButtons];
	
	[paginationView bind:@"activePage" toObject:self withKeyPath:@"page" options:nil];
}

#pragma mark -
#pragma mark Private Methods

- (void)didUpdatePages {
	paginationView.pages = self.pages;
	
	BOOL isHidden = self.pages == 1;
	[paginationView setHidden: isHidden];
	[pageButtons setHidden: isHidden];
	
	if (self.page >= self.pages && self.pages != 0) {
		self.page -= 1;
	}
	
	if ([delegate respondsToSelector:@selector(didUpdatePresentationView:)]) {
		[delegate didUpdatePresentationView: self];
	}
	
}

- (void)updateMouseTrackingRect {
	[self removeTrackingRect:mouseTrackingRectTag];
	
	if (mouseTracking) {
		NSRect trackingRect = NSRectFromCGRect(self.layout.viewPort);
		mouseTrackingRectTag = [self addTrackingRect:trackingRect owner:self userData:nil assumeInside:YES];
	}
}

- (void)updateLayout {
	layout.viewFrame = NSRectToCGRect(self.frame);
	layout.border = GRID_BORDER;	
	
	if ([dataSource respondsToSelector:@selector(sizeForItemInPresentationView:)]) {
		layout.itemSize = [dataSource sizeForItemInPresentationView:self];		
	}
	
	[layout calculate];
}

@end
