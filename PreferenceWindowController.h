//
//  PreferenceWindowController.h
//  ACShell
//
//  Created by David Siegel on 7/18/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferenceWindowController : NSWindowController <NSAnimationDelegate> {
    NSView * generalPreferences;
    NSView * advancedPreferences;
    
    NSArray * preferencePanels;
    
    NSView * emptyPanel;
    
    NSToolbar * toolbar;
    
    int currentPanelIndex;
    int initialHeight;
    int initialY;
}

@property (retain) IBOutlet NSView * advancedPreferences;
@property (retain) IBOutlet NSView * generalPreferences;
@property (retain) IBOutlet NSToolbar * toolbar;

- (IBAction) showPrefs: (id) sender;


@end
