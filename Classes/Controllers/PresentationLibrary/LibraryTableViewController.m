//
//  LibraryTableViewController.m
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import "LibraryTableViewController.h"
#import "ACShellCollection.h"

#define AC_SHELL_SEARCH_MAX_RESULTS  1000

@interface LibraryTableViewController ()

@end

@implementation LibraryTableViewController


- (void)viewDidLoad
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"year" ascending:NO];
    self.userSortDescriptor = sortDescriptor;
    [self.presentationTable setSortDescriptors:@[self.userSortDescriptor]];
}

- (NSArray *)selectedPresentations
{
    NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES AND isComplete == YES"];
    return [[self.presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
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

@end
