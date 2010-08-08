//
//  KeynoteDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KeynoteHandler;

@protocol KeynoteDelegate <NSObject>

@optional
- (void)didFinishStartingKeynote: (KeynoteHandler *)keynote;
- (void)keynoteDidStopPresentation: (KeynoteHandler *)keynote;

- (void) keynoteAppDidLaunch: (BOOL) success;

@end
