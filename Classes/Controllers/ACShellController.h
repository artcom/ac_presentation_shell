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
#import "SetupAssistantDelegateProtocol.h"

@class PresentationWindowController;
@class PreferenceController;
@class PresentationLibrary;
@class ACShellCollection;
@class EditWindowController;
@class SetupAssistantController;

@interface ACShellController : NSObject <KeynoteDelegate, RsyncControllerDelegate, SetupAssistantDelegate,
                                            NSOutlineViewDelegate, NSOutlineViewDataSource, NSTableViewDelegate,
                                            NSTableViewDataSource, NSToolbarDelegate, NSSplitViewDelegate> 
{
	PresentationLibrary *presentationLibrary;

	PresentationWindowController *presentationWindowController;
    PreferenceController * preferenceController;
    EditWindowController * editWindowController;
	RsyncController *rsyncController;
    SetupAssistantController * setupAssistant;	
    
	NSOutlineView *collectionView;
	NSTableView *presentationTable;
	
	NSArrayController *presentationsArrayController;
	NSTreeController *collectionTreeController;

    NSTextField * statusLine;

    NSWindow *browserWindow;
	NSProgressIndicator *progressSpinner;
	
	NSMutableArray *currentPresentationList;
    NSImageView * warningIcon;
	
	BOOL editingEnabled;
    NSSegmentedControl * collectionActions;
    
    NSMenuItem * editPresentationMenuItem;
    
    NSView * leftSplitPane;
    NSView * rightSplitPane;
}

@property (retain) NSSortDescriptor *userSortDescriptor;
@property (retain) PresentationLibrary *presentationLibrary;
@property (retain, nonatomic) NSMutableArray * library;

@property (assign, nonatomic) IBOutlet NSArrayController *presentationsArrayController;
@property (assign, nonatomic) IBOutlet NSTreeController *collectionTreeController;
@property (assign, nonatomic) IBOutlet NSWindow *browserWindow;
@property (assign, nonatomic) IBOutlet NSOutlineView *collectionView;
@property (assign, nonatomic) IBOutlet NSTableView *presentationTable;
@property (assign, nonatomic) IBOutlet NSTextField *statusLine;
@property (retain, nonatomic) NSMutableArray * currentPresentationList;
@property (assign, nonatomic) IBOutlet NSImageView * warningIcon;
@property (assign, nonatomic) IBOutlet NSSegmentedControl * collectionActions;
@property (assign, nonatomic) IBOutlet NSMenuItem * editPresentationMenuItem;
@property (assign, nonatomic) IBOutlet NSView * leftSplitPane;
@property (assign, nonatomic) IBOutlet NSView * rightSplitPane;

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
- (IBAction)editPresentation: (id) sender;
- (IBAction)collectionActionClicked: (id) sender;

- (IBAction)showPreferences: (id)sender;

- (IBAction)load;

- (NSArray *)selectedPresentations;

@end
