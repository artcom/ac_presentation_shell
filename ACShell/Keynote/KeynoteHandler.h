//
//  KeynoteHandler.h
//  ACShell
//
//  Created by Robert Palmer on 30.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Keynote.h"
#import "KeynoteLaunchDelegate.h"
#import "KeynotePlaybackDelegate.h"

@interface KeynoteHandler : NSObject

@property (atomic, strong, readonly) KeynoteApplication *application;
@property (atomic, assign, readonly) BOOL presenting;
@property (nonatomic, weak) id<KeynotePlaybackDelegate> delegate;
@property (nonatomic, weak) id<KeynoteLaunchDelegate> launchDelegate;

+ (KeynoteHandler *)sharedHandler;

- (void)launch;
- (void)open:(NSString *)file;

- (void)play:(NSString *)file withDelegate:(id<KeynotePlaybackDelegate>)delegate;
- (void)stop;
@end
