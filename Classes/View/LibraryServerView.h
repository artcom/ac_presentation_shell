//
//  LibraryServerView.h
//  ACShell
//
//  Created by David Siegel on 8/2/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LibraryServerView : NSView {
    BOOL selected;
    NSTextField * titleField;
}

@property (readwrite) BOOL selected;

@property (retain, nonatomic) IBOutlet NSTextField * titleField;

@end
