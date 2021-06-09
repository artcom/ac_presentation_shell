//
//  LibraryTableViewController.h
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationLibrary.h"

@protocol LibraryTableViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface LibraryTableViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) id<LibraryTableViewControllerDelegate> delegate;
@property (strong) PresentationLibrary *presentationLibrary;
@property (strong, nonatomic) NSMutableArray *currentPresentationList;
@property (strong, readonly) NSArray *selectedPresentations;
@property (strong) NSSortDescriptor *userSortDescriptor;

@property (weak, nonatomic) IBOutlet NSArrayController *presentationsArrayController;
@property (weak) IBOutlet NSTableView *presentationTable;

- (void)updatePresentationFilter:(id)sender;
@end

@protocol LibraryTableViewControllerDelegate <NSObject>
- (void)libraryTableViewController:(LibraryTableViewController *)controller openPresentation:(Presentation *)presentation;
- (void)libraryTableViewController:(LibraryTableViewController *)controller playPresentation:(Presentation *)presentation;
- (void)libraryTableViewController:(LibraryTableViewController *)controller editPresentation:(Presentation *)presentation;
- (void)libraryTableViewController:(LibraryTableViewController *)controller updatePresentationList:(NSMutableArray *)presentationList;
@end

NS_ASSUME_NONNULL_END
