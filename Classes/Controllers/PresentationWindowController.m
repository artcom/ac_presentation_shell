//
//  PresentationWindowController.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PresentationWindowController.h"
#import "Presentation.h"
#import "KeynoteHandler.h"
#import "PresentationView.h"
#import "PaginationView.h"
#import "OverlayLayer.h"
#import "ProgressOverlayLayer.h"

@implementation PresentationWindowController

@synthesize presentations;
@synthesize presentationView;


- (id)init {
	self = [super initWithWindowNibName:@"PresentationWindow"];
	if (self != nil) {
		keynote = [KeynoteHandler sharedHandler];
	}
	return self;
}


#pragma mark -
#pragma mark Setter Methods
- (void) setPresentations:(NSMutableArray *)newPresentations {
	if (presentations != newPresentations) {
		presentations = newPresentations;		
	}
	
	[presentationView arrangeSublayer];
}

- (void) showWindow:(id)sender {
	NSRect frame = [self presentationScreenFrame];
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
#pragma mark PresentationView DataSource
- (NSInteger)numberOfItemsInPresentationView:(PresentationView *)aPresentationView {
	return [self.presentations count];
}

- (CGSize)sizeForItemInPresentationView: (PresentationView *)aPresentationView {
	return CGSizeMake(220, 100);
}

- (CALayer *)presentationView:(PresentationView *)aPresentationView layerForItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];
	NSImage *image = presentation.thumbnail;
	
	CALayer *layer = [CALayer layer];
	layer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
	layer.contents = image;
	
	return layer;
}

- (CALayer *)presentationView:(PresentationView *)aPresentationView hoverLayerForItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];

	OverlayLayer *layer = [OverlayLayer layer];
	if (presentation.year) {
		layer.text = [NSString stringWithFormat: @"%@, %@", presentation.title, presentation.year];
	} else {
		layer.text = presentation.title;
	}
	return layer;
}


#pragma mark -
#pragma mark PresentationView Delegate
- (void)presentationView:(PresentationView *)aView didClickItemAtIndex:(NSInteger)index {
	Presentation *presentation = [self.presentations objectAtIndex:index];
	
	[keynote play: presentation.absolutePresentationPath withDelegate: self];
	
	[aView addOverlay:[ProgressOverlayLayer layer] forItem:index];
	self.presentationView.mouseTracking = NO;
	
	// playingKeynote = index;
}

#pragma mark -
#pragma mark Keynote Handler Delegate
-(void) didFinishStartingKeynote:(KeynoteHandler *)keynote {
	self.presentationView.mouseTracking = YES;
}

- (void) keynoteDidStopPresentation:(KeynoteHandler *)aKeynote {
	// CALayer *oldHoveredLayer = [self presentationView: presentationView hoverLayerForItemAtIndex: playingKeynote];
	// [presentationView addOverlay: oldHoveredLayer forItem: playingKeynote];
	
 	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[self window] makeKeyAndOrderFront:nil];
}

- (NSRect)presentationScreenFrame {
	NSArray *screens = [NSScreen screens];
	NSUInteger monitorIndex = 0;
	
	if ([screens count] > 1 && [[KeynoteHandler sharedHandler] usesSecondaryMonitorForPresentation]) {
		monitorIndex = 1;
	};
	
	return [[screens objectAtIndex: monitorIndex] frame];
}

@end
