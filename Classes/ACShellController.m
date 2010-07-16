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

#define LIBRARY_NAME @"LIBRARY"
#define PRESETS_NAME @"PRESETS"
#define CATEGORY_ALL @"All"
#define CATEGORY_HIGHLIGHTS @"Highlights"

@interface ACShellController ()

- (void)performRsync;
- (void)updatePresentationLists;
- (void)didFinishSyncing;
- (void)beautifyOutlineView;
- (BOOL) isSpecialGroup: (id) item;
- (BOOL) isStaticCategory: (id) item;

@end



@implementation ACShellController
@synthesize presentationContext;
@synthesize presentations;
@synthesize categories;
@synthesize presentationsArrayController;
@synthesize playlistTreeController;
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
	self.presentationContext = [[[PresentationContext alloc] init] autorelease];

	self.presentations = [presentationContext allPresentations];
	
	NSMutableArray *staticCategories = [NSMutableArray array];
	[staticCategories addObject: [Playlist playlistWithName:CATEGORY_ALL presentations:[presentationContext allPresentations] children:nil]];
	[staticCategories addObject: [Playlist playlistWithName:CATEGORY_HIGHLIGHTS presentations:[presentationContext highlights] children:nil]];

	Playlist *library = [Playlist playlistWithName:LIBRARY_NAME presentations:nil children:staticCategories];
    Playlist *presets = [Playlist playlistWithName:PRESETS_NAME presentations:nil children:[presentationContext presets]];
    self.categories = [[NSMutableArray arrayWithObjects: library, presets, nil] retain];
	
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

- (IBAction)addPlaylist: (id)sender {
	Playlist *list = [Playlist playlistWithName:@"new preset" presentations:[NSMutableArray array] children:nil];
	
	NSUInteger indices[] = {1,[presentationContext.presets count]};
	
	[playlistTreeController insertObject:list atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indices length:2]];
	[presentationContext.presets addObject:list];
}


#pragma mark -
#pragma mark  NSOutlineViewDelegate Protocol Methods

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ! [self isSpecialGroup: item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [self isSpecialGroup: item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return  ! [self isSpecialGroup: item] && ! [self isStaticCategory: item];
}


#pragma mark -
#pragma mark Private Methods

- (BOOL) isSpecialGroup: (id) item {
	Playlist *playlist = (Playlist *)[item representedObject];
    if ([playlist.name isEqualToString: LIBRARY_NAME] ||
        [playlist.name isEqualToString: PRESETS_NAME])
    {
        return YES;
    }
	return NO;    
}

- (BOOL) isStaticCategory: (id) item {
	Playlist *playlist = (Playlist *)[item representedObject];
    if ([playlist.name isEqualToString: CATEGORY_ALL] ||
        [playlist.name isEqualToString: CATEGORY_HIGHLIGHTS])
    {
        return YES;
    }
	return NO;    
}

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
    
    #pragma mark TODO: handle non-zero exit status
	
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data = [file readDataToEndOfFile];
	
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"got\n%@", string);	
}

- (void)beautifyOutlineView {
	NSTreeNode *firstNode = [playlistView itemAtRow:0];
	[playlistView expandItem:nil expandChildren:YES];
	NSTreeNode *allItem = [[firstNode childNodes] objectAtIndex:0];
	
	NSUInteger row = [playlistView rowForItem:allItem];
	[playlistView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}



@end
