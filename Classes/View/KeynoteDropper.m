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


-(void) setFilename: (NSString*) aFilename {
    if (filename != aFilename) {
        filename = aFilename;
    }
    NSImage *iconImage = nil;
    if (filename != nil) {
        iconImage = [[NSWorkspace sharedWorkspace] iconForFile: aFilename];
        [iconImage setSize:NSMakeSize(64,64)];
        if ( ! [[NSFileManager defaultManager] fileExistsAtPath: aFilename isDirectory: nil]) {
            iconImage = [NSImage imageNamed: @"icn_missing_file"];
        }
    }
    [self setImage: iconImage];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
 
    if ( [[pasteboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *filenames = [pasteboard propertyListForType: NSFilenamesPboardType];
        NSString * draggedFile = nil;
        if ([filenames count] >= 1) {
            draggedFile = [filenames objectAtIndex:0];
        }
        if ([[draggedFile pathExtension] isEqual: @"key"]) {
            return NSDragOperationCopy;
        } 
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ( [[pasteboard types] containsObject: NSFilenamesPboardType] ) {
        NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
        
        self.filename = [files objectAtIndex: 0];
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
    if (filename == nil || [filename length] == 0) {
        return NO;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath: filename isDirectory: nil];
}

@end
