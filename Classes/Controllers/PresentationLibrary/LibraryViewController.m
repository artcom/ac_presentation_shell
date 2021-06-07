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
    [self beautifyOutlineView];
    [self updateSyncFailedWarning];
}

-(NSMutableArray*) library {
    return [PresentationLibrary sharedInstance].library.children;
}

-(void) setLibrary:(NSMutableArray *) array {
    [PresentationLibrary sharedInstance].library.children = array;
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
    if ([selectedPath length] < 2 || [selectedPath indexAtPosition:0] == 0) {
        return NO;
    }
    return YES;
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
    
    BOOL deleteIt = [self runSuppressableBooleanDialogWithIdentifier: @"DeleteCollection"
                                                             message: ACSHELL_STR_DELETE_COLLECTION
                                                            okButton: ACSHELL_STR_DELETE
                                                        cancelButton: ACSHELL_STR_CANCEL];
    if (deleteIt) {
        [self.collectionTreeController removeObjectAtArrangedObjectIndexPath:selectedPath];
        
        if ([self.presentationLibrary collectionCount] == 0) {
            [self.collectionView deselectAll: self];
        }
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

- (IBAction)collectionActionClicked: (id) sender
{
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment: clickedSegment];
    switch (clickedSegmentTag) {
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
    
    ACShellCollection * selectedCollection = [[self.collectionTreeController selectedObjects] objectAtIndex: 0];
    ACShellCollection * droppedOnCollection = (ACShellCollection *)[item representedObject];
    if (selectedCollection == droppedOnCollection) {
        return NSDragOperationNone;
    }
    
    return NSDragOperationLink;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    /*
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
     */
    // TODO: reactivate later
    return YES;
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

@end
