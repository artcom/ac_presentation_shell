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


- (id)init {
	self = [super initWithWindowNibName:@"PresentationWindow"];
	if (self != nil) {
		self.keynote = [KeynoteHandler sharedHandler];
        self.window.delegate = self;
	}
	return self;
}

- (void)setPresentations:(NSMutableArray *)newPresentations {
	_presentations = newPresentations;
	[self.presentationView arrangeSublayer];
}


#pragma mark - Handle screen environments


- (void)startObservingChangingScreens {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidChangeScreenParameters:)
                                                 name:NSApplicationDidChangeScreenParametersNotification
                                               object:nil];
}

- (void)stopObservingChangingScreens {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidChangeScreenParametersNotification object:nil];
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification {
    [self updateWindowState];
}

- (BOOL)usingSecondaryScreen {
    // Always use the secondary screen for presentation if available
    return [[NSScreen screens] count] > 1;
}

- (NSRect)presentationScreenFrame {
	NSUInteger monitorIndex = [self usingSecondaryScreen] ? 1 : 0;
	NSArray *screens = [NSScreen screens];
	return [[screens objectAtIndex: monitorIndex] frame];
}


#pragma mark - Manage window


- (void)showWindow:(id)sender {
    
    [self startObservingChangingScreens];
    [self updateWindowState];
    [self.window setMovable:NO];
	[self.window makeKeyAndOrderFront:nil];
	
    NSApplicationPresentationOptions options = NSApplicationPresentationHideDock | NSApplicationPresentationHideMenuBar;
	@try {
		[NSApp setPresentationOptions:options];
	}
	@catch(NSException *exception) {
		NSLog(@"Error setting NSApplicationPresentationOptions: %lu", options);
	}
	
	[super showWindow:sender];
}

- (void)updateWindowState {
	NSRect frame = [self presentationScreenFrame];
	[self.window setFrame:frame display:YES animate:NO];
    
    // FIX Issue with window levels
    /*
     See https://developer.apple.com/library/mac/documentation/cocoa/Conceptual/WinPanel/Concepts/WindowLevel.html
     
     Originally, ACShell always used NSStatusWindowLevel for its presentation window in order to sandwich it
     between any Keynote document window and the Keynote presentation mode. That way, the only things you'll ever
     see are the presentation window and the playing Keynote presentation. (Without this, you see the Keynote
     application and all its documents popping up when starting or stopping any presentation from ACShell)
     
     This doesn't seem to work correctly when using a single monitor. The Keynote playback window stays stuck
     behind the ACShell presentation window.
     
     Current solution: Use the ideal level when using a secondary screen or set the level to normal when using
     a single window. This solution is problematic, since the reason for the issue is not known, only its symptom.
     It will be left in for now because users are mostly using a secondary screen for the presentation and in
     that case the experience should be visually flawless. This is further backed by experiential data
     that it never did not work correctly when using a secondary monitor for presentation.
     
     Using NSNormalWindowLevel in single-monitor use has another benefit: It gives the user control over your
     screen back - you can open other applications and/or bring other windows to the front. The only drawback:
     When presenting on single monitor, you will see Keynote document windows.
     */
    
    NSInteger windowLevel = [self usingSecondaryScreen] ? NSStatusWindowLevel : NSNormalWindowLevel;
    [self.window setLevel:windowLevel];
}


#pragma mark - NSWindowDelegate


- (void)windowWillClose:(NSNotification *)notification {
    [self stopObservingChangingScreens];
}


#pragma mark - PresentationView DataSource


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


#pragma mark - PresentationView Delegate


- (void)presentationView:(PresentationView *)aView didClickItemAtIndex:(NSInteger)index {
    Presentation *presentation = [self.presentations objectAtIndex:index];
	
	[self.keynote play: presentation.absolutePresentationPath withDelegate: self];
	
	[aView addOverlay:[ProgressOverlayLayer layer] forItem:index];
	self.presentationView.mouseTracking = NO;
	
	// playingKeynote = index;
}


#pragma mark - Keynote Handler Delegate


-(void) didFinishStartingKeynote:(KeynoteHandler *)keynote {
	self.presentationView.mouseTracking = YES;
}

- (void) keynoteDidStopPresentation:(KeynoteHandler *)aKeynote {
	// CALayer *oldHoveredLayer = [self presentationView: presentationView hoverLayerForItemAtIndex: playingKeynote];
	// [presentationView addOverlay: oldHoveredLayer forItem: playingKeynote];
	
 	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[self window] makeKeyAndOrderFront:nil];
}

@end
