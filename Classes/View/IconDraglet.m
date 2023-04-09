//
//  IconDraglet.m
//  ACShell
//
//  Created by David Siegel on 8/2/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "IconDraglet.h"

@implementation IconDraglet
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

- (BOOL)performDragOperation:(id )sender {
    if (![super performDragOperation:sender] ) {
        return NO;
    }
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ( [pasteboard.types containsObject:NSPasteboardTypeFileURL] ) {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];
        self.filename = url.path;
        return YES;
    }
    return NO;
}

- (void) mouseDown:(NSEvent *)theEvent {
    [super mouseDown: theEvent];
    NSRect f;
    f.size.width = f.size.height = 32;
    f.origin = [self convertPoint:theEvent.locationInWindow fromView:nil];
    f.origin.x -= 16;
    f.origin.y -= 16;
    [self dragFile:self.filename fromRect: f slideBack: YES event: theEvent];
}

@end
