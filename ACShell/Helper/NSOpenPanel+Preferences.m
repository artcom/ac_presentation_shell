//
//  NSOpenPanel+Preferences.m
//  ACShell
//
//  Created by Julian Krumow on 11.10.23.
//  Copyright © 2023 ART+COM AG. All rights reserved.
//

#import "default_keys.h"
#import "NSOpenPanel+Preferences.h"

@implementation NSOpenPanel (Preferences)

- (void)selectStorageDirectory
{
    self.showsResizeIndicator = YES;
    self.showsHiddenFiles = YES;
    self.allowsMultipleSelection = NO;
    self.canChooseFiles = NO;
    self.canChooseDirectories = YES;

    if ([self runModal] ==  NSModalResponseOK) {
        NSString *path = self.URL.path;
        if (path != nil) {
            [NSUserDefaults.standardUserDefaults synchronize];
            [NSUserDefaults.standardUserDefaults setObject:path forKey:ACSHELL_DEFAULT_KEY_STORAGE_LOCATION];
            [NSUserDefaults.standardUserDefaults synchronize];
            [NSNotificationCenter.defaultCenter postNotificationName:ACShellLibraryConfigDidChange object:nil];
        }
    }
}

@end
