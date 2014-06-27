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
#import "KeynoteHandler.h"
#import "RsyncController.h"
#import "EditWindowController.h"
#import "SetupAssistantController.h"
#import "PreferenceController.h"
#import "default_keys.h"
#import "localized_text_keys.h"

#define ACSHELL_PRESENTATION @"ACShell_Presentation"

enum ACPresentationDoubleClicked {
    ACShellOpenPresentation,
    ACShellPlayPresentation,
    ACShellOpenEditWindow
};

// keep this in sync with the interface builder tags
enum CollectionActionTags {
    AddCollectionAction,
    DeleteCollectionAction
};

#define AC_SHELL_TOOLBAR_ITEM_START  @"ACShellToolbarItemStart"
#define AC_SHELL_TOOLBAR_ITEM_SYNC   @"ACShellToolbarItemSync"
#define AC_SHELL_TOOLBAR_ITEM_UPLOAD @"ACShellToolbarItemUpload"
#define AC_SHELL_TOOLBAR_ITEM_SEARCH @"ACShellToolbarItemSearch"
#define AC_SHELL_SEARCH_MAX_RESULTS  1000

@interface ACShellController ()

@property (weak, readonly) NSString* librarySource;
@property (weak, readonly) NSString* libraryTarget;

- (void)beautifyOutlineView;
- (BOOL) isToplevelGroup: (id) item;
- (BOOL) isStaticCategory: (id) item;
- (void) updateStatusText: (NSNotification*) notification;
- (void) updateSyncFailedWarning;
- (BOOL) isCollectionSelected;

- (BOOL) runSuppressableBooleanDialogWithIdentifier: (NSString*) identifier
                                            message: (NSString*) message
                                           okButton: (NSString*) ok
                                       cancelButton: (NSString*) cancel;

-(void) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet toIndex:(NSUInteger)insertIndex;
- (NSInteger)rowsAboveRow:(NSInteger)row inIndexSet:(NSIndexSet *)indexSet;

- (BOOL) handleDuplicates: (NSMutableArray*) newItems inCollection: (ACShellCollection*) collection;
- (BOOL) isPresentationRemovable;

- (void) presentationTableColumnOrderDidChange: (id) aNotification;
@end

@implementation ACShellController
@synthesize presentationLibrary;
@synthesize presentationsArrayController;
@synthesize collectionTreeController;
@synthesize browserWindow;
@synthesize collectionView;
@synthesize presentationTable;
@synthesize statusLine;
@synthesize currentPresentationList;
@synthesize warningIcon;
@synthesize editingEnabled;
@synthesize editPresentationMenuItem;
@synthesize collectionActions;
@synthesize leftSplitPane;
@synthesize rightSplitPane;

+ (void) initialize {
	NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	[[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile: filepath]];
}

- (id) init {
	self = [super init];
	if (self != nil) {
        presentationLibrary = [PresentationLibrary libraryFromSettingsFile];
        
		presentationWindowController = [[PresentationWindowController alloc] init];
        
        preferenceController = [[PreferenceController alloc] init];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED]) {
            editWindowController = [[EditWindowController alloc] initWithShellController: self];
        }
		
		rsyncController = [[RsyncController alloc] init];
		rsyncController.delegate = self;
    }
	
	return self;
}

- (void) awakeFromNib {
	[presentationTable registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
	[presentationTable setTarget:self];
	[presentationTable setDoubleAction:@selector(openPresentation:)];
	
	[collectionView registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
    
    [[statusLine cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentationSelectionDidChange:)
                                                 name:NSTableViewSelectionDidChangeNotification object:presentationTable];
	
	[self bind: @"currentPresentationList" toObject:collectionTreeController withKeyPath:@"selection.presentations" options:nil];
    
    rsyncController.documentWindow = self.browserWindow;
    
    [self updateSyncFailedWarning];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey: ACSHELL_DEFAULT_KEY_SETUP_DONE]) {
        [[KeynoteHandler sharedHandler] launchWithDelgate: self];
        [[self browserWindow] makeKeyAndOrderFront: self];
        [self load];
    } else {
        setupAssistant = [[SetupAssistantController alloc] initWithDelegate: self];
        [setupAssistant showWindow: self];
    }
    
    [self presentationTableColumnOrderDidChange: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(presentationTableColumnOrderDidChange:)
                                                 name: NSTableViewColumnDidMoveNotification
                                               object:presentationTable];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"order" ascending:YES];
    self.userSortDescriptor = sortDescriptor;
    
    [presentationTable setSortDescriptors:@[self.userSortDescriptor]];
}


