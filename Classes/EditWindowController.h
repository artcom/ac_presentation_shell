//
//  EditWindowController.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Presentation;

@interface EditWindowController : NSWindowController {
    Presentation * presentation;
}

@property (retain, nonatomic) Presentation * presentation;

- (void) edit: (Presentation*) presentation;
@end
