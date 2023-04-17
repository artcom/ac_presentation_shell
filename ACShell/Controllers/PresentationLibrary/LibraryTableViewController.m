//
//  LibraryTableViewController.m
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import "LibraryTableViewController.h"
#import "ACShellCollection.h"
#import "Presentation.h"
#import "default_keys.h"
#import "localized_text_keys.h"

#define ACSHELL_PRESENTATION @"ACShell_Presentation"
#define AC_SHELL_SEARCH_MAX_RESULTS  1000

enum ACPresentationDoubleClicked {
    ACShellOpenPresentation,
    ACShellPlayPresentation,
    ACShellOpenEditWindow
};

@interface LibraryTableViewController ()

@end

@implementation LibraryTableViewController
@synthesize currentPresentationList;

- (void)viewDidLoad
{
    [self.presentationTable registerForDraggedTypes:[NSArray arrayWithObject:ACSHELL_PRESENTATION]];
    [self.presentationTable setTarget:self];
    [self.presentationTable setDoubleAction:@selector(openPresentation:)];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"year" ascending:NO];
    self.userSortDescriptor = sortDescriptor;
    [self.presentationTable setSortDescriptors:@[self.userSortDescriptor]];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(presentationSelectionDidChange:)
                                               name:NSTableViewSelectionDidChangeNotification object:self.presentationTable];
    
    [self presentationTableColumnOrderDidChange: nil];
    [NSNotificationCenter.defaultCenter addObserver: self
                                           selector: @selector(presentationTableColumnOrderDidChange:)
                                               name: NSTableViewColumnDidMoveNotification
                                             object:self.presentationTable];
}

- (NSArray *)selectedPresentations
{
    NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES AND isComplete == YES"];
    return [[self.presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
}

- (BOOL)hasPresentationSelected
{
    return self.presentationTable.selectedRowIndexes.count > 0;
}

- (NSMutableArray*) currentPresentationList {
    if (![self.presentationLibrary hasLibrary]) {
        return NSMutableArray.array;
    }
    return currentPresentationList;
}

- (void)setCurrentPresentationList:(NSMutableArray *)newArray {
    if (currentPresentationList != newArray) {
        currentPresentationList = newArray;
        [self.delegate libraryTableViewController:self updatePresentationList:currentPresentationList];
    }
    [self updateStatusText:nil];
    [self.presentationTable deselectAll:nil];
}

- (void)updatePresentationFilter:(id)sender
{
    NSString *searchString = [sender stringValue];
    
    // If there is no search query, remove any existing filter and sort using user-defined sort
    if ([searchString isEqualToString:@""]) {
        [self.presentationsArrayController setFilterPredicate:nil];
        [self.presentationTable setSortDescriptors:@[self.userSortDescriptor]];
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
    __weak LibraryTableViewController *weakSelf = self;
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

- (void) presentationTableColumnOrderDidChange: (id) aNotification {
    NSMenu * menu = [[NSMenu alloc] initWithTitle: @""];
    NSArray * tableColumns = [self.presentationTable tableColumns];
    for (NSTableColumn * c in tableColumns) {
        NSMenuItem * item = [menu addItemWithTitle: NSLocalizedString([c identifier], nil)
                                            action: @selector(userDidHidePresentationColumn:)
                                     keyEquivalent: @""];
        [item setTarget: self];
        [item setState: [c isHidden] ? NSControlStateValueOff : NSControlStateValueOn];
        [item setRepresentedObject: c];
    }
    [[self.presentationTable headerView] setMenu: menu];
}


- (void) presentationSelectionDidChange: (id) sender {
    [self updateStatusText:sender];
}

- (void)updateStatusText:(id)sender
{
    NSUInteger selectedItems = [[self.presentationTable selectedRowIndexes] count];
    if ( ! [self.presentationLibrary hasLibrary]) {
        [self.statusText setStringValue: NSLocalizedString(ACSHELL_STR_NO_LIBRARY, nil)];
    } else if (selectedItems > 0) {
        [self.statusText setStringValue: [NSString stringWithFormat: NSLocalizedString(ACSHELL_STR_N_OF_M_PRESENTATIONS, nil),
                                          selectedItems, [[self.presentationsArrayController arrangedObjects] count]]];
    } else {
        [self.statusText setStringValue: [NSString stringWithFormat: NSLocalizedString(ACSHELL_STR_N_PRESENTATIONS, nil), self.currentPresentationList.count]];
    }
}

- (void) userDidHidePresentationColumn: (id) sender {
    NSTableColumn * column = [sender representedObject];
    [column setHidden: ! [column isHidden]];
    [sender setState: [column isHidden] ? NSControlStateValueOff : NSControlStateValueOn];
}

- (void)openPresentation: (id)sender {
    if (sender == self.presentationTable) {
        if ([[self.presentationsArrayController selectedObjects] count] > 0) {
            Presentation *presentation = [[self.presentationsArrayController selectedObjects] objectAtIndex:0];
            int doubleClickSetting = [[NSUserDefaults.standardUserDefaults objectForKey: ACSHELL_DEFAULT_KEY_PRESENTATION_DOUBLE_CLICKED] intValue];
            switch (doubleClickSetting) {
                case ACShellOpenPresentation:
                    [self.delegate libraryTableViewController:self openPresentation:presentation];
                    break;
                case ACShellPlayPresentation:
                    [self.delegate libraryTableViewController:self playPresentation:presentation];
                    break;
                case ACShellOpenEditWindow:
                    [self.delegate libraryTableViewController:self editPresentation:presentation];
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark -
#pragma mark NSTableViewDelegate Protocol Methods

- (BOOL) tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes requiringSecureCoding:NO error:NULL];
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
        [self.presentationsArrayController filterPredicate] == nil)
    {
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

- (BOOL) tableView: (NSTableView*) tableView acceptDrop: (id<NSDraggingInfo>) info
               row: (NSInteger) row dropOperation: (NSTableViewDropOperation) dropOperation
{
    NSData *rowsData = [[info draggingPasteboard] dataForType: ACSHELL_PRESENTATION];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchivedObjectOfClass:NSIndexSet.class fromData:rowsData error:NULL];
    
    [self moveObjectsInArrangedObjectsFromIndexes:rowIndexes toIndex:row];
    
    NSInteger rowsAbove = [self rowsAboveRow:row inIndexSet:rowIndexes];
    NSRange range = NSMakeRange(row - rowsAbove, [rowIndexes count]);
    rowIndexes = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.presentationsArrayController setSelectionIndexes:rowIndexes];
    
    NSSortDescriptor * sort = [[self.presentationsArrayController sortDescriptors] objectAtIndex: 0];
    NSArray * items = [self.presentationsArrayController arrangedObjects];
    BOOL isAscending = [sort ascending];
    NSUInteger index = isAscending ? 1 : [items count];
    for (Presentation* p in items) {
        p.order = index;
        index += (isAscending ? 1 : -1);
    }
    
    return YES;
}

-(void) moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet*)indexSet toIndex:(NSUInteger)insertIndex {
    NSArray *objects = [self.presentationsArrayController arrangedObjects];
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
        [self.presentationsArrayController removeObjectAtArrangedObjectIndex:removeIndex];
        [self.presentationsArrayController insertObject:object atArrangedObjectIndex:insertIndex];
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

@end