-(void) load {
	[collectionView deselectAll:self];
	
	[self willChangeValueForKey:@"library"];
    if ( ! [presentationLibrary loadXmlLibraryFromDirectory: self.libraryDirPath]) {
        
        [rsyncController initialSyncWithSource: self.librarySource destination: self.libraryDirPath];
    }
	[self didChangeValueForKey:@"library"];
	[self beautifyOutlineView];
}

- (IBAction)play: (id)sender {
	presentationWindowController.presentations = [self selectedPresentations];
	[presentationWindowController showWindow:nil];
}

- (IBAction)sync: (id)sender {
    if ([presentationLibrary hasLibrary]) {
        [rsyncController syncWithSource: self.librarySource destination: self.libraryDirPath];
    } else {
        [rsyncController initialSyncWithSource: self.librarySource destination: self.libraryDirPath];
    }
}

- (IBAction) upload: (id) sender {
    [rsyncController uploadWithSource: self.libraryDirPath destination: self.libraryTarget];
}

- (IBAction)remove: (id)sender {
	if ([browserWindow firstResponder] == presentationTable) {
		[self removePresentation:sender];
	} else if ([browserWindow firstResponder] == collectionView) {
		[self removeCollection:self];
	} else {
        NSBeep();
    }
}

- (IBAction)addPresentation: sender {
    [self beautifyOutlineView];
    [editWindowController add];
}

- (IBAction)openPresentation: (id)sender {
	if (sender == presentationTable) {
        if ([[presentationsArrayController selectedObjects] count] > 0) {
            Presentation *presentation = [[presentationsArrayController selectedObjects] objectAtIndex:0];
            int doubleClickSetting = [[[NSUserDefaults standardUserDefaults] objectForKey: ACSHELL_DEFAULT_KEY_PRESENTATION_DOUBLE_CLICKED] intValue];
            switch (doubleClickSetting) {
                case ACShellOpenPresentation:
                    if (presentation.presentationFileExists) {
                        [[KeynoteHandler sharedHandler] open: presentation.absolutePresentationPath];
                    }
                    break;
                case ACShellPlayPresentation:
                    if (presentation.presentationFileExists) {
                        [[KeynoteHandler sharedHandler] play: presentation.absolutePresentationPath withDelegate: self];
                    }
                    break;
                case ACShellOpenEditWindow:
                    if ( ! [[editWindowController window] isVisible]) {
                        [editWindowController edit: presentation];
                    } else {
                        NSBeep();
                        [[editWindowController window] makeKeyAndOrderFront: sender];
                    }
                    break;
                default:
                    break;
            }
        }
	}
}

- (IBAction)collectionActionClicked: (id) sender {
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment: clickedSegment];
    switch (clickedSegmentTag) {
        case AddCollectionAction:
            [self addCollection: sender];
            break;
        case DeleteCollectionAction:
            [self removeCollection: sender];
            break;
        default:
            break;
    }
}

