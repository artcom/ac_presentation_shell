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
	NSTimer *keynotePollTimer;
	id <KeynoteDelegate> delegate;
}

@property (retain) id <KeynoteDelegate> delegate;

- (void)open: (NSString *)file;

@end
