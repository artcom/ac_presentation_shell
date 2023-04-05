//
//  NSFileManager-DirectoryHelper.h
//  ACShell
//
//  Created by Robert Palmer on 29.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (DirectoryHelper)
- (NSString *)applicationSupportDirectoryInUserDomain;
@end
