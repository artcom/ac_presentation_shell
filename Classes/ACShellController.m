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
@synthesize syncWindow;
@synthesize progressSpinner;

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

- (IBAction)sync: (id)sender {
	[[NSApplication sharedApplication] beginSheet:syncWindow modalForWindow:[[NSApplication sharedApplication] mainWindow] modalDelegate:self didEndSelector:@selector(didEndModal) contextInfo:nil];
	[progressSpinner startAnimation:nil];
		
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/ls"];
	
    NSArray *arguments = [NSArray arrayWithObjects: @"-l", @"-a", @"-t", nil];
    [task setArguments: arguments];
	
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	
    NSFileHandle *file = [pipe fileHandleForReading];
	
    [task launch];
    [task waitUntilExit];
	
    NSData *data = [file readDataToEndOfFile];
	
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"got\n%@", string);
}

- (IBAction)abortSync: (id)sender {
	[progressSpinner stopAnimation:nil];
	[[NSApplication sharedApplication] endSheet:syncWindow];
}

- (void)didEndModal {
	[syncWindow orderOut:nil];
}

- (NSArray *)selectedPresentations {
	NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES"];
	return [[presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
}

@end