- (IBAction)updatePresentationFilter:(id)sender {
    
    NSString *searchString = [sender stringValue];
    
    // If there is no search query, remove any existing filter and sort using user-defined sort
    if ([searchString isEqualToString:@""]) {
        [presentationsArrayController setFilterPredicate:nil];
        [presentationTable setSortDescriptors:@[self.userSortDescriptor]];
        return;
    }
    
    // Prepend and append an asterisk '*' to every word of the entered query to also get results
    // where a word in a presentation starts or ends with a queried word,
    // e.g. 'Hello world' becomes '*Hello* *world*' to also find 'Hello worlds'
    NSArray *searchWords = [searchString componentsSeparatedByString:@" "];
    NSMutableArray *wildcardedWords = [NSMutableArray arrayWithCapacity:searchWords.count];
    for (NSString *word in searchWords) {
        if ([word isEqualToString:@"AND"] || [word isEqualToString:@"OR"]) [wildcardedWords addObject:word];
        else [wildcardedWords addObject:[NSString stringWithFormat:@"*%@*", word]];
    }
    NSString *fullTextQuery = [wildcardedWords componentsJoinedByString:@" "];

    // Start async search
    __weak ACShellController *weakSelf = self;
    [self.presentationLibrary searchFullText:fullTextQuery maxNumResults:AC_SHELL_SEARCH_MAX_RESULTS completion:^(NSArray *results) {
        
        // Filter: Entry has to be in result list or the original searchString has to be in title or year
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"title contains[cd] %@ or yearString contains[cd] %@ or directory IN %@", searchString, searchString, results];
        //NSPredicate *predicate = [NSPredicate predicateWithFormat: @"directory IN %@", results];
        [weakSelf.presentationsArrayController setFilterPredicate:predicate];
        
        /** Sort descriptor for table view: Entries should be shown in the same order as the @a results array */
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"directory" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSUInteger index1 = [results indexOfObject:obj1];
            NSUInteger index2 = [results indexOfObject:obj2];
            
            // If an index is NSNotFound it means that the entry is in the title or the year
            // but not in the Keynote presentation itself. In this case we'll put it at the
            // end of the list. Since NSNotFound is actually NSIntegerMax, this will work automatically.
            if (index1 > index2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (index1 < index2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        [weakSelf.presentationTable setSortDescriptors:@[sortDescriptor]];
    }];
}


- (NSArray *)selectedPresentations {
	NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES AND isComplete == YES"];
	return [[presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
}

- (IBAction)addCollection: (id)sender {
	ACShellCollection *list = [ACShellCollection collectionWithName:NSLocalizedString(ACSHELL_STR_NEW_COLLECTION, nil)
                                                      presentations:[NSMutableArray array] children:nil];
	
	NSUInteger indices[] = {1,[presentationLibrary collectionCount]};
	
	[collectionTreeController insertObject:list atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indices length:2]];
    
    [collectionTreeController setSelectionIndexPath: [NSIndexPath indexPathWithIndexes: indices length: 2]];
    [collectionView editColumn: 0 row: [collectionView selectedRow] withEvent:nil select:YES];
}

- (IBAction)editPresentation: (id) sender {
    if ( ! [[editWindowController window] isVisible]) {
        Presentation *presentation = [[presentationsArrayController selectedObjects] objectAtIndex:0];
        [editWindowController edit: presentation];
    } else {
        NSBeep();
    }
}

- (BOOL) isCollectionSelected {
	NSIndexPath *selectedPath = [collectionTreeController selectionIndexPath];
	if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
		return NO;
	}
    return YES;
}

- (IBAction)removeCollection: (id)sender {
	NSIndexPath *selectedPath = [collectionTreeController selectionIndexPath];
	if (! [self isCollectionSelected]) {
        NSBeep();
		return;
	}
    
    BOOL deleteIt = [self runSuppressableBooleanDialogWithIdentifier: @"DeleteCollection"
                                                             message: ACSHELL_STR_DELETE_COLLECTION
                                                            okButton: ACSHELL_STR_DELETE
                                                        cancelButton: ACSHELL_STR_CANCEL];
    if (deleteIt) {
        [collectionTreeController removeObjectAtArrangedObjectIndexPath:selectedPath];
        
        if ([presentationLibrary collectionCount] == 0) {
            [collectionView deselectAll: self];
        }
    }
}

- (IBAction)removePresentation: (id) sender {
	if ( ! [self isPresentationRemovable]) {
        NSBeep();
		return;
	}
    
    BOOL deleteIt = [self runSuppressableBooleanDialogWithIdentifier: @"DeletePresentationFromCollection"
                                                             message: ACSHELL_STR_DELETE_PRESENTATION
                                                            okButton: ACSHELL_STR_DELETE
                                                        cancelButton: ACSHELL_STR_CANCEL];
    if (deleteIt) {
        [presentationsArrayController removeObjectsAtArrangedObjectIndexes: [presentationsArrayController selectionIndexes]];
        NSArray * items = [[[collectionTreeController selectedObjects] objectAtIndex:0] presentations];
        NSInteger order = 1;
        for (Presentation* p in items) {
            p.order = order++;
        }
    }
}


- (void) userDidHidePresentationColumn: (id) sender {
    NSTableColumn * column = [sender representedObject];
    [column setHidden: ! [column isHidden]];
    [sender setState: [column isHidden] ? NSOffState : NSOnState];
}

- (BOOL) isPresentationRemovable {
    NSIndexPath *selectedPath = [collectionTreeController selectionIndexPath];
	if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
        return NO;
    }
    return YES;
}

