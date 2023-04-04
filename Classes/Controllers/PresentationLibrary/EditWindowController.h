//
//  EditWindowController.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressDelegateProtocol.h"
#import "PresentationLibrary.h"
#import "Presentation.h"
#import "KeynoteDropper.h"
#import "FileDraglet.h"

@interface EditWindowController : NSWindowController
<ProgressDelegateProtocol, KeynoteDropperDelegate, NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) PresentationLibrary *presentationLibrary;
@property (nonatomic, strong) Presentation *presentation;

@property (weak, nonatomic) IBOutlet FileDraglet * droppedThumbnail;
@property (weak, nonatomic) IBOutlet NSTextField * thumbnailFileLabel;

@property (weak, nonatomic) IBOutlet KeynoteDropper * droppedKeynote;
@property (weak, nonatomic) IBOutlet NSTextField * keynoteFileLabel;
@property (weak, nonatomic) IBOutlet NSButton * editButton;

@property (weak, nonatomic) IBOutlet NSTextField * titleField;
@property (weak, nonatomic) IBOutlet NSStackView *categoryStack;
@property (weak, nonatomic) IBOutlet NSTableView *tagList;
@property (weak, nonatomic) IBOutlet NSTextField *tagInput;
@property (weak, nonatomic) IBOutlet NSSegmentedControl *tagControls;

@property (weak, nonatomic) IBOutlet NSTextField * yearField;
@property (weak, nonatomic) IBOutlet NSButton * highlightCheckbox;

@property (weak, nonatomic) IBOutlet NSButton * deleteButton;
@property (weak, nonatomic) IBOutlet NSButton * okButton;

@property (strong, nonatomic) IBOutlet NSWindow* progressSheet;
@property (weak, nonatomic) IBOutlet NSTextField* progressTitle;
@property (weak, nonatomic) IBOutlet NSTextField* progressMessage;
@property (weak, nonatomic) IBOutlet NSProgressIndicator* progressBar;
@property (weak, nonatomic) IBOutlet NSTextField* progressText;

- (id) initWithPresentationLibrary: (PresentationLibrary *) thePresentationLibrary;

- (IBAction) userDidConfirmEdit: (id) sender;
- (IBAction) userDidCancelEdit: (id) sender;
- (IBAction) userDidDropThumbnail: (id) sender;
- (IBAction) userDidChangeTitle: (id) sender;
- (IBAction) userWantsToDeletePresentation: (id) sender;

- (IBAction)tagActionClicked:(id)sender;

- (void) editWithKeynote;
- (void) edit: (Presentation*) aPresentation;
- (void) add;

@end
