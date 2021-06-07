//
//  LibraryTableViewController.m
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import "LibraryTableViewController.h"
#import "ACShellCollection.h"

@interface LibraryTableViewController ()

@end

@implementation LibraryTableViewController

- (NSArray *)selectedPresentations {
    NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES AND isComplete == YES"];
    return [[self.presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
}

@end
