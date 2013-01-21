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

@interface KeynoteHandler : NSObject {
	KeynoteApplication *application;
}

@property (nonatomic, retain) KeynoteApplication *application;

+ (KeynoteHandler *)sharedHandler;

- (void) launchWithDelgate: (id<KeynoteDelegate>) delegate;

- (void)play: (NSString *)file withDelegate: (id<KeynoteDelegate>) delegate;
- (void)open: (NSString *)file;

- (BOOL)usesSecondaryMonitorForPresentation;

@end
