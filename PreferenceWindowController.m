//
//  PreferenceWindowController.m
//  ACShell
//
//  Created by David Siegel on 7/18/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PreferenceWindowController.h"

@interface PreferenceWindowController () 

- (void) showPanel: (unsigned) index;

@end


@implementation PreferenceWindowController

@synthesize advancedPreferences;
@synthesize generalPreferences;
@synthesize toolbar;

- (id)init {
    self = [super initWithWindowNibName: @"PreferenceWindow"];
    if (self != nil) {
        currentPanelIndex = -1;
    }
    return self;
}

-(void)awakeFromNib {
    static const int ibWindowHeight = 20;
    initialHeight = self.window.frame.size.height - ibWindowHeight;
    
    preferencePanels = [[NSArray arrayWithObjects: 
                        generalPreferences,
                        advancedPreferences,
                        nil] retain];
    
    emptyPanel = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 1, 1)];
    
    [self showPanel: 0];
}

- (void) dealloc {
    [preferencePanels release];
    
    [super dealloc];
}

- (IBAction) showPrefs: (id) sender {
    [self showPanel: [sender tag]];
}

- (void) showPanel: (unsigned) index {
    currentPanelIndex = index;
    NSView * panel = [preferencePanels objectAtIndex: index];
    if (panel != self.window.contentView) {
        NSView * oldPanel = self.window.contentView;
        float delta = panel.frame.size.height - oldPanel.frame.size.height;
        
        
        NSRect newWindowFrame = NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y - delta,
                                     panel.frame.size.width, initialHeight + panel.frame.size.height);
        self.window.contentView = emptyPanel;
        
        NSDictionary *windowResize = [NSDictionary dictionaryWithObjectsAndKeys:
                        self.window, NSViewAnimationTargetKey,
                        [NSValue valueWithRect: newWindowFrame],
                        NSViewAnimationEndFrameKey,
                        nil];
        NSArray * animations = [NSArray arrayWithObject: windowResize];
        NSViewAnimation * anim = [[NSViewAnimation alloc] initWithViewAnimations: animations];
        [anim setDelegate: self];
        [anim startAnimation];
        //[self.window setFrame: newWindowFrame display: YES animate: YES];
    }
}

- (void) animationDidEnd:(NSAnimation*) anim {
    NSLog(@"anim done");
    if (currentPanelIndex < 0) {
        self.window.contentView = nil;
    } else {
        [self.window setContentView: [preferencePanels objectAtIndex: currentPanelIndex]];
    }
}

- (NSString*) windowTitleForDocumentDisplayName: (NSString *) displayName {
    if (currentPanelIndex < 0) {
        return self.window.title;
    } else {
        return [[[toolbar items] objectAtIndex: currentPanelIndex] label];
    }
}

@end
