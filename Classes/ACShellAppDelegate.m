//
//  ACShellAppDelegate.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellAppDelegate.h"
#import "NSFileManager-DirectoryHelper.h"
#import "default_keys.h"


@implementation ACShellAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString * filepath = [NSBundle.mainBundle pathForResource: @"defaults" ofType: @"plist"];
    NSMutableDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile: filepath].mutableCopy;
    [NSUserDefaults.standardUserDefaults registerDefaults: defaults];
    
    [self updateUserDefaults];
    
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainWindowController = [storyboard instantiateControllerWithIdentifier:@"MainWindowController"];
    self.setupAssistantController = [[SetupAssistantController alloc] initWithDelegate: self];
    self.preferenceController = [PreferenceController new];
    
    if ([NSUserDefaults.standardUserDefaults boolForKey:ACSHELL_DEFAULT_KEY_SETUP_DONE]) {
        [self updateUserDefaults];
        [self.mainWindowController showWindow:nil];
    } else {
        [self.setupAssistantController showWindow:nil];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (!self.isStartup) {
        [self.mainWindowController start];
        self.isStartup = YES;
    }
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
    [[PresentationLibrary sharedInstance] saveSettings];
}

- (IBAction)showPreferences:(id)sender
{
    [self.preferenceController showWindow:nil];
}

- (void)updateUserDefaults
{
    NSString * source = [NSUserDefaults.standardUserDefaults objectForKey:ACSHELL_DEFAULT_KEY_RSYNC_SOURCE];
    if (source && ![source isEqualToString:@""]) {
        NSString *path = PresentationLibrary.libraryDirPath;
        [NSUserDefaults.standardUserDefaults synchronize];
        [NSUserDefaults.standardUserDefaults setObject:path forKey:ACSHELL_DEFAULT_KEY_RSYNC_DESTINATION];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    
}

#pragma mark -
#pragma mark SetupAssistantDelegate Protocol Methods

- (void) setupDidFinish: (id) sender
{
    [NSUserDefaults.standardUserDefaults setBool: YES forKey: ACSHELL_DEFAULT_KEY_SETUP_DONE];
    [self updateUserDefaults];
    [self.setupAssistantController close];
    [self.mainWindowController showWindow:nil];
    [self.mainWindowController.window makeKeyWindow];
    [self.mainWindowController start];
}

@end
