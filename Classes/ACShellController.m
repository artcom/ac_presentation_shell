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
- (void)didFinishSyncing;
- (void)beautifyOutlineView;

@end



@implementation ACShellController
@synthesize presentationContext;
@synthesize presentations;
@synthesize categories;
@synthesize presentationsArrayController;
@synthesize syncWindow;
@synthesize progressSpinner;
@synthesize playlistView;



- (id) init {
	self = [super init];
	if (self != nil) {		
		presentationWindowController = [[PresentationWindowController alloc] init];

	}
	
	return self;
}

- (void) awakeFromNib {
	[self updatePresentationLists];
}


- (void)updatePresentationLists {
	NSLog(@"%s", _cmd);
	self.presentationContext = [[[PresentationContext alloc] init] autorelease];

	self.presentations = [presentationContext allPresentations];
	
	NSMutableArray *staticCategories = [NSMutableArray array];
	[staticCategories addObject: [Playlist playlistWithName:@"All" presentations:[presentationContext allPresentations] children:nil]];
	[staticCategories addObject: [Playlist playlistWithName:@"Highlight" presentations:[presentationContext highlights] children:nil]];
	
	Playlist *object = [Playlist playlistWithName:@"Library" presentations:nil children:staticCategories];
	self.categories = [[NSMutableArray arrayWithObject:object] retain];
	
	[self beautifyOutlineView];
}

- (void) dealloc {
	[categories release];
	[presentations release];
	[presentationWindowController release];
	[presentationContext release];
	[playlistView release];
	
	[super dealloc];
}


- (IBAction)play: (id)sender {	
	presentationWindowController.presentations = [self selectedPresentations];
	[presentationWindowController showWindow:nil];
}

- (IBAction)sync: (id)sender {
	[self.presentationContext save];
	[[NSApplication sharedApplication] beginSheet:syncWindow modalForWindow:[[NSApplication sharedApplication] mainWindow] 
									modalDelegate:self didEndSelector:@selector(didEndModal) contextInfo:nil];
	[progressSpinner startAnimation:nil];
		
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self performRsync];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self updatePresentationLists];
			[self didFinishSyncing];
		});
	});
}

- (IBAction)abortSync: (id)sender {
	[rsyncTask terminate];
		
	[self didFinishSyncing];
}



- (void)didEndModal {
	[syncWindow orderOut:nil];
}

- (NSArray *)selectedPresentations {
	NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES"];
	return [[presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	Playlist *playlist = (Playlist *)[item representedObject];
	return playlist.children == nil;
}


#pragma mark -
#pragma mark Private Methods

- (void)didFinishSyncing {
	[rsyncTask release];
	rsyncTask = nil;
	
	[progressSpinner stopAnimation:nil];
	[[NSApplication sharedApplication] endSheet:syncWindow];	
}

- (void)performRsync {
	rsyncTask = [[NSTask alloc] init];
    [rsyncTask setLaunchPath: @"/opt/local/bin/rsync"];
	NSString *libraryPath = [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"library"];
	[rsyncTask setArguments: [NSArray arrayWithObjects: @"-avz", @"--delete", @"/Volumes/kommunikation/extern/Praesentationen/presentationtest/", libraryPath, nil]];
	
	NSPipe *pipe = [NSPipe pipe];
	[rsyncTask setStandardOutput: pipe];
	
	[rsyncTask launch];
    [rsyncTask waitUntilExit];
	
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data = [file readDataToEndOfFile];
	
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"got\n%@", string);	
}

- (void)beautifyOutlineView {
	NSTreeNode *firstNode = [playlistView itemAtRow:0];
	[playlistView expandItem:firstNode];
	NSTreeNode *allItem = [[firstNode childNodes] objectAtIndex:0];
	
	NSUInteger row = [playlistView rowForItem:allItem];
	[playlistView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}



@end
