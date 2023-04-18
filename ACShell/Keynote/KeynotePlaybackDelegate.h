//
//  KeynoteDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 14.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class KeynoteHandler;
@protocol KeynotePlaybackDelegate <NSObject>
- (void)keynoteDidStartPresentation:(KeynoteHandler *)keynote;
- (void)keynoteDidStopPresentation:(KeynoteHandler *)keynote;
@end

NS_ASSUME_NONNULL_END
