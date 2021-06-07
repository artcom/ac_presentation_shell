//
//  PresentationTableViewController.m
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import "PresentationTableViewController.h"
#import "ACShellCollection.h"

@interface PresentationTableViewController ()

@end

@implementation PresentationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}



- (NSArray *)selectedPresentations {
    NSPredicate *selected = [NSPredicate predicateWithFormat:@"selected == YES AND isComplete == YES"];
    return [[self.presentationsArrayController arrangedObjects] filteredArrayUsingPredicate:selected];
}

@end
