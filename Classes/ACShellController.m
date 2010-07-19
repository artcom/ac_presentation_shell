//
//  ACShellController.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellController.h"
#import "Presentation.h"
#import "PresentationLibrary.h"
#import "PresentationWindowController.h"
#import "ACShellCollection.h"
#import "NSFileManager-DirectoryHelper.h"
#import "PreferenceWindowController.h"
#import "KeynoteHandler.h"

#define ACSHELL_PRESENTATION @"ACShell_Presentation"

#define ACSHELL_OPEN_PRESENTATION 0
#define ACSHELL_PLAY_PRESENTATION 1

@interface ACShellController ()

- (void)performRsync;
- (void)didFinishSyncing;
- (void)beautifyOutlineView;
- (BOOL) isToplevelGroup: (id) item;
- (BOOL) isStaticCategory: (id) item;
- (void) updateStatusText: (NSNotification*) notification;

@end

@implementation ACShellController
@synthesize presentationLibrary;
@synthesize presentationsArrayController;
@synthesize collectionTreeController;
@synthesize syncWindow;
@synthesize browserWindow;
@synthesize progressSpinner;
@synthesize collectionView;
@synthesize presentationTable;
@synthesize statusLine;

- (id) init {
	self = [super init];
	if (self != nil) {		        
        NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
        [[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile: filepath]];
		
		presentationWindowController = [[PresentationWindowController alloc] init];
        preferenceWindowController = [[PreferenceWindowController alloc] init];
        presentationLibrary = [[PresentationLibrary libraryFromSettingsFile] retain];
	}
	
	return self;
}

- (void) awakeFromNib {
	[presentationTable registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
	[presentationTable setTarget:self];
	[presentationTable setDoubleAction:@selector(openPresentation:)];
	
	[collectionView registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
    
    [[statusLine cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusText:)
                                                 name:NSTableViewSelectionDidChangeNotification object:presentationTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusText:)
                                                 name:NSOutlineViewSelectionDidChangeNotification object:collectionView];
}

- (void) dealloc {
	[presentationWindowController release];
    [preferenceWindowController release];
	[presentationLibrary release];
	[collectionView release];
	[presentationTable release];
	
	[super dealloc];
}

-(void) load {
    if ( ! [presentationLibrary loadXmlLibrary]) {
        NSBeginAlertSheet( NSLocalizedString(@"Synchronize library now?",nil), @"OK", @"Cancel",
                          nil, browserWindow, self, @selector(onLibrarySyncAnswered:returnCode:contextInfo:),
                          nil, browserWindow, 
                          NSLocalizedString(@"A good network connection and some patience is required.", nil),
                          nil);

    }
	
	[self beautifyOutlineView];
}

-(void) onLibrarySyncAnswered: (NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    NSLog(@"answer");
    if (returnCode == NSAlertDefaultReturn) {
        [sheet close];
        [self sync: nil];
    } else {
        NSLog(@"sync canceled");
    }
}
        
- (IBAction)play: (id)sender {	
	presentationWindowController.presentations = [self selectedPresentations];
	[presentationWindowController showWindow:nil];
}

- (IBAction)sync: (id)sender {
	[[NSApplication sharedApplication] beginSheet:syncWindow modalForWindow: browserWindow 
									modalDelegate:self didEndSelector:@selector(didEndModal) contextInfo:nil];
	[progressSpinner startAnimation:nil];
		
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self performRsync];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self didFinishSyncing];
		});
	});
}

- (IBAction)abortSync: (id)sender {
	[rsyncTask terminate];
		
	[self didFinishSyncing];
}

- (IBAction)remove: (id)sender {
	if ([browserWindow firstResponder] == presentationTable) {
		[self removePresentation:sender];			
	} else if ([browserWindow firstResponder] == collectionView) {
		[self removeCollection:self];
	}
}

- (IBAction)openPresentation: (id)sender {
	if (sender == presentationTable) {
		Presentation *presentation = [[presentationsArrayController selectedObjects] objectAtIndex:0];
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"presentationDoubleClick"] intValue] == ACSHELL_OPEN_PRESENTATION) {
			[[KeynoteHandler sharedHandler] open: presentation.presentationFile];			
		} else {
			[[KeynoteHandler sharedHandler] play: presentation.presentationFile withDelegate: self];			
		}
		
	}
}

