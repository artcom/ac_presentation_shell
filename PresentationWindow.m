//
//  PresentationWindow.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PresentationWindow.h"

@implementation PresentationWindow

- (void)awakeFromNib {
	[self setStyleMask:NSBorderlessWindowMask];
	[self setLevel:NSStatusWindowLevel];
	
	[self makeFirstResponder:self];
}

- (BOOL) canBecomeKeyWindow {
	return YES;
}

- (void)cancelOperation:(id)sender {
	[self orderOut:nil];
}

@end