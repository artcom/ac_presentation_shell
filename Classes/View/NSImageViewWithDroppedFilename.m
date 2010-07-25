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
    NSString *filenamesXML = [[sender draggingPasteboard] stringForType:NSFilenamesPboardType];
    if (filenamesXML) {
        NSArray *filenames = [NSPropertyListSerialization
                              propertyListFromData:[filenamesXML dataUsingEncoding:NSUTF8StringEncoding]
                              mutabilityOption:NSPropertyListImmutable
                              format:nil
                              errorDescription:nil];
        if ([filenames count] >= 1) {
            filename = [filenames objectAtIndex:0];
        } else {
            filename = nil;   
        }
    }
    return YES;
}
@end
