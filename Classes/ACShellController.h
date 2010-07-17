//
//  ACShellController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSTableView-WithDelete.h"

@class PresentationWindowController;
@class PresentationContext;
@class ACShellCollection;


@interface ACShellController : NSObject <DeleteKeyDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource, NSTableViewDelegate, NSTableViewDataSource> {
	PresentationContext *presentationContext;
	
	NSArray *presentations;
	NSMutableArray* categories;

	PresentationWindowController *presentationWindowController;
	NSOutlineView *collectionView;
	NSTableView *presentationTable;
	
	NSArrayController *presentationsArrayController;
	NSTreeController *collectionTreeController;
	NSWindow *syncWindow;
	NSProgressIndicator *progressSpinner;
	
	NSTask *rsyncTask;
}

@property (retain) PresentationContext *presentationContext;
@property (retain, nonatomic) NSArray *presentations;
@property (retain, nonatomic) NSMutableArray *categories;
@property (retain, nonatomic) IBOutlet NSArrayController *presentationsArrayController;
@property (retain, nonatomic) IBOutlet 	NSTreeController *collectionTreeController;
@property (retain, nonatomic) IBOutlet NSWindow *syncWindow;
@property (retain, nonatomic) IBOutlet NSProgressIndicator *progressSpinner;
@property (retain, nonatomic) IBOutlet NSOutlineView *collectionView;
@property (retain, nonatomic) IBOutlet NSTableView *presentationTable;

- (IBAction)play: (id)sender;
- (IBAction)sync: (id)sender;
- (IBAction)abortSync: (id)sender;
- (IBAction)addCollection: (id)sender;
- (IBAction)removeCollection: (id)sender;

- (NSArray *)selectedPresentations;

@end
