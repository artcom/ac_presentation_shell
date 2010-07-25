//
//  EditWindowController.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "EditWindowController.h"
#import "Presentation.h"

@implementation EditWindowController
@synthesize presentation;

- (id) init {
    self = [super initWithWindowNibName: @"PresentationEditWindow"];
    if (self != nil) {
    }
    return self;
}

- (void) edit: (Presentation*) aPresentation {
    NSLog(@"=== edit");
    self.presentation = aPresentation;
    [self.window makeKeyAndOrderFront: self];
}

@end
