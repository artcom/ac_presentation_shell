//
//  ACShellAppDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferenceController.h"
#import "ACShellWindowController.h"
#import "MHWDirectoryWatcher.h"

@interface ACShellAppDelegate : NSObject <NSApplicationDelegate>
@property (strong) ACShellWindowController *mainWindowController;
@property (strong) PreferenceController *preferenceController;
@property (assign) BOOL isStartup;
@property (strong) MHWDirectoryWatcher *libraryWatcher;

- (IBAction)showPreferences:(id)sender;
@end