- (IBAction)updatePresentationFilter: (id) sender {
    NSString * searchString = [sender stringValue];
    NSPredicate * predicate = nil;
    if ((searchString != nil) && (![searchString isEqualToString:@""])) {
        predicate = [NSPredicate predicateWithFormat: @"title contains[cd] %@", searchString];
    }
    [presentationsArrayController setFilterPredicate: predicate];
    [self updateStatusText: nil];
}

- (void)didEndModal {
    NSLog(@"sync window out");
    [syncWindow close];
	[syncWindow orderOut:nil];
}

- (NSArray *)selectedPresentations {
	NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES"];
	return [[presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
}

- (IBAction)addCollection: (id)sender {
	ACShellCollection *list = [ACShellCollection collectionWithName:NSLocalizedString(@"new collection", nil)
                                                      presentations:[NSMutableArray array] children:nil];
	
	NSUInteger indices[] = {1,[presentationLibrary collectionCount]};
	
	[collectionTreeController insertObject:list atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indices length:2]];

    [collectionTreeController setSelectionIndexPath: [NSIndexPath indexPathWithIndexes: indices length: 2]];
    [collectionView editColumn: 0 row: [collectionView selectedRow] withEvent:nil select:YES];
}

- (IBAction)removeCollection: (id)sender {
	NSIndexPath *selectedPath = [collectionTreeController selectionIndexPath];
	if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
        NSBeep();
		return;
	}

	[collectionTreeController removeObjectAtArrangedObjectIndexPath:selectedPath];

    if ([presentationLibrary collectionCount] == 0) {
        [collectionView deselectAll: self];
    }
}

- (IBAction)removePresentation: (id) sender {
    NSIndexPath *selectedPath = [collectionTreeController selectionIndexPath];
	if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
        NSBeep();
		return;
	}

    [presentationsArrayController removeObjects: [presentationsArrayController selectedObjects]];
}

- (IBAction)showPreferences: (id) sender {
    [preferenceWindowController showWindow: sender];
}

-(NSMutableArray*) library {
    return presentationLibrary.library.children;
}

-(void) setLibrary:(NSMutableArray *) array {
    presentationLibrary.library.children = array;
}

#pragma mark -
#pragma mark NSTableViewDelegate Protocol Methods 

- (BOOL) tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION] owner:self];
    [pboard setData:data forType:ACSHELL_PRESENTATION];
    return YES;
}

- (NSDragOperation) tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
	if (dropOperation == NSTableViewDropOn) {
		return NSDragOperationNone;
	}
	return NSDragOperationMove;
}

- (BOOL) tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
	NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:ACSHELL_PRESENTATION];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
	ACShellCollection *selectedCollection = [[collectionTreeController selectedObjects] objectAtIndex:0];
	NSMutableArray *myPresentations = selectedCollection.presentations;
	
	NSMutableArray *movedPresentations = [[NSMutableArray alloc] init];
	
	Presentation *insertionPoint = row < [myPresentations count] ? [myPresentations objectAtIndex:row] : nil;
	[rowIndexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger index, BOOL *stop) {
		[movedPresentations addObject: [myPresentations objectAtIndex:index]];
		[myPresentations removeObjectAtIndex:index];
	}];
	
	NSUInteger insertionIndex = insertionPoint ? [myPresentations indexOfObject:insertionPoint] : [myPresentations count];
	
	for (Presentation *p in (insertionPoint ? [movedPresentations objectEnumerator] : [movedPresentations reverseObjectEnumerator])) {
		if (insertionIndex < [myPresentations count]) {
			[myPresentations insertObject:p atIndex:insertionIndex];	
		} else {
			[myPresentations addObject:p];
		}
		
	}
	
	[presentationLibrary updateIndices:myPresentations];
	NSIndexSet *newSelection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertionIndex, [movedPresentations count])];
	[presentationTable selectRowIndexes:newSelection byExtendingSelection:NO];
	[presentationTable reloadData];
	
	return YES;
}

- (void) updateStatusText: (NSNotification*) notification {
    unsigned selectedItems =     [[presentationTable selectedRowIndexes] count];
    if ( ! [presentationLibrary hasLibrary]) {
        [statusLine setStringValue: NSLocalizedString(@"No library loaded", nil)];
    } else if (selectedItems > 0) {
        [statusLine setStringValue: [NSString stringWithFormat: NSLocalizedString(@"%d of %d presentations", nil), 
                                     selectedItems, [[presentationsArrayController arrangedObjects] count]]];
    } else {
        [statusLine setStringValue: [NSString stringWithFormat: NSLocalizedString(@"%d presentations", nil),
                                     [[presentationsArrayController arrangedObjects] count]]];
    }
}