- (IBAction)showPreferences: (id) sender {
    [preferenceController showWindow: sender];
}

-(NSMutableArray*) library {
    return presentationLibrary.library.children;
}

-(void) setLibrary:(NSMutableArray *) array {
    presentationLibrary.library.children = array;
}

- (void)setCurrentPresentationList:(NSMutableArray *)newArray {
	if (currentPresentationList != newArray) {
		currentPresentationList = newArray;
		
		if ([[collectionTreeController selectedObjects] count] > 0) {
			[[[collectionTreeController selectedObjects] objectAtIndex:0] setPresentations: currentPresentationList];
		}
	}
}

-(NSMutableArray*) currentPresentationList {
	if (![presentationLibrary hasLibrary]) {
		return [NSMutableArray array];
	}
	return currentPresentationList;
}

- (BOOL) editingEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED];
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
    NSArray * sortDescriptors = [tableView sortDescriptors];
    if ([sortDescriptors count] > 0 &&
        [[[sortDescriptors objectAtIndex: 0] key] isEqual: @"order"] &&
        [presentationsArrayController filterPredicate] == nil)
    {
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

- (BOOL) tableView: (NSTableView*) tableView acceptDrop: (id<NSDraggingInfo>) info
               row: (NSInteger) row dropOperation: (NSTableViewDropOperation) dropOperation
{
    NSData * rowsData = [[info draggingPasteboard] dataForType: ACSHELL_PRESENTATION];
    NSIndexSet * indexSet = [NSKeyedUnarchiver unarchiveObjectWithData: rowsData];
    [self moveObjectsInArrangedObjectsFromIndexes: indexSet toIndex: row];
    
    NSInteger rowsAbove = [self rowsAboveRow:row inIndexSet:indexSet];
    NSRange range = NSMakeRange(row - rowsAbove, [indexSet count]);
    indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [presentationsArrayController setSelectionIndexes:indexSet];
    
    NSSortDescriptor * sort = [[presentationsArrayController sortDescriptors] objectAtIndex: 0];
    NSArray * items = [presentationsArrayController arrangedObjects];
    BOOL isAscending = [sort ascending];
    int index = isAscending ? 1 : [items count];
    for (Presentation* p in items) {
        p.order = index;
        index += (isAscending ? 1 : -1);
    }
    
    return YES;
}

-(void) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet toIndex:(NSUInteger)insertIndex {
	
    NSArray *objects = [presentationsArrayController arrangedObjects];
	NSInteger idx = [indexSet lastIndex];
	
    NSInteger aboveInsertIndexCount = 0;
    id object;
    NSInteger removeIndex;
	
    while (NSNotFound != idx) {
		if (idx >= insertIndex) {
			removeIndex = idx + aboveInsertIndexCount;
			aboveInsertIndexCount += 1;
		}
		else {
			removeIndex = idx;
			insertIndex -= 1;
		}
		object = [objects objectAtIndex:removeIndex];
		[presentationsArrayController removeObjectAtArrangedObjectIndex:removeIndex];
		[presentationsArrayController insertObject:object atArrangedObjectIndex:insertIndex];
		idx = [indexSet indexLessThanIndex:idx];
    }
}

- (NSInteger)rowsAboveRow:(NSInteger)row inIndexSet:(NSIndexSet *)indexSet {
    
	NSUInteger currentIndex = [indexSet firstIndex];
    NSInteger i = 0;
    while (currentIndex != NSNotFound) {
		if (currentIndex < row) {
            i++;
        }
		currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
    }
    return i;
}

- (void) presentationSelectionDidChange: (id) sender {
    [self updateStatusText: sender];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem {
    SEL theAction = [anItem action];
    
    if (theAction == @selector(editPresentation:)){
        if ([[presentationTable selectedRowIndexes] count] == 1) {
            return YES;
        }
        return NO;
    } else if (theAction == @selector(remove:)) {
        if ([browserWindow firstResponder] == presentationTable) {
            return [self isPresentationRemovable];
        } else if ([browserWindow firstResponder] == collectionView) {
            return [self isCollectionSelected];
        } else {
            return NO;
        }
        
    }
    return YES;
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
    
    NSArray * arrangedItems = [presentationsArrayController arrangedObjects];
    NSArray * draggedItems = [arrangedItems objectsAtIndexes: rowIndexes];
    NSMutableArray * newItems = [[NSMutableArray alloc] initWithArray: draggedItems copyItems: YES];
    
	ACShellCollection *collection = (ACShellCollection *)[item representedObject];
    
    if ([self handleDuplicates: newItems inCollection: collection]) {
        int order = [collection.presentations count] + 1;
        for (Presentation* p in newItems) {
            p.order = order++;
        }
        [collection.presentations addObjectsFromArray: newItems];
    }
	return YES;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [collectionActions setEnabled: [self isCollectionSelected] forSegment: DeleteCollectionAction];
    [self updateStatusText: nil];
}

#pragma mark -
#pragma mark NSSplitViewDelegate Protocol Methods
- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize: (NSSize)oldSize {
    float desiredLeftViewWidth = [leftSplitPane frame].size.width;
    [sender adjustSubviews];
    NSRect leftFrame = [leftSplitPane frame];
    NSRect rightFrame = [rightSplitPane frame];
    
    leftFrame.origin.x = 0;
    leftFrame.size.width = desiredLeftViewWidth;
    
    rightFrame.origin.x = desiredLeftViewWidth + 1;
    rightFrame.size.width = [sender frame].size.width - desiredLeftViewWidth - 1;
    
    
    [leftSplitPane setFrame: leftFrame];
    [rightSplitPane setFrame: rightFrame];
    
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification {
    NSRect tableFrame = [rightSplitPane frame];
    NSRect labelFrame = [statusLine frame];
    labelFrame.origin.x = tableFrame.origin.x;
    labelFrame.size.width = tableFrame.size.width;
    [statusLine setFrame: labelFrame];
}

#pragma mark -
#pragma mark NSToolbarDelegate Protocol Methods
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:
            AC_SHELL_TOOLBAR_ITEM_START,
            AC_SHELL_TOOLBAR_ITEM_SYNC,
            AC_SHELL_TOOLBAR_ITEM_UPLOAD,
            AC_SHELL_TOOLBAR_ITEM_SEARCH,
            NSToolbarCustomizeToolbarItemIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            NSToolbarSpaceItemIdentifier,
            NSToolbarSeparatorItemIdentifier,
            nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:
            NSToolbarSpaceItemIdentifier,
            AC_SHELL_TOOLBAR_ITEM_START,
            NSToolbarSpaceItemIdentifier,
            AC_SHELL_TOOLBAR_ITEM_SYNC,
            NSToolbarFlexibleSpaceItemIdentifier,
            AC_SHELL_TOOLBAR_ITEM_SEARCH,
            nil];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqual: AC_SHELL_TOOLBAR_ITEM_UPLOAD] && [self editingEnabled]) {
        NSToolbarItem * item = [[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier];
        [item setImage: [NSImage imageNamed: @"icn_upload"]];
        [item setLabel: NSLocalizedString(ACSHELL_STR_UPLOAD, nil)];
        [item setToolTip: NSLocalizedString(ACSHELL_STR_UPLOAD_TOOLTIP, nil)];
        [item setPaletteLabel: NSLocalizedString(ACSHELL_STR_UPLOAD, nil)];
        return item;
    }
    return nil;
}

