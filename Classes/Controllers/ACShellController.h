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
@property (retain, nonatomic) IBOutlet NSSegmentedControl * collectionActions;
@property (retain, nonatomic) IBOutlet NSMenuItem * editPresentationMenuItem;
@property (retain, nonatomic) IBOutlet NSView * leftSplitPane;
@property (retain, nonatomic) IBOutlet NSView * rightSplitPane;

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
