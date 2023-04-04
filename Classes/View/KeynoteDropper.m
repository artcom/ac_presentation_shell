//
//  KeynoteDropper.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "KeynoteDropper.h"

@implementation KeynoteDropper

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ( [pasteboard.types containsObject:NSPasteboardTypeFileURL] ) {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];
        if ([url.path.pathExtension isEqual: @"key"]) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    BOOL dropped = [super performDragOperation:sender];
    if (dropped) [self.delegate userDidDropKeynote:self];
    return dropped;
}

- (void)mouseDown:(NSEvent *)event {
    if (event.clickCount == 2) {
        [self.delegate userDidDoubleClickKeynote:self];
    }
}

@end
