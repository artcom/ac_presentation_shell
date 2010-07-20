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
    initialTitle = [self.window.title retain];
    
    preferencePanels = [[NSArray arrayWithObjects: 
                        generalPreferences,
                        advancedPreferences,
                        nil] retain];
    
    emptyPanel = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 1, 1)];
    
    [self showPanel: 0];
}

- (void) dealloc {
    [preferencePanels release];
    [initialTitle release];
    
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
        
		self.window.contentView = emptyPanel;	
        NSRect newWindowFrame = NSMakeRect(self.window.frame.origin.x, self.window.frame.origin.y - delta,
                                     panel.frame.size.width, initialHeight + panel.frame.size.height);
        
		[[self window] setFrame:newWindowFrame display:YES animate:YES];
		self.window.contentView = [preferencePanels objectAtIndex: index];
	}
}

@end
