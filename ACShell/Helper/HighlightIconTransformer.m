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
        highlightIcon =  [NSImage imageWithSystemSymbolName:@"star.fill" accessibilityDescription:nil];
    }
    return highlightIcon; 
}

+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue: (id) value {
    return (value != nil && [value boolValue]) ? [HighlightIconTransformer icon] : nil; 
}

@end
