//
//  PreferenceController.m
//  ACShell
//
//  Created by David Siegel on 8/22/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PreferenceController.h"

#import "ACPreferenceWindowController.h"
#import "ACPreferencePage.h"

@implementation PreferenceController
@synthesize generalPreferences;
@synthesize advancedPreferences;

- (id) init {
    self = [super init];
    if (self != nil) {
        [NSBundle loadNibNamed: @"PreferencePages" owner: self];
    }
    return self;
}

- (void) awakeFromNib {
    NSLog(@"awake");
    
    ACPreferencePage * generalPrefs = [[ACPreferencePage alloc] initWithView: generalPreferences
                                                                       title: @"General"
                                                                    iconName: NSImageNamePreferencesGeneral];
    ACPreferencePage * advancedPrefs = [[ACPreferencePage alloc] initWithView:advancedPreferences
                                                                       title: @"Advanced"
                                                                    iconName: NSImageNameAdvanced];
    NSArray * preferencePages = [NSArray arrayWithObjects: generalPrefs, advancedPrefs, nil];
    windowController = [[ACPreferenceWindowController alloc] initWithPages: preferencePages];
    
}

- (IBAction) showWindow: (id) sender {
    [windowController showWindow: sender];
}

@end
