//
//  KeynoteDropper.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "KeynoteDropper.h"


@implementation KeynoteDropper

-(NSString*) filename {
    return filename;
}

-(void) setFilename: (NSString*) aFilename {
    filename = [aFilename retain];
    if (filename == nil) {
        return;
    }
    NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile: aFilename];
	[iconImage setSize:NSMakeSize(64,64)];
    self.image = iconImage;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSLog(@"dragging entered");
    NSPasteboard *pasteboard = [sender draggingPasteboard];
//    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
 
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
    if ( ! [super performDragOperation: sender]) {
        return NO;
    }
    NSPasteboard *pasteboard = [sender draggingPasteboard];
 //   NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
    if ( [[pasteboard types] containsObject: NSFilenamesPboardType] ) {
        NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
        
        self.filename = [files objectAtIndex: 0];
        [self sendAction: self.action to: self.target];
        return YES;
    }
    return NO;
}
@end
