//
//  LibraryViewController.m
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import "LibraryViewController.h"
#import "PresentationLibrary.h"
#import "ACShellCollection.h"
#import "localized_text_keys.h"
#import "NSAlert+Dialogs.h"

#define ACSHELL_PRESENTATION @"ACShell_Presentation"

// keep this in sync with the interface builder tags
enum CollectionActionTags {
    AddCollectionAction,
    DeleteCollectionAction
};

@interface LibraryViewController ()

@end

@implementation LibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.presentationLibrary = [PresentationLibrary sharedInstance];
    
    [self.collectionView registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
    
    [self beautifyOutlineView];
    [self updateSyncFailedWarning];
}

- (NSMutableArray*) library {
    return [PresentationLibrary sharedInstance].library.children;
}

- (void) setLibrary:(NSMutableArray *) array {
    [PresentationLibrary sharedInstance].library.children = array;
}

- (void)setPresentationList:(NSMutableArray *)presentationList
{
    if ([[self.collectionTreeController selectedObjects] count] > 0) {
        [[[self.collectionTreeController selectedObjects] objectAtIndex:0] setPresentations:presentationList];
    }
}

- (BOOL) isPresentationRemovable {
    NSIndexPath *selectedPath = [self.collectionTreeController selectionIndexPath];
    if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
        return NO;
    }
    return YES;
}

- (void) updateSyncFailedWarning {
    BOOL lastSyncOk = self.presentationLibrary.syncSuccessful;
    [self.warningIcon setHidden: lastSyncOk];
    if ( ! lastSyncOk ) {
        [self.warningIcon setToolTip: NSLocalizedString(ACSHELL_STR_LAST_SYNC_FAILED, nil)];
    }
}

- (BOOL) isCollectionSelected {
    NSIndexPath *selectedPath = [self.collectionTreeController selectionIndexPath];
    return [selectedPath indexAtPosition:0] == 1;
}

- (void)addCollection {
    ACShellCollection *list = [ACShellCollection collectionWithName:NSLocalizedString(ACSHELL_STR_NEW_COLLECTION, nil)
                                                      presentations:[NSMutableArray array] children:nil];
    
    NSUInteger indices[] = {1,[self.presentationLibrary collectionCount]};
    [self.collectionTreeController insertObject:list atArrangedObjectIndexPath:[NSIndexPath indexPathWithIndexes:indices length:2]];
    [self.collectionTreeController setSelectionIndexPath: [NSIndexPath indexPathWithIndexes: indices length: 2]];
    [self.collectionView editColumn: 0 row: [self.collectionView selectedRow] withEvent:nil select:YES];
}

- (void)removeCollection {
    NSIndexPath *selectedPath = [self.collectionTreeController selectionIndexPath];
    if (! [self isCollectionSelected]) {
        NSBeep();
        return;
    }
    
    BOOL deleteIt = [NSAlert runSuppressableBooleanDialogWithIdentifier: ACSHELL_STR_DELETE_COLLECTION
                                                                message: ACSHELL_STR_DELETE_COLLECTION
                                                               okButton: ACSHELL_STR_DELETE
                                                           cancelButton: ACSHELL_STR_CANCEL
                                                      destructiveAction:YES];
    if (deleteIt) {
        [self.collectionTreeController removeObjectAtArrangedObjectIndexPath:selectedPath];
        
        if ([self.presentationLibrary collectionCount] == 0) {
            [self.collectionView deselectAll: self];
        }
    }
}

- (IBAction)collectionActionClicked: (id) sender
{
    NSInteger selectedSegment = [sender selectedSegment];
    NSInteger selectedSegmentTag = [[sender cell] tagForSegment:selectedSegment];
    switch (selectedSegmentTag) {
        case AddCollectionAction:
            [self addCollection];
            break;
        case DeleteCollectionAction:
            [self removeCollection];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark  NSOutlineViewDataSource Protocol Methods

- (BOOL) outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:ACSHELL_PRESENTATION];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchivedObjectOfClass:NSIndexSet.class fromData:rowData error:nil];
    
    
    NSArray * arrangedItems = [self.presentationsArrayController arrangedObjects];
    NSArray * draggedItems = [arrangedItems objectsAtIndexes: rowIndexes];
    NSMutableArray * newItems = [[NSMutableArray alloc] initWithArray: draggedItems copyItems: YES];
    
    ACShellCollection *collection = (ACShellCollection *)[item representedObject];
    
    if ([self handleDuplicates: newItems inCollection: collection]) {
        NSUInteger order = [collection.presentations count] + 1;
        for (Presentation* p in newItems) {
            p.order = order++;
        }
        [collection.presentations addObjectsFromArray: newItems];
    }
    return YES;
}

- (NSDragOperation) outlineView:(NSOutlineView *)outlineView
                   validateDrop:(id <NSDraggingInfo>)info
                   proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    
    if (index != -1) return NSDragOperationNone;
    
    ACShellCollection *selectedCollection = [[self.collectionTreeController selectedObjects] objectAtIndex: 0];
    ACShellCollection *droppedOnCollection = (ACShellCollection *)[item representedObject];
    if (selectedCollection == droppedOnCollection) return NSDragOperationNone;
    
    if (![self isCollection:item]) return NSDragOperationNone;
    
    return NSDragOperationLink;
}


#pragma mark -
#pragma mark  NSOutlineViewDelegate Protocol Methods

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return (![self isToplevelGroup: item]);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [self isToplevelGroup: item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return (![self isToplevelGroup: item] && ![self isStaticCategory: item]);
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    [self.collectionActions setEnabled: [self isCollectionSelected] forSegment: DeleteCollectionAction];
}

#pragma mark -
#pragma mark Private Methods

- (void)beautifyOutlineView {
    [self.collectionView expandItem:nil expandChildren:YES];
    
    NSTreeNode *firstNode = [self.collectionView itemAtRow:0];
    NSTreeNode *allItem = [[firstNode childNodes] objectAtIndex:0];
    NSUInteger row = [self.collectionView rowForItem:allItem];
    [self.collectionView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (BOOL) isToplevelGroup: (id) item {
    return ([[item indexPath] length] == 1);
}

- (BOOL) isStaticCategory: (id) item {
    return ([[item indexPath] length] == 2 && [[item indexPath] indexAtPosition: 0] == 0);
}

- (BOOL) isCollection:(id)item {
    return ([[item indexPath] length] == 2 && [[item indexPath] indexAtPosition: 0] == 1);
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

@end
