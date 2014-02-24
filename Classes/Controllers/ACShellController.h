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
	PresentationWindowController *presentationWindowController;
    PreferenceController * preferenceController;
    EditWindowController * editWindowController;
	RsyncController *rsyncController;
    SetupAssistantController * setupAssistant;	
	NSProgressIndicator *progressSpinner;
	NSMutableArray *currentPresentationList;
	BOOL editingEnabled;
}

@property (strong) NSSortDescriptor *userSortDescriptor;
@property (strong) PresentationLibrary *presentationLibrary;
@property (strong, nonatomic) NSMutableArray * library;

@property (weak, nonatomic) IBOutlet NSArrayController *presentationsArrayController;
@property (weak, nonatomic) IBOutlet NSTreeController *collectionTreeController;
@property (weak, nonatomic) IBOutlet NSWindow *browserWindow;
@property (weak, nonatomic) IBOutlet NSOutlineView *collectionView;
@property (weak, nonatomic) IBOutlet NSTableView *presentationTable;
@property (weak, nonatomic) IBOutlet NSTextField *statusLine;
@property (strong, nonatomic) NSMutableArray * currentPresentationList;
@property (weak, nonatomic) IBOutlet NSImageView * warningIcon;
@property (weak, nonatomic) IBOutlet NSSegmentedControl * collectionActions;
@property (weak, nonatomic) IBOutlet NSMenuItem * editPresentationMenuItem;
@property (weak, nonatomic) IBOutlet NSView * leftSplitPane;
@property (weak, nonatomic) IBOutlet NSView * rightSplitPane;

@property (weak, readonly) NSString* libraryDirPath;
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
