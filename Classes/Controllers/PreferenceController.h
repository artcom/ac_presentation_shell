//
//  PreferenceController.h
//  ACShell
//
//  Created by David Siegel on 8/22/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ACPreferenceWindowController;

@interface PreferenceController : NSObject {
    ACPreferenceWindowController * windowController;
    NSView * generalPreferences;
    NSView * advancedPreferences;
}

@property (retain, nonatomic) IBOutlet NSView* generalPreferences;
@property (retain, nonatomic) IBOutlet NSView* advancedPreferences;


- (IBAction) showWindow: (id) sender;

@end
