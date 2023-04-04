//
//  FileDraglet.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "FileDraglet.h"

@implementation FileDraglet

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

- (BOOL) fileExists {
    if (self.filename == nil || self.filename.length == 0) {
        return NO;
    }
    return [NSFileManager.defaultManager fileExistsAtPath:self.filename isDirectory:nil];
}
@end
