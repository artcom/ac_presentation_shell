//
//  LibraryViewController.h
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationLibrary.h"
#import "Presentation.h"

NS_ASSUME_NONNULL_BEGIN

@interface LibraryViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (strong, nonatomic) NSMutableArray *library;
@property (strong, nonatomic) PresentationLibrary *presentationLibrary;

@property (weak, nonatomic) NSArrayController *presentationsArrayController;
@property (weak, nonatomic) IBOutlet NSTreeController *collectionTreeController;
@property (weak, nonatomic) IBOutlet NSOutlineView *collectionView;
@property (weak, nonatomic) IBOutlet NSSegmentedControl * collectionActions;

- (IBAction)collectionActionClicked: (id) sender;

- (BOOL) isCollectionSelected;
- (BOOL) isPresentationRemovable;
- (void)beautifyOutlineView;
- (void)setPresentationList:(NSMutableArray *)presentationList;
- (void)addCollection;
- (void)removeCollection;

@end

NS_ASSUME_NONNULL_END