#pragma mark -
#pragma mark  NSOutlineViewDelegate Protocol Methods

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ! [self isToplevelGroup: item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [self isToplevelGroup: item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return  ! [self isToplevelGroup: item] && ! [self isStaticCategory: item];
}

- (NSDragOperation) outlineView:(NSOutlineView *)outlineView 
				   validateDrop:(id <NSDraggingInfo>)info 
				   proposedItem:(id)item proposedChildIndex:(NSInteger)index {
	
	if (index != -1 || // only allow drops on collections, not between them
        [self isToplevelGroup: item] || [self isStaticCategory:item]) // keep static stuff static
    {
		return NSDragOperationNone;
	}

    ACShellCollection * selectedCollection = [[collectionTreeController selectedObjects] objectAtIndex: 0];
    ACShellCollection * droppedOnCollection = (ACShellCollection *)[item representedObject];
    if (selectedCollection == droppedOnCollection) {
        return NSDragOperationNone;
    }

	return NSDragOperationLink;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
	NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:ACSHELL_PRESENTATION];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	
	ACShellCollection *selectedCollection = [[collectionTreeController selectedObjects] objectAtIndex:0];
	
	NSArray *selectionArray = [[NSArray alloc] initWithArray:[selectedCollection.presentations objectsAtIndexes:rowIndexes] copyItems:YES];
	
	ACShellCollection *collection = (ACShellCollection *)[item representedObject];
	[collection.presentations addObjectsFromArray:selectionArray];
	[selectionArray release];
	
	[self.presentationLibrary updateIndices:collection.presentations];
	return YES;
}

#pragma mark -
#pragma mark KeynoteDelegate Protocol Methods
- (void) keynoteDidStopPresentation:(KeynoteHandler *)aKeynote {
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[self browserWindow] makeKeyAndOrderFront:nil];
}


#pragma mark -
#pragma mark Private Methods
- (BOOL) isToplevelGroup: (id) item {
    if ([[item indexPath] length] == 1) {
        return YES;
    }
	return NO;    
}

- (BOOL) isStaticCategory: (id) item {
	if ([[item indexPath] length] == 2 && [[item indexPath] indexAtPosition: 0] == 0) {
		return YES;
	}
	return NO;    
}

- (void)didFinishSyncing {
    if ([rsyncTask terminationStatus] != 0) {
        NSFileHandle *file = [rsyncTask.standardError fileHandleForReading];
        NSData *data = [file readDataToEndOfFile];
        
        NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        NSLog (@"ERROR\n%@", string);	
    } else {        
        if ( ! [presentationLibrary loadXmlLibrary] ) {
            NSLog(@"Failed to load xml library after syncing.");
        }
    }
    [rsyncTask release];
    rsyncTask = nil;    
	
	[progressSpinner stopAnimation:nil];
	[[NSApplication sharedApplication] endSheet:syncWindow];	
}

- (void)performRsync {
	rsyncTask = [[NSTask alloc] init];
    [rsyncTask setLaunchPath: @"/opt/local/bin/rsync"];
	NSString *dstPath = [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain] stringByAppendingPathComponent:@"library"];
	NSString * srcPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"libraryPath"];
    
    NSLog(@"%@", srcPath);
    /*if ([srcPath characterAtIndex: [srcPath length] - 1] != '/') {
        srcPath = [srcPath stringByAppendingString: @"/"];
    }*/
    [rsyncTask setArguments: [NSArray arrayWithObjects: @"-avz", @"--delete", srcPath, dstPath, nil]];
	
	NSPipe *pipe = [NSPipe pipe];
	[rsyncTask setStandardError: pipe];
	
	[rsyncTask launch];
    [rsyncTask waitUntilExit];
}

- (void)beautifyOutlineView {
	[collectionView expandItem:nil expandChildren:YES];
	
	NSTreeNode *firstNode = [collectionView itemAtRow:0];
	NSTreeNode *allItem = [[firstNode childNodes] objectAtIndex:0];
	NSUInteger row = [collectionView rowForItem:allItem];
	[collectionView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}



@end
