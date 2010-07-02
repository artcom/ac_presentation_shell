//
//  PresentationWindow.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "PresentationWindow.h"
#import "PaginationView.h"

@implementation PresentationWindow

@synthesize paginationView;


- (void)awakeFromNib {
	[self setStyleMask:NSBorderlessWindowMask];
	[self setLevel:NSStatusWindowLevel];
	
	[self makeFirstResponder:self];
}

- (BOOL) canBecomeKeyWindow {
	return YES;
}

-(void)moveUp:(id)sender {
	paginationView.activePage -= 1;
}

- (void)moveDown:(id)sender {
	paginationView.activePage += 1;
}

- (void)cancelOperation:(id)sender {
	[self orderOut:nil];
	[NSApp setPresentationOptions:NSApplicationPresentationDefault];
}

@end