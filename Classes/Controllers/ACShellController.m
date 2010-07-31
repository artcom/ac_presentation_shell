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
#import "RsyncController.h"
#import "EditWindowController.h"
#import "default_keys.h"
#import "localized_text_keys.h"

#define ACSHELL_PRESENTATION @"ACShell_Presentation"

enum ACPresentationDoubleClicked {
    ACShellOpenPresentation,
    ACShellPlayPresentation,
    ACShellOpenEditWindow
};

#define AC_SHELL_TOOLBAR_ITEM_START  @"ACShellToolbarItemStart"
#define AC_SHELL_TOOLBAR_ITEM_SYNC   @"ACShellToolbarItemSync"
#define AC_SHELL_TOOLBAR_ITEM_UPLOAD @"ACShellToolbarItemUpload"
#define AC_SHELL_TOOLBAR_ITEM_SEARCH @"ACShellToolbarItemSearch"

@interface ACShellController ()

@property (readonly) NSString* librarySource;

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
@synthesize removeButton;

+ (void) initialize {
	NSString * filepath = [[NSBundle mainBundle] pathForResource: @"defaults" ofType: @"plist"];
	[[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithContentsOfFile: filepath]];
}

- (id) init {
	self = [super init];
	if (self != nil) {		        
        presentationLibrary = [[PresentationLibrary libraryFromSettingsFile] retain];

		presentationWindowController = [[PresentationWindowController alloc] init];
        preferenceWindowController = [[PreferenceWindowController alloc] init];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusText:)
                                                 name:NSTableViewSelectionDidChangeNotification object:presentationTable];
	
	[self bind: @"currentPresentationList" toObject:collectionTreeController withKeyPath:@"selection.presentations" options:nil];
    
    rsyncController.documentWindow = self.browserWindow;
    
    [self updateSyncFailedWarning];
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
    [rsyncController uploadWithSource: self.libraryDirPath destination: self.librarySource];
}

- (IBAction)remove: (id)sender {
	if ([browserWindow firstResponder] == presentationTable) {
		[self removePresentation:sender];			
	} else if ([browserWindow firstResponder] == collectionView) {
		[self removeCollection:self];
	}
}

- (IBAction)addPresentation: sender { [editWindowController add]; }

- (IBAction)openPresentation: (id)sender {
	if (sender == presentationTable) {
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
                [editWindowController edit: presentation];
                break;
            default:
                break;
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
    NSIndexPath *selectedPath = [collectionTreeController selectionIndexPath];
	if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
        NSBeep();
		return;
	}

    BOOL deleteIt = [self runSuppressableBooleanDialogWithIdentifier: @"DeletePresentationFromCollection"
                                                             message: ACSHELL_STR_DELETE_PRESENTATION
                                                            okButton: ACSHELL_STR_DELETE
                                                        cancelButton: ACSHELL_STR_CANCEL];
    if (deleteIt) {
        [presentationsArrayController removeObjects: [presentationsArrayController selectedObjects]];
    }
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


- (void)setCurrentPresentationList:(NSMutableArray *)newArray {
	if (currentPresentationList != newArray) {
		[currentPresentationList release];
		currentPresentationList = [newArray retain];
		
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

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [removeButton setEnabled: [self isCollectionSelected]];
    [self updateStatusText: nil];
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
- (void) keynoteDidStopPresentation:(KeynoteHandler *)aKeynote {
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[self browserWindow] makeKeyAndOrderFront:nil];
}

#pragma mark -
#pragma mark RsyncControllerDelegate Protocol Methods
- (void)rsync:(RsyncController *) controller didFinishSyncingSuccesful:(BOOL)successFlag {
    self.presentationLibrary.syncSuccessful = successFlag;
    [self updateSyncFailedWarning];
	if (successFlag) {
		[self load];
	}
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
	[[NSUserDefaults standardUserDefaults] synchronize];
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
    unsigned selectedItems =     [[presentationTable selectedRowIndexes] count];
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
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
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
@end