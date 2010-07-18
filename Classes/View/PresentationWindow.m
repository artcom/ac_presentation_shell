//
//  PresentationWindow.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "PresentationWindow.h"
#import "PaginationView.h"
#import "GridView.h"

@implementation PresentationWindow

@synthesize paginationView;
@synthesize gridView;

- (void)awakeFromNib {
	[self setStyleMask:NSBorderlessWindowMask];
	[self setLevel:NSStatusWindowLevel];
	
	[self setAcceptsMouseMovedEvents:YES];
	[self makeFirstResponder:self];
}

- (void)dealloc {
	[gridView release];
	[paginationView release];
	
	[super dealloc];
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (void)moveUp:(id)sender {
	if ([gridView hasPreviousPage]) {
		gridView.page -= 1;
	}
}

- (void)moveDown:(id)sender {
	if ([gridView hasNextPage]) {
		gridView.page += 1;	
	}
}

- (void)cancelOperation:(id)sender {
	[self orderOut:nil];
	[NSApp setPresentationOptions:NSApplicationPresentationDefault];
}

- (void) setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animateFlag {
	[super setFrame:frameRect display:displayFlag animate:animateFlag];
}

@end