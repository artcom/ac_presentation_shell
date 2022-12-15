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
    NSString *applicationSupportFolder = [self findSystemFolderType:kApplicationSupportFolderType forDomain:kUserDomain];
    NSString *myApplicationSupportFolder = [applicationSupportFolder stringByAppendingPathComponent:@"AC Shell"];
    
    if (![NSFileManager.defaultManager fileExistsAtPath:myApplicationSupportFolder]) {
        NSError *error = nil;
        [NSFileManager.defaultManager createDirectoryAtPath:myApplicationSupportFolder withIntermediateDirectories:NO attributes:nil error:&error];
        
        if (error != nil) {
            NSLog(@"error: %@", error);
        }
        
    }
    
    return myApplicationSupportFolder;
}

- (NSString *)findSystemFolderType:(int)folderType forDomain:(int)domain {
    FSRef folder;
    OSErr err = noErr;
    CFURLRef url;
    NSString *result = nil;
    
    err = FSFindFolder(domain, folderType, false, &folder);
    if (err == noErr) {
        url = CFURLCreateFromFSRef(kCFAllocatorDefault, &folder);
        result = [(__bridge NSURL *)url path];
        CFRelease(url);
    }
    
    return result;
}

@end
