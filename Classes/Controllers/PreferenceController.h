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
}

@property (strong, nonatomic) IBOutlet NSView* generalPreferences;
@property (strong, nonatomic) IBOutlet NSView* advancedPreferences;
@property (weak, nonatomic) IBOutlet NSButtonCell* showEditWindowOption;

- (IBAction) showWindow: (id) sender;
- (IBAction)changeDestination:(id)sender;

@end
