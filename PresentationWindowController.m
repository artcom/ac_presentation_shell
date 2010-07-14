//
//  PresentationWindowController.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PresentationWindowController.h"
#import "Presentation.h"
#import "PresentationData.h"
#import "KeynoteHandler.h"
#import "GridView.h"
#import "PaginationView.h"
#import "HeightForWidthLayoutManager.h"
#import "OverlayLayer.h"
#import "ProgressOverlayLayer.h"

@implementation PresentationWindowController

@synthesize presentations;
@synthesize gridView;
@synthesize paginationView;

- (id)init {
	self = [super initWithWindowNibName:@"PresentationWindow"];
	if (self != nil) {
		keynote = [[KeynoteHandler alloc] init];
	}
	return self;
}

- (void) dealloc {
	[keynote release];
	[presentations release];
	
	[gridView release];
	[paginationView release];
	
	
	[super dealloc];
}

- (void)awakeFromNib {
	NSRect frame = [[[NSScreen screens] objectAtIndex:0] frame];
	
	[self.window setFrame:frame display:YES animate: NO];
	[paginationView bind:@"activePage" toObject:gridView withKeyPath:@"page" options:nil];
}

#pragma mark -
#pragma mark User Actions
- (void)previousPage:(id)sender {
	if ([gridView hasPreviousPage]) {
		gridView.page -= 1;
	}
}

- (void)nextPage:(id)sender {
	if ([gridView hasNextPage]) {
		gridView.page += 1;	
	}
}


#pragma mark -
#pragma mark Setter Methods
- (void) setPresentations:(NSArray *)newPresentations {
	if (presentations != newPresentations) {
		[presentations release];
		presentations = [newPresentations mutableCopy];
		
		[gridView arrangeSublayer];
	}
}

- (void) showWindow:(id)sender {
	NSRect frame = [[[NSScreen screens] objectAtIndex:1] frame];
	
	[self.window setFrame:frame display:YES animate: NO];
	[self.window makeKeyAndOrderFront:nil];
	
	@try {
		NSApplicationPresentationOptions options = NSApplicationPresentationHideDock + NSApplicationPresentationHideMenuBar;
		[NSApp setPresentationOptions:options];
	}
	@catch(NSException * exception) {
		NSLog(@"Error.  Make sure you have a valid combination of options.");
	}
	
	[super showWindow:sender];
	[paginationView updateView];	
}


#pragma mark -
#pragma mark GridView DataSource
- (NSInteger)numberOfItemsInGridView:(GridView *)aGridView {
	return [self.presentations count];
}

- (CGSize)sizeForItemInGridView: (GridView *)aGridView {
	return CGSizeMake(220, 100);
}

- (CALayer *)gridView:(GridView *)aGridView layerForItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];
	NSImage *image = presentation.thumbnail;
	
	CALayer *layer = [CALayer layer];
	layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	layer.contents = image;
	
	return layer;
}

- (CALayer *)gridView:(GridView *)aGridView hoverLayerForItemAtIndex:(NSInteger)index {
	
	Presentation *presentation = [self.presentations objectAtIndex:index];

	OverlayLayer *layer = [OverlayLayer layer];
	layer.text = presentation.data.title;
	
	return layer;
}


#pragma mark -
#pragma mark GridView Delegate
- (void)gridView:(GridView *)aView didClickedItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];
	[aView addOverlay:[ProgressOverlayLayer layer] forItem:index];
	
	[keynote open: presentation.presentationFile];
}

- (void) didUpdateGridView:(GridView *)aView {	
	 paginationView.pages = aView.pages;
}

@end
