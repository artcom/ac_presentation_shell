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

@property (strong, nonatomic) NSMutableArray *sublayers;

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
    
    self.sublayers = [[NSMutableArray alloc] init];
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

- (float)backingScaleFactor {
    return [[self window] backingScaleFactor];
}

- (void)viewDidChangeBackingProperties {
    float backingScaleFactor = [self backingScaleFactor];
    self.layer.contentsScale = backingScaleFactor;
    for (CALayer *layer in self.sublayers) {
        layer.contentsScale = backingScaleFactor;
    }
    [self.hoverLayer setContentsScale:backingScaleFactor];
}

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale fromWindow:(NSWindow *)window {
    return YES;
}


- (void) mouseUp:(NSEvent *)theEvent {
    if (!mouseTracking) return;
    
    NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    CALayer *clickedLayer = nil;
    for (CALayer *layer in self.sublayers) {
        if ([layer hitTest:NSPointToCGPoint(location)]) {
            clickedLayer = layer;
        }
    }
    
    if (clickedLayer == nil) {
        return;
    }
    
    NSInteger selectedItem = [self indexOfItemOnPage:[self.sublayers indexOfObject: clickedLayer]];
    if ([self.delegate respondsToSelector:@selector(presentationView:didClickItemAtIndex:)]) {
        [self.delegate presentationView:self didClickItemAtIndex:selectedItem];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if (!self.mouseTracking || ![dataSource respondsToSelector: @selector(presentationView:hoverLayerForItemAtIndex:)]) {
        return;
    }
    
    CALayer *layer = [self.layer hitTest:NSPointToCGPoint([theEvent locationInWindow])];
    
    if (layer == self.layer) {
        self.hoverLayer = nil;
        return;
    }
    
    if (![self.sublayers containsObject:layer] || layer == self.hoverLayer) {
        return;
    }
    
    hoveredItem = [self indexOfItemOnPage:[self.sublayers indexOfObject:layer]];
    
    CALayer *hoverLayer = [dataSource presentationView:self hoverLayerForItemAtIndex:hoveredItem];
    hoverLayer.frame = layer.frame;
    self.hoverLayer = hoverLayer;
}

- (void) mouseEntered:(NSEvent *)theEvent {
    [[self window] setAcceptsMouseMovedEvents:YES];
}


- (void)mouseExited:(NSEvent *)theEvent {
    self.hoverLayer = nil;
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
    for (CALayer *layer in self.sublayers) {
        [layer removeFromSuperlayer];
    }
    
    [self.sublayers removeAllObjects];
    
    NSInteger firstItem = [self firstItemOnPage];
    NSInteger lastItem = [self lastItemOnPage];
    
    CGSize itemSize = [dataSource sizeForItemInPresentationView:self];
    CGRect itemBounds = CGRectMake(0.0f, 0.0f, itemSize.width, itemSize.height);
    for (int i = firstItem; i <= lastItem; i++) {
        CALayer *layer = [dataSource presentationView:self layerForItemAtIndex:i];
        layer.position = [layout positionForItem:i % layout.itemsOnPage];
        layer.contentsScale = [[self window] backingScaleFactor];
        layer.bounds = itemBounds;
        [self.layer addSublayer:layer];
        [self.sublayers addObject:layer];
    }
    [self didUpdatePages];
}


- (void)setPage:(NSInteger)newPage {
    self.hoverLayer = nil;
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

- (void)addOverlay:(CALayer *)newOverlay forItem: (NSInteger)index {
    newOverlay.position = [layout positionForItem: index % layout.itemsOnPage];
    [self setHoverLayer:newOverlay];
}

- (void)setHoverLayer:(CALayer *)hoverLayer {
    [self.hoverLayer removeFromSuperlayer];
    if (hoverLayer) {
        hoverLayer.contentsScale = [self backingScaleFactor];
        hoverLayer.delegate = self;
        [self.layer addSublayer:hoverLayer];
    }
    _hoverLayer = hoverLayer;
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
    CGFloat headerYOrigin = (verticalMargin * 1.5) + layout.viewPort.size.height - self.headerView.frame.size.height / 2;
    self.headerView.frame = CGRectMake(layout.viewPort.origin.x, headerYOrigin, layout.viewPort.size.width, 32.0);
    [CATransaction commit];
    
    [self.headerView updateLayout];
    
    CGFloat pagerButtonsXOrigin = layout.viewPort.origin.x + layout.viewPort.size.width - pageButtons.frame.size.width;
    [pageButtons setFrameOrigin: NSMakePoint(pagerButtonsXOrigin, layout.viewPort.origin.y - 23 - pageButtons.frame.size.height)];
    
    [paginationView setFrameOrigin:NSMakePoint(layout.viewPort.origin.x + layout.viewPort.size.width + 20, layout.viewPort.origin.y)];
    [paginationView setFrameSize:NSMakeSize(paginationView.frame.size.width, layout.viewPort.size.height)];
    
    [self updateMouseTrackingRect];
}

#pragma mark -
#pragma mark PresentationHeaderViewDataSource

- (NSInteger)indexForSelectedCategoryInPresentationHeaderView:(PresentationHeaderView *)presentationHeaderView
{
    return [self.dataSource indexForSelectedCategoryInPresentationView:self];
}

- (NSArray *)titlesForCategoriesInPresentationHeaderView:(PresentationHeaderView *)presentationHeaderView
{
    return [self.dataSource titlesForCategoriesInPresentationView:self];
}

#pragma mark -
#pragma mark PresentationHeaderViewDelegate

- (void)presentationHeaderView:(PresentationHeaderView *)headerView didSelectCategoryAtIndex:(NSInteger)index
{
    [self.delegate presentationView:self didSelectCategoryAtIndex:index];
}

- (void)presentationHeaderViewDidClickResetButton:(PresentationHeaderView *)headerView
{
    [self.delegate presentationViewDidClickResetButton:self];
}

#pragma mark -
#pragma mark Set Up Accessory Views

- (void)setUpAccessorieViews {
    
    self.headerView = [[PresentationHeaderView alloc] initWithFrame:NSMakeRect(0, 0, 240, 32)];
    self.headerView.dataSource = self;
    self.headerView.delegate = self;
    [self addSubview:self.headerView];
    
    paginationView = [[PaginationView alloc] initWithFrame:NSMakeRect(0, 0, 6, 100)];
    paginationView.pages = 1;
    paginationView.activePage = 0;
    [self addSubview:paginationView];
    
    pageButtons = (NSButton*) [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 32, 10)];
    
    NSButton *upButtons = [[NSButton alloc] initWithFrame: NSMakeRect(0, 0, 15, 10)];
    [upButtons setImage:[NSImage imageNamed:@"presentation_icon_prev_page"]];
    [upButtons setBordered:NO];
    [upButtons setTarget:self];
    [upButtons setAction:@selector(moveUp:)];
    [pageButtons addSubview:upButtons];
    
    NSButton *downButtons = [[NSButton alloc] initWithFrame: NSMakeRect(17, 0, 15, 10)];
    [downButtons setImage:[NSImage imageNamed:@"presentation_icon_next_page"]];
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
