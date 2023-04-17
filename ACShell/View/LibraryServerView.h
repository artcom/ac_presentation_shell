//
//  LibraryServerView.h
//  ACShell
//
//  Created by David Siegel on 8/2/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LibraryServerView : NSView

@property (assign) BOOL selected;

@property (weak, nonatomic) IBOutlet NSTextField * titleField;

@end
