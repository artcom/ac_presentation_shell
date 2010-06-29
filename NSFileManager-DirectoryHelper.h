//
//  NSFileManager-DirectoryHelper.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (DirectoryHelper)

- (NSString *)findSystemFolderType:(int)folderType forDomain:(int)domain;
- (NSString *)applicationSupportDirectoryInUserDomain;

@end
