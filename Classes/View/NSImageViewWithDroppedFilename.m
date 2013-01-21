//
//  NSImageViewWithDroppedFilename.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "NSImageViewWithDroppedFilename.h"


@implementation NSImageViewWithDroppedFilename
@synthesize filename;

- (void)dealloc
{
    [filename release];
    [super dealloc];
}

- (BOOL)performDragOperation:(id )sender {
    if ( ! [super performDragOperation:sender] ) {
        return NO;
    }
    NSPasteboard * pasteboard = [sender draggingPasteboard];
    if ( [[pasteboard types] containsObject: NSFilenamesPboardType] ) {
        NSArray *filenames = [pasteboard propertyListForType:NSFilenamesPboardType];
        if ([filenames count] >= 1) {
            filename = [filenames objectAtIndex:0];
        } else {
            filename = nil;   
        }
        return YES;
    }
    return NO;
}

-(void) setFilename: (NSString*) aFilename {
    if (filename != aFilename) {
        [filename release];
        filename = [aFilename retain];
    }
    NSImage *iconImage = nil;
    if (filename != nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath: aFilename]) {
            iconImage = [[[NSImage alloc] initByReferencingFile: aFilename] autorelease];
        } else {
            iconImage = [NSImage imageNamed: @"icn_missing_file"];
        }
    }
    [self setImage: iconImage];
}

- (BOOL) fileExists {
    return [[NSFileManager defaultManager] fileExistsAtPath: self.filename];
}
@end
