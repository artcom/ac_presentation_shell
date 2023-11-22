//
//  NSOpenPanel+Preferences.h
//  ACShell
//
//  Created by Julian Krumow on 11.10.23.
//  Copyright © 2023 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSOpenPanel (Preferences)
- (void)selectStorageDirectory;
@end

NS_ASSUME_NONNULL_END
