//
//  BooleanToImageTransformer.m
//  ACShell
//
//  Created by David Siegel on 7/18/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "HighlightIconTransformer.h"


static NSImage * highlightIcon = nil;

@implementation HighlightIconTransformer

+ (NSImage*) icon {
    if (highlightIcon == nil) {
        NSString* filepath = [[NSBundle mainBundle] pathForResource:@"icn_highlight" ofType:@"png"];
        highlightIcon =  [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filepath]];
    }
    return highlightIcon; 
}

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue: (id) value {
    return (value != nil && [value boolValue]) ? [HighlightIconTransformer icon] : nil; 
}

@end
