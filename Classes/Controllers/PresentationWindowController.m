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


@interface PresentationWindowController()
@property (assign) NSInteger selectedPresentationIndex;
@end

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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidChangeScreenParametersNotification
                                                  object:nil];
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
	return [screens[monitorIndex] frame];
}


#pragma mark - Manage window


- (void)showWindow:(id)sender {
    
    [self startObservingChangingScreens];
    [self updateWindowState];
	
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
    [self.window setMovable:NO];
	[self.window makeKeyAndOrderFront:nil];
    
    // FIX Issue with window levels
    /*
     See https://developer.apple.com/library/mac/documentation/cocoa/Conceptual/WinPanel/Concepts/WindowLevel.html
     
     Originally, ACShell always used NSStatusWindowLevel for this presentation window in order to sandwich it
     between any Keynote document window and the Keynote presentation mode. That way, the only things you'll ever
     see are this presentation window and a playing Keynote presentation. (Without this, you see the Keynote
     application and all its documents popping up when starting or stopping any presentation from ACShell)
     
     This doesn't seem to work correctly when using a single monitor. The Keynote playback window stays stuck
     behind the ACShell presentation window. It's unclear why, the Keynote playback window does not seem to 
     use the same level as with two monitors.
     
     Ideally, we would now just choose a lower level for this presentation window. The issue we now face is that
     when transitioning between ACShell and Keynote, we *will* see other elements pop up (the menu bar of 
     the Keynote application, Keynote document windows).
     
     This is okay when using one monitor only: In this case the presenter is showing something on his machine,
     the setting there is often a casual one, so no big deal, when we see the menu bar of Keynote for a short 
     time.
     
     If a secondary screen is used, the presentation is less casual and should appear flawless. Therefore, we
     keep the NSStatusWindowLevel for this case.
     
     NSNormalWindowLevel = 0
     NSFloatingWindowLevel = 3
     NSSubmenuWindowLevel = 3
     NSTornOffMenuWindowLevel = 3
     ---> single-monitor keynote presentation probably here, higher than 4 <---
     NSModalPanelWindowLevel = 8
     NSMainMenuWindowLevel = 24
     NSStatusWindowLevel = 25
     NSPopUpMenuWindowLevel = 101
     NSScreenSaverWindowLevel = 1000
     */
    
    NSInteger windowLevel = [self usingSecondaryScreen] ? NSStatusWindowLevel : NSFloatingWindowLevel + 1;
    [self.window setLevel:windowLevel];
}

- (void)cancelOperation:(id)sender {
    if (self.keynote.presenting) [self.keynote stop];
    else {
        [self close];
        [NSApp setPresentationOptions:NSApplicationPresentationDefault];
    }
}


#pragma mark - NSWindowDelegate


- (void)windowWillClose:(NSNotification *)notification {
    [self.keynote stop];
    [self keynoteDidStopPresentation:nil];
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
	self.selectedPresentationIndex = index;
}


#pragma mark - Keynote Handler Delegate


-(void)didFinishStartingKeynote:(KeynoteHandler *)keynote {
    [self.presentationView mouseExited:nil];
    CALayer *oldHoveredLayer = [self presentationView:self.presentationView hoverLayerForItemAtIndex:self.selectedPresentationIndex];
	[self.presentationView addOverlay:oldHoveredLayer forItem:self.selectedPresentationIndex];
}

- (void)keynoteDidStopPresentation:(KeynoteHandler *)aKeynote {

    [self.presentationView mouseEntered:nil];
	self.presentationView.mouseTracking = YES;

 	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[self window] makeKeyAndOrderFront:nil];
}

- (void)keynoteAppDidLaunch:(BOOL)success version:(NSString *)version {
    // Do nothing
}

@end
