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

+ (void) initialize {
	NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	[[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile: filepath]];
}



- (void) awakeFromNib {
    return;
	[presentationTable registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
	[presentationTable setTarget:self];
	[presentationTable setDoubleAction:@selector(openPresentation:)];
	
	[collectionView registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
    
    [[statusLine cell] setBackgroundStyle:NSBackgroundStyleRaised];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentationSelectionDidChange:)
                                                 name:NSTableViewSelectionDidChangeNotification object:presentationTable];
	
	[self bind: @"currentPresentationList" toObject:collectionTreeController withKeyPath:@"selection.presentations" options:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(load) name:ACShellLibraryConfigDidChange object:nil];
    
    rsyncController.documentWindow = self.browserWindow;
    
    [self updateSyncFailedWarning];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey: ACSHELL_DEFAULT_KEY_SETUP_DONE]) {
        [[KeynoteHandler sharedHandler] launchWithDelegate: self];
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
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"year" ascending:NO];
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
    [sender setState: [column isHidden] ? NSControlStateValueOff : NSControlStateValueOn];
}

- (BOOL) isPresentationRemovable {
    NSIndexPath *selectedPath = [collectionTreeController selectionIndexPath];
	if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
        return NO;
    }
    return YES;
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

- (void)keynoteDidStartPresentation:(KeynoteHandler *)keynote {
    // Do nothing
}

- (void)keynoteDidStopPresentation:(KeynoteHandler *)keynote {
    // Do nothing
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
    [[KeynoteHandler sharedHandler] launchWithDelegate: self];
}

#pragma mark -
#pragma mark Private Methods

- (void)beautifyOutlineView {
	[collectionView expandItem:nil expandChildren:YES];
	
	NSTreeNode *firstNode = [collectionView itemAtRow:0];
	NSTreeNode *allItem = [[firstNode childNodes] objectAtIndex:0];
	NSUInteger row = [collectionView rowForItem:allItem];
	[collectionView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
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

- (BOOL) handleDuplicates: (NSMutableArray*) newItems inCollection: (ACShellCollection*) collection {
    BOOL hasDuplicates = NO;
    for (Presentation * p in newItems) {
        if ([collection.presentations containsObject: p]) {
            hasDuplicates = YES;
            break;
        }
    }
    if (hasDuplicates) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = NSLocalizedString(ACSHELL_STR_WARN_DUPLICATES, nil);
        
        [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_ADD, nil)];
        [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_SKIP, nil)];
        [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_CANCEL, nil)];
        
        NSInteger result = [alert runModal];
        switch (result) {
            case NSAlertFirstButtonReturn: /* add them anyway */
                break;
            case NSAlertSecondButtonReturn: /* skip duplicates */
                for (Presentation * p in [newItems reverseObjectEnumerator]) {
                    if ([collection.presentations containsObject: p]) {
                        [newItems removeObject: p];
                    }
                }
                break;
            case NSAlertThirdButtonReturn:
                return NO;
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
        [item setState: [c isHidden] ? NSControlStateValueOff : NSControlStateValueOn];
        [item setRepresentedObject: c];
    }
    [[presentationTable headerView] setMenu: menu];
}

@end
