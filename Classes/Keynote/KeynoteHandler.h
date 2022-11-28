//
//  KeynoteHandler.h
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Keynote.h"
#import "KeynoteDelegate.h"

@interface KeynoteHandler : NSObject

@property (atomic, strong, readonly) KeynoteApplication *application;
@property (atomic, assign, readonly) BOOL presenting;

+ (KeynoteHandler *)sharedHandler;

- (void)launchWithDelegate: (id<KeynoteDelegate>) delegate;
- (void)open:(NSString *)file;

- (void)play:(NSString *)file withDelegate: (id<KeynoteDelegate>) delegate;
- (void)stop;
@end
