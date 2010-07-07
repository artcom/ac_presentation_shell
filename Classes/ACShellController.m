//
//  ACShellController.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ACShellController.h"
#import "Presentation.h"
#import "PresentationContext.h"
#import "PresentationWindowController.h"
#import "Playlist.h"

@implementation ACShellController
@synthesize presentations;
@synthesize presentationsArrayController;

- (id) init {
	self = [super init];
	if (self != nil) {		
		PresentationContext *context = [[PresentationContext alloc] init];
		self.presentations = [context allPresentations];
		
		presentationWindowController = [[PresentationWindowController alloc] init];

		NSMutableArray *staticCategories = [NSMutableArray array];
		[staticCategories addObject: [Playlist playlistWithName:@"All" presentations:[context allPresentations] children:nil]];
		[staticCategories addObject: [Playlist playlistWithName:@"Highlight" presentations:[context highlights] children:nil]];

		Playlist *object = [Playlist playlistWithName:@"Library" presentations:nil children:staticCategories];
		categories = [[NSMutableArray arrayWithObject:object] retain];
		
		[context release];
	}
	
	return self;
}

- (void) dealloc {
	[categories release];
	[presentations release];
	[presentationWindowController release];

	[super dealloc];
}


- (IBAction)play: (id)sender {	
	presentationWindowController.presentations = [self selectedPresentations];
	[presentationWindowController showWindow:nil];
}


- (NSArray *)selectedPresentations {
	NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES"];
	return [[presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
}



@end
