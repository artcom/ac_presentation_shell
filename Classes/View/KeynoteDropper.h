//
//  KeynoteDropper.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IconDraglet.h"

@protocol KeynoteDropperDelegate;
@interface KeynoteDropper : IconDraglet
@property (nonatomic, weak) IBOutlet id<KeynoteDropperDelegate> delegate;
@property (readonly) BOOL fileExists;
@end

@protocol KeynoteDropperDelegate
- (void) userDidDropKeynote: (KeynoteDropper *)keynoteDraglet;
- (void) userDidDoubleClickKeynote: (KeynoteDropper *)keynoteDraglet;
@end
