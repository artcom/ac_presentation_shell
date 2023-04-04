//
//  KeynoteDropper.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileDraglet.h"

@protocol KeynoteDropperDelegate;
@interface KeynoteDropper : FileDraglet
@property (nonatomic, weak) IBOutlet id<KeynoteDropperDelegate> delegate;
@end

@protocol KeynoteDropperDelegate
- (void) userDidDropKeynote: (KeynoteDropper *)keynoteDropper;
- (void) userDidDoubleClickKeynote: (KeynoteDropper *)keynoteDropper;
@end