- (void) toolbarWillAddItem:(NSNotification *)notification {
    NSToolbarItem *addedItem = [[notification userInfo] objectForKey: @"item"];
    if ([[addedItem itemIdentifier] isEqual: AC_SHELL_TOOLBAR_ITEM_UPLOAD]) {
        if (self.editingEnabled) {
            [addedItem setTarget:self];
            [addedItem setAction:@selector(upload:)];
        } else {
            [addedItem setEnabled: NO];
        }
    }
}

#pragma mark -
#pragma mark KeynoteDelegate Protocol Methods

- (void) keynoteAppDidLaunch: (BOOL) success version:(NSString *)version {
    if (success) {
        NSLog(@"Running Keynote application Version %@", version);
        //run prefs checks
    } else {
        // issue warning
        NSLog(@"Failed to run Keynote application Version %@", version);
    }
}

#pragma mark -
#pragma mark RsyncControllerDelegate Protocol Methods
- (void)rsync:(RsyncController *) controller didFinishSyncSuccessfully:(BOOL)successFlag {
    self.presentationLibrary.syncSuccessful = successFlag;
    [self updateSyncFailedWarning];
	if (successFlag) {
		[self load];
	}
}

#pragma mark -
#pragma mark SetupAssistantDelegate Protocol Methods
- (void) setupDidFinish: (id) sender {
    [[NSUserDefaults standardUserDefaults] setBool: YES forKey: ACSHELL_DEFAULT_KEY_SETUP_DONE];
    [self beautifyOutlineView];
    [[self browserWindow] makeKeyAndOrderFront: self];
    [[KeynoteHandler sharedHandler] launchWithDelgate: self];
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

- (void)beautifyOutlineView {
	[collectionView expandItem:nil expandChildren:YES];
	
	NSTreeNode *firstNode = [collectionView itemAtRow:0];
	NSTreeNode *allItem = [[firstNode childNodes] objectAtIndex:0];
	NSUInteger row = [collectionView rowForItem:allItem];
	[collectionView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (NSString*) librarySource {
    if ([self editingEnabled]) {
        return self.libraryTarget;
    }
	[[NSUserDefaults standardUserDefaults] synchronize];
    if ([[NSUserDefaults standardUserDefaults] objectForKey: ACSHELL_DEFAULT_KEY_RSYNC_READ_USER] != nil) {
        return [NSString stringWithFormat: @"%@@%@",
                [[NSUserDefaults standardUserDefaults]  stringForKey: ACSHELL_DEFAULT_KEY_RSYNC_READ_USER],
                [[NSUserDefaults standardUserDefaults]  stringForKey: ACSHELL_DEFAULT_KEY_RSYNC_SOURCE]];
    }
    return [[NSUserDefaults standardUserDefaults]  stringForKey: ACSHELL_DEFAULT_KEY_RSYNC_SOURCE];
}

- (NSString*) libraryTarget {
	[[NSUserDefaults standardUserDefaults] synchronize];
    if ([[NSUserDefaults standardUserDefaults] objectForKey: ACSHELL_DEFAULT_KEY_RSYNC_WRITE_USER] != nil) {
        return [NSString stringWithFormat: @"%@@%@",
                [[NSUserDefaults standardUserDefaults]  stringForKey: ACSHELL_DEFAULT_KEY_RSYNC_WRITE_USER],
                [[NSUserDefaults standardUserDefaults]  stringForKey: ACSHELL_DEFAULT_KEY_RSYNC_SOURCE]];
    }
    return [[NSUserDefaults standardUserDefaults]  stringForKey: ACSHELL_DEFAULT_KEY_RSYNC_SOURCE];
}

- (NSString*) libraryDirPath {
    return [[[NSFileManager defaultManager] applicationSupportDirectoryInUserDomain]
            stringByAppendingPathComponent: [self.librarySource lastPathComponent]];
}

- (void) updateSyncFailedWarning {
    BOOL lastSyncOk = presentationLibrary.syncSuccessful;
    [self.warningIcon setHidden: lastSyncOk];
    if ( ! lastSyncOk ) {
        [self.warningIcon setToolTip: NSLocalizedString(ACSHELL_STR_LAST_SYNC_FAILED, nil)];
    }
}

- (void) updateStatusText: (NSNotification*) notification {
    unsigned selectedItems = [[presentationTable selectedRowIndexes] count];
    if ( ! [presentationLibrary hasLibrary]) {
        [statusLine setStringValue: NSLocalizedString(ACSHELL_STR_NO_LIBRARY, nil)];
    } else if (selectedItems > 0) {
        [statusLine setStringValue: [NSString stringWithFormat: NSLocalizedString(ACSHELL_STR_N_OF_M_PRESENTATIONS, nil),
                                     selectedItems, [[presentationsArrayController arrangedObjects] count]]];
    } else {
        [statusLine setStringValue: [NSString stringWithFormat: NSLocalizedString(ACSHELL_STR_N_PRESENTATIONS, nil),
                                     [[presentationsArrayController arrangedObjects] count]]];
    }
}

- (BOOL) runSuppressableBooleanDialogWithIdentifier: (NSString*) identifier
                                            message: (NSString*) message
                                           okButton: (NSString*) ok
                                       cancelButton: (NSString*) cancel
{
    BOOL reallyDoIt = NO;
    NSString * userDefaultsKey = [NSString stringWithFormat: @"supress%@Dialog", identifier];
    BOOL suppressAlert = [[NSUserDefaults standardUserDefaults] boolForKey: userDefaultsKey];
    if (suppressAlert ) {
        reallyDoIt = YES;
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText: NSLocalizedString(message, nil)];
        [alert addButtonWithTitle: NSLocalizedString(ok, nil)];
        [alert addButtonWithTitle: NSLocalizedString(cancel, nil)];
        [alert setShowsSuppressionButton: YES];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            reallyDoIt = YES;
        }
        [[NSUserDefaults standardUserDefaults] setBool: alert.suppressionButton.state forKey: userDefaultsKey];
    }
    return reallyDoIt;
}

- (BOOL) handleDuplicates: (NSMutableArray*) newItems inCollection: (ACShellCollection*) collection {
    BOOL hasDuplicates = NO;
    for (Presentation * p in newItems) {
        if ([collection.presentations containsObject: p]) {
            hasDuplicates = YES;
            break;
        }
    }
    if (hasDuplicates) {
        NSAlert *alert = [NSAlert alertWithMessageText: NSLocalizedString(ACSHELL_STR_WARN_DUPLICATES, nil)
                                         defaultButton: NSLocalizedString(ACSHELL_STR_ADD, nil)
                                       alternateButton: NSLocalizedString(ACSHELL_STR_SKIP, nil)
                                           otherButton: NSLocalizedString(ACSHELL_STR_CANCEL, nil)
                             informativeTextWithFormat: @""];
        NSInteger result = [alert runModal];
        switch (result) {
            case NSAlertOtherReturn:
                return NO;
            case NSAlertDefaultReturn: /* add them anyway */
                break;
            case NSAlertAlternateReturn: /* skip duplicates */
                for (Presentation * p in [newItems reverseObjectEnumerator]) {
                    if ([collection.presentations containsObject: p]) {
                        [newItems removeObject: p];
                    }
                }
                break;
        }
    }
    return YES;
}


- (void) presentationTableColumnOrderDidChange: (id) aNotification {
    NSMenu * menu = [[NSMenu alloc] initWithTitle: @""];
    NSArray * tableColumns = [presentationTable tableColumns];
    for (NSTableColumn * c in tableColumns) {
        NSMenuItem * item = [menu addItemWithTitle: NSLocalizedString([c identifier], nil)
                                            action: @selector(userDidHidePresentationColumn:)
                                     keyEquivalent: @""];
        [item setTarget: self];
        [item setState: [c isHidden] ? NSOffState : NSOnState];
        [item setRepresentedObject: c];
    }
    [[presentationTable headerView] setMenu: menu];
}

@end
