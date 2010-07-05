//
//  PresentationView.m
//  ACShell
//
//  Created by Robert Palmer on 05.07.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PresentationView.h"


@implementation PresentationView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor whiteColor] set];
	NSRectFill(dirtyRect);
}

@end
