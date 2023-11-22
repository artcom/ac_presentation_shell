//
//  ACShellAppDelegate.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellAppDelegate.h"
#import "default_keys.h"
#import "localized_text_keys.h"
#import "NSFileManager-DirectoryHelper.h"
#import "NSOpenPanel+Preferences.h"


@implementation ACShellAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self registerUserDefaults];
    [self updateUserDefaults];

    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainWindowController = [storyboard instantiateControllerWithIdentifier:@"MainWindowController"];
    self.preferenceController = [PreferenceController new];
    [self.mainWindowController showWindow:nil];
    [self ensureStorageLocation];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [PresentationLibrary.sharedInstance saveSettings];
}

- (IBAction)showPreferences:(id)sender
{
    [self.preferenceController showWindow:nil];
}

- (void)registerUserDefaults
{
    NSString *filepath = [NSBundle.mainBundle pathForResource:@"defaults" ofType:@"plist"];
    NSMutableDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:filepath].mutableCopy;

    [NSUserDefaults.standardUserDefaults registerDefaults:defaults];
}

- (void)updateUserDefaults
{
    NSString *destination = [NSUserDefaults.standardUserDefaults objectForKey:ACSHELL_DEFAULT_KEY_STORAGE_LOCATION];

    if (!destination || [destination isEqualToString:@""]) {
        NSString *path = PresentationLibrary.libraryDirPath;
        [NSUserDefaults.standardUserDefaults synchronize];
        [NSUserDefaults.standardUserDefaults setObject:path forKey:ACSHELL_DEFAULT_KEY_STORAGE_LOCATION];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

- (void)ensureStorageLocation
{
    if (PresentationLibrary.libraryExistsAtPath == NO) {
        [self selectStorageLocation];
    }
}

- (void)selectStorageLocation
{
    NSAlert *alert = NSAlert.new;

    alert.messageText = NSLocalizedString(ACSHELL_STR_SELECT_STORAGE_LOCATION, nil);
    [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_SELECT, nil)];
    [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_CANCEL, nil)];
    alert.alertStyle = NSAlertStyleCritical;

    [alert beginSheetModalForWindow:self.mainWindowController.window
                  completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSOpenPanel *dialog = NSOpenPanel.new;

            [dialog selectStorageDirectory];
        }
    }];
}

@end
