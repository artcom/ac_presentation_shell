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
#import "NSFileManager-DirectoryHelper.h"

@interface ACShellController ()

- (void)performRsync;
- (void)updatePresentationLists;

@end


@implementation ACShellController
@synthesize presentations;
@synthesize categories;
@synthesize presentationsArrayController;
@synthesize syncWindow;
@synthesize progressSpinner;

- (id) init {
	self = [super init];
	if (self != nil) {		
		presentationWindowController = [[PresentationWindowController alloc] init];

		[self updatePresentationLists];
	}
	
	return self;
}

- (void)updatePresentationLists {
	PresentationContext *context = [[PresentationContext alloc] init];
	self.presentations = [context allPresentations];
	
	NSMutableArray *staticCategories = [NSMutableArray array];
	[staticCategories addObject: [Playlist playlistWithName:@"All" presentations:[context allPresentations] children:nil]];
	[staticCategories addObject: [Playlist playlistWithName:@"Highlight" presentations:[context highlights] children:nil]];
	
	Playlist *object = [Playlist playlistWithName:@"Library" presentations:nil children:staticCategories];
	self.categories = [[NSMutableArray arrayWithObject:object] retain];
	
	[context release];
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
		
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self performRsync];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self updatePresentationLists];
			[self abortSync:nil];
		});
	});
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


#pragma mark -
#pragma mark Private Methods
- (void)performRsync {
	NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/opt/local/bin/rsync"];
	NSString *libraryPath = [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"library"];
	[task setArguments: [NSArray arrayWithObjects: @"-avz", @"/Volumes/kommunikation/extern/Praesentationen/presentationtest/", libraryPath, nil]];
	
	NSPipe *pipe = [NSPipe pipe];
	[task setStandardOutput: pipe];
	
	[task launch];
    [task waitUntilExit];
	
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data = [file readDataToEndOfFile];
	
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"got\n%@", string);	
}

@end
