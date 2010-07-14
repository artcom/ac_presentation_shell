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

@synthesize window;
@synthesize mainView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
	return YES;
}

@end
