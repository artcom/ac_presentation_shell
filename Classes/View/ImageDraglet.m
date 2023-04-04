//
//  ImageDraglet.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ImageDraglet.h"

@implementation ImageDraglet
@synthesize filename;

- (BOOL)performDragOperation:(id )sender {
    if (![super performDragOperation:sender] ) {
        return NO;
    }
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ( [pasteboard.types containsObject:NSPasteboardTypeFileURL] ) {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];
        filename = url.path;
        return YES;
    }
    return NO;
}

-(void) setFilename: (NSString*) aFilename {
    if (filename != aFilename) {
        filename = aFilename;
    }
    NSImage *iconImage = nil;
    if (filename != nil) {
        if ([NSFileManager.defaultManager fileExistsAtPath: aFilename]) {
            iconImage = [[NSImage alloc] initByReferencingFile: aFilename];
        } else {
            iconImage = [NSImage imageNamed: @"icn_missing_file"];
        }
    }
    [self setImage: iconImage];
}


- (BOOL) fileExists {
    if (self.filename == nil || self.filename.length == 0) {
        return NO;
    }
    return [NSFileManager.defaultManager fileExistsAtPath:self.filename isDirectory:nil];
}
@end
