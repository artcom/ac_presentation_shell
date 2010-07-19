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
#import "PresentationLibrary.h"

@implementation ACShellAppDelegate

@synthesize shellController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"UP");
    [shellController load];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

- (void) applicationWillTerminate:(NSNotification *)notification {
	[shellController.presentationContext saveSettings];
}

@end
