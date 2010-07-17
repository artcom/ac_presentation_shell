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
#import "ACShellCollection.h"
#import "NSFileManager-DirectoryHelper.h"

#define LIBRARY_NAME @"LIBRARY"
#define COLLECTIONS_NAME @"COLLECTIONS"
#define CATEGORY_ALL @"All"
#define CATEGORY_HIGHLIGHTS @"Highlights"

#define ACSHELL_PRESENTATION @"ACShell_Presentation"

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
@synthesize collectionTreeController;
@synthesize syncWindow;
@synthesize progressSpinner;
@synthesize collectionView;
@synthesize presentationTable;



- (id) init {
	self = [super init];
	if (self != nil) {		
		presentationWindowController = [[PresentationWindowController alloc] init];
	}
	
	return self;
}

- (void) awakeFromNib {
	[self updatePresentationLists];
	
	[presentationTable registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
	[collectionView registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
}

- (void)updatePresentationLists {
	self.presentationContext = [[[PresentationContext alloc] init] autorelease];

	self.presentations = [presentationContext allPresentations];
	
	NSMutableArray *staticCategories = [NSMutableArray array];
	[staticCategories addObject: [ACShellCollection collectionWithName:CATEGORY_ALL presentations:[presentationContext allPresentations] children:nil]];
	[staticCategories addObject: [ACShellCollection collectionWithName:CATEGORY_HIGHLIGHTS presentations:[presentationContext highlights] children:nil]];

	ACShellCollection *library = [ACShellCollection collectionWithName:LIBRARY_NAME presentations:nil children:staticCategories];
    ACShellCollection *collections = [ACShellCollection collectionWithName:COLLECTIONS_NAME presentations:nil children:[presentationContext collections]];
    self.categories = [[NSMutableArray arrayWithObjects: library, collections, nil] retain];
	
	[self beautifyOutlineView];
}

- (void) dealloc {
	[categories release];
	[presentations release];
	[presentationWindowController release];
	[presentationContext release];
	[collectionView release];
	[presentationTable release];
	
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

- (IBAction)addCollection: (id)sender {
	ACShellCollection *list = [ACShellCollection collectionWithName:@"new collection" presentations:[NSMutableArray array] children:nil];
	
	NSUInteger indices[] = {1,[presentationContext.collections count]};
	
	[collectionTreeController insertObject:list atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indices length:2]];
	[presentationContext.collections addObject:list];
}

- (IBAction)removeCollection: (id)sender {
	NSIndexPath *selectedPath = [collectionTreeController selectionIndexPath];
	
	if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
		return;
	}

	NSArray *selectedNodes = [collectionTreeController selectedNodes];
	
	if ([selectedNodes count] > 0) {
		[presentationContext.collections removeObject:[[selectedNodes objectAtIndex:0] representedObject]];
	}
	
	[collectionTreeController removeObjectAtArrangedObjectIndexPath:selectedPath];
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
	
	
	[presentationContext updateIndices:myPresentations];
	NSIndexSet *newSelection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertionIndex, [movedPresentations count])];
	[presentationTable selectRowIndexes:newSelection byExtendingSelection:NO];
	[presentationTable reloadData];
	
	return YES;
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

- (NSDragOperation) outlineView:(NSOutlineView *)outlineView 
				   validateDrop:(id <NSDraggingInfo>)info 
				   proposedItem:(id)item proposedChildIndex:(NSInteger)index {
	
	if (index != -1 || // only allow drops on collections, not between them
        [self isSpecialGroup: item] || [self isStaticCategory:item]) // keep static stuff static
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
	
	[self.presentationContext updateIndices:collection.presentations];
	return YES;
}

#pragma mark -
#pragma mark DeleteKeyDelegate Protocol Methods

- (void) deleteKeyPressed: (NSTableView *) sender {
    if (sender == presentationTable) {
        NSLog(@"delete presentation");
    } else if (sender == collectionView) {
        [self removeCollection: sender];
    }
}

#pragma mark -
#pragma mark Private Methods

- (BOOL) isSpecialGroup: (id) item {
	ACShellCollection *collection = (ACShellCollection *)[item representedObject];
    if ([collection.name isEqualToString: LIBRARY_NAME] ||
        [collection.name isEqualToString: COLLECTIONS_NAME])
    {
        return YES;
    }
	return NO;    
}

- (BOOL) isStaticCategory: (id) item {
	ACShellCollection *collection = (ACShellCollection *)[item representedObject];
    if ([collection.name isEqualToString: CATEGORY_ALL] ||
        [collection.name isEqualToString: CATEGORY_HIGHLIGHTS])
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
	NSTreeNode *firstNode = [collectionView itemAtRow:0];
	[collectionView expandItem:nil expandChildren:YES];
	NSTreeNode *allItem = [[firstNode childNodes] objectAtIndex:0];
	
	NSUInteger row = [collectionView rowForItem:allItem];
	[collectionView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}



@end
