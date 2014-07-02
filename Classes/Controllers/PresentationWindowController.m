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
        self.window.delegate = self;
	}
	return self;
}


- (void) setPresentations:(NSMutableArray *)newPresentations {
	if (presentations != newPresentations) {
		presentations = newPresentations;		
	}
	
	[presentationView arrangeSublayer];
}


#pragma mark - Handle screen environments


- (void)observeChangingScreens {
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
    return [[NSScreen screens] count] > 1;
}

- (NSRect)presentationScreenFrame {
	NSArray *screens = [NSScreen screens];
	NSUInteger monitorIndex = 0;
	
    // XXX: Keynote <= 6.2 does not offer this setting anymore - reactivate later
	if ([screens count] > 1) { //  && [[KeynoteHandler sharedHandler] usesSecondaryMonitorForPresentation]) {
		monitorIndex = 1;
	};
	
	return [[screens objectAtIndex: monitorIndex] frame];
}


#pragma mark - Manage window


- (void)showWindow:(id)sender {
    
    [self observeChangingScreens];
    
    [self updateWindowState];
	[self.window makeKeyAndOrderFront:nil];
    [self.window setMovable:NO];
	
	@try {
		NSApplicationPresentationOptions options = NSApplicationPresentationHideDock | NSApplicationPresentationHideMenuBar;
		[NSApp setPresentationOptions:options];
	}
	@catch(NSException * exception) {
		NSLog(@"Error.  Make sure you have a valid combination of options.");
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
     It will be left in for now because most if the users will are using a secondary screen the presentation
     experience should be visually flawless. This is further backed by the experiential data that it never did
     not work correctly when using a secondary monitor for presentation.
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
	
	[keynote play: presentation.absolutePresentationPath withDelegate: self];
	
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
