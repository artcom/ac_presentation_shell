//
//  KeynoteDropper.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "KeynoteDropper.h"

@implementation KeynoteDropper
@synthesize filename;

- (void) setFilename: (NSString*) aFilename {
    if (filename != aFilename) {
        filename = aFilename;
    }
    NSImage *iconImage = nil;
    if (filename != nil) {
        iconImage = [[NSWorkspace sharedWorkspace] iconForFile: aFilename];
        [iconImage setSize:NSMakeSize(64,64)];
        if ( ! [NSFileManager.defaultManager fileExistsAtPath: aFilename isDirectory: nil]) {
            iconImage = [NSImage imageNamed: @"icn_missing_file"];
        }
    }
    [self setImage: iconImage];
}

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
    if (![super performDragOperation:sender] ) {
        return NO;
    }
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ( [pasteboard.types containsObject:NSPasteboardTypeFileURL] ) {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];
        self.filename = url.path;
        [self.delegate userDidDropKeynote:self];
        return YES;
    }
    return NO;
}

- (void)mouseDown:(NSEvent *)event {
    if (event.clickCount == 2) {
        [self.delegate userDidDoubleClickKeynote:self];
    }
}

- (BOOL) fileExists {
    if (self.filename == nil || self.filename.length == 0) {
        return NO;
    }
    return [NSFileManager.defaultManager fileExistsAtPath:self.filename isDirectory:nil];
}

@end
