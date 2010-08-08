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
    
    id<KeynoteDelegate> delegate;
}

@property (assign) id<KeynoteDelegate> delegate;

+ (KeynoteHandler *)sharedHandler;

- (void) launch;

- (void)play: (NSString *)file;
- (void)open: (NSString *)file;

- (BOOL)usesSecondaryMonitorForPresentation;

@end
