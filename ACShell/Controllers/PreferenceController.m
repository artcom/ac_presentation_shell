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
#import "NSOpenPanel+Preferences.h"
#import "default_keys.h"
#import "localized_text_keys.h"

@implementation PreferenceController
@synthesize generalPreferences;
@synthesize advancedPreferences;
@synthesize showEditWindowOption;

- (id) init {
    self = [super init];
    if (self != nil) {
        [NSBundle.mainBundle loadNibNamed:@"PreferencePages" owner:self topLevelObjects:nil];
    }
    return self;
}


- (void) awakeFromNib {
    ACPreferencePage * generalPrefs = [[ACPreferencePage alloc] initWithView: generalPreferences
                                                                       title: NSLocalizedString(ACSHELL_STR_GENERAL, nil)
                                                                    iconName: @"gearshape"];
    ACPreferencePage * advancedPrefs = [[ACPreferencePage alloc] initWithView:advancedPreferences
                                                                        title: NSLocalizedString(ACSHELL_STR_ADVANCED, nil)
                                                                     iconName: @"gearshape.2"];
    NSArray * preferencePages = [NSArray arrayWithObjects: generalPrefs, advancedPrefs, nil];
    windowController = [[ACPreferenceWindowController alloc] initWithPages: preferencePages];
}

- (IBAction) showWindow: (id) sender {
    [showEditWindowOption setEnabled: [NSUserDefaults.standardUserDefaults boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED]];
    [windowController showWindow: sender];
}

- (IBAction)changeDestination:(id)sender {
    NSOpenPanel *dialog = NSOpenPanel.new;
    [dialog selectStorageDirectory];
}

@end
