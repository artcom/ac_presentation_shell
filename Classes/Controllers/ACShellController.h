//
//  ACShellController.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KeynoteDelegate.h"
#import "RsyncController.h"

@class PresentationWindowController;
@class PreferenceWindowController;
@class PresentationLibrary;
@class ACShellCollection;
@class EditWindowController;

@interface ACShellController : NSObject <KeynoteDelegate, RsyncControllerDelegate, NSOutlineViewDelegate, 
											NSOutlineViewDataSource, NSTableViewDelegate, NSTableViewDataSource,
                                            NSToolbarDelegate> 
{
	PresentationLibrary *presentationLibrary;

	PresentationWindowController *presentationWindowController;
    PreferenceWindowController * preferenceWindowController;
    EditWindowController * editWindowController;
    
	NSOutlineView *collectionView;
	NSTableView *presentationTable;
	
	NSArrayController *presentationsArrayController;
	NSTreeController *collectionTreeController;

    NSTextField * statusLine;

    NSWindow *browserWindow;
	NSProgressIndicator *progressSpinner;
	
	RsyncController *rsyncController;
	
	NSMutableArray *currentPresentationList;
    NSImageView * warningIcon;
	
	BOOL editingEnabled;
	NSButton * removeButton;
}

@property (retain) PresentationLibrary *presentationLibrary;
@property (retain, nonatomic) NSMutableArray * library;

@property (retain, nonatomic) IBOutlet NSArrayController *presentationsArrayController;
@property (retain, nonatomic) IBOutlet NSTreeController *collectionTreeController;
@property (retain, nonatomic) IBOutlet NSWindow *browserWindow;
@property (retain, nonatomic) IBOutlet NSOutlineView *collectionView;
@property (retain, nonatomic) IBOutlet NSTableView *presentationTable;
@property (retain, nonatomic) IBOutlet NSTextField *statusLine;
@property (retain, nonatomic) NSMutableArray * currentPresentationList;
@property (retain, nonatomic) IBOutlet NSImageView * warningIcon;
@property (retain, nonatomic) IBOutlet NSButton * removeButton;

@property (readonly) NSString* libraryDirPath;
@property (readonly) BOOL editingEnabled;

- (IBAction)play: (id)sender;
- (IBAction)sync: (id)sender;
- (IBAction)upload: (id) sender;
- (IBAction)remove: (id)sender;
- (IBAction)addPresentation: sender;
- (IBAction)addCollection: (id)sender;
- (IBAction)removeCollection: (id)sender;
- (IBAction)removePresentation: (id) sender;
- (IBAction)openPresentation: (id)sender;
- (IBAction)updatePresentationFilter: (id) sender;

- (IBAction)showPreferences: (id)sender;

- (IBAction)load;

- (NSArray *)selectedPresentations;

@end