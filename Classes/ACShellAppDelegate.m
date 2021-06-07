//
//  ACShellAppDelegate.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellAppDelegate.h"
#import "NSFileManager-DirectoryHelper.h"
#import "ACShellController.h"


@implementation ACShellAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
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
