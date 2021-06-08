//
//  LibraryTableViewController.h
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface LibraryTableViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (strong) PresentationLibrary *presentationLibrary;
@property (strong, nonatomic) NSMutableArray *currentPresentationList;
@property (strong, readonly) NSArray *selectedPresentations;
@property (strong) NSSortDescriptor *userSortDescriptor;

@property (weak, nonatomic) IBOutlet NSArrayController *presentationsArrayController;
@property (weak) IBOutlet NSTableView *presentationTable;

- (void)updatePresentationFilter:(id)sender;
@end

NS_ASSUME_NONNULL_END
