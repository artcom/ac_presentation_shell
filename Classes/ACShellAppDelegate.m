//
//  ACShellAppDelegate.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellAppDelegate.h"
#import "NSFileManager-DirectoryHelper.h"


@implementation ACShellAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
    [[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile: filepath]];
    self.preferenceController = [[PreferenceController alloc] init];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void) applicationWillTerminate:(NSNotification *)notification {
    [[PresentationLibrary sharedInstance] saveSettings];
}

- (IBAction)showPreferences:(id)sender {
    [self.preferenceController showWindow:nil];
}

@end
