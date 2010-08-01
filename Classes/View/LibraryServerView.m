//
//  LibraryServerView.m
//  ACShell
//
//  Created by David Siegel on 8/2/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "LibraryServerView.h"


@implementation LibraryServerView
@synthesize selected;
@synthesize titleField;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        selected = NO;
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    NSLog(@"====LibraryServerView awake %@", titleField);
    [[titleField cell] setBackgroundStyle: NSBackgroundStyleRaised]; // hmmmm
}

- (void)drawRect:(NSRect)dirtyRect {
    if (selected) {
        [[NSColor controlColor] set];
        NSRectFill([self bounds]);
    }
    [super drawRect: dirtyRect];
}

@end
