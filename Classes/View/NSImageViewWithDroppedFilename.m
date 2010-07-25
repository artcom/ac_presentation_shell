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
@end
