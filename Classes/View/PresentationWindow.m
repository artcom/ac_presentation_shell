//
//  PresentationWindow.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PresentationWindow.h"

@implementation PresentationWindow

- (void)awakeFromNib {
	[self setStyleMask:NSBorderlessWindowMask];
	[self setLevel:NSStatusWindowLevel];
	
	[self setAcceptsMouseMovedEvents:YES];
	[self makeFirstResponder:self];
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (void)cancelOperation:(id)sender {
	[self orderOut:nil];
	[NSApp setPresentationOptions:NSApplicationPresentationDefault];
}

@end