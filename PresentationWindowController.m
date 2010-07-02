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


@implementation PresentationWindowController

@synthesize presentations;
@synthesize gridView;

- (id)init {
	self = [super initWithWindowNibName:@"PresentationWindow"];
	if (self != nil) {
		keynote = [[KeynoteHandler alloc] init];
	}
	return self;
}

- (void)awakeFromNib {
	NSRect frame = [[[NSScreen screens] objectAtIndex:0] frame];
	
	[self.window setFrame:frame display:YES animate: NO];
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
	NSRect frame = [[[NSScreen screens] objectAtIndex:0] frame];
	
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
}


#pragma mark -
#pragma mark GridView DataSource
- (NSInteger)numberOfItemsInGridView:(GridView *)aGridView {
	return [self.presentations count];
}

- (CALayer *)gridView:(GridView *)aGridView layerForItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];
	NSImage *image = presentation.thumbnail;
	
	CALayer *layer = [CALayer layer];
	layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	layer.contents = image;
	
	return layer;
}

#pragma mark -
#pragma mark GridView Delegate
- (void)gridView:(GridView *)aView didClickedItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];
	
	[keynote open: presentation.presentationFile];
}

-(void) moveUp:(id)sender {
	NSLog(@"move up");
}


@end
