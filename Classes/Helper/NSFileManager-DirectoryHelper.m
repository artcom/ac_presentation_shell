//
//  NSFileManager-DirectoryHelper.m
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "NSFileManager-DirectoryHelper.h"


@implementation NSFileManager (DirectoryHelper)

- (NSString *)applicationSupportDirectoryInUserDomain {
    
    NSURL *applicationSupportDirectory = [NSFileManager.defaultManager URLForDirectory:NSApplicationSupportDirectory
                                                                              inDomain:NSUserDomainMask
                                                                     appropriateForURL:nil
                                                                                create:YES
                                                                                 error:NULL];
    
    NSURL *acShellSupportDirectory = [applicationSupportDirectory URLByAppendingPathComponent:@"AC Shell"];
    NSString *path = acShellSupportDirectory.path;
    
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        NSError *error = nil;
        [NSFileManager.defaultManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error != nil) {
            NSLog(@"error: %@", error);
        }
    }
    return path;
}

@end
