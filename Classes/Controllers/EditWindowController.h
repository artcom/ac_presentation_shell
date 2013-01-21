//
//  EditWindowController.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressDelegateProtocol.h"

@class Presentation;
@class ACShellController;
@class KeynoteDropper;
@class NSImageViewWithDroppedFilename;

@interface EditWindowController : NSWindowController <ProgressDelegateProtocol>
{
    Presentation * presentation;

    KeynoteDropper * droppedKeynote;
    NSTextField * keynoteFileLabel;
    NSButton * editButton;
    
    NSTextField * titleField;
    NSImageViewWithDroppedFilename * droppedThumbnail;
    NSTextField * thumbnailFileLabel;

    NSButton * highlightCheckbox;
    NSTextField * yearField;
    
    NSButton * okButton;
    NSButton * deleteButton;

    NSWindow *            progressSheet;
    NSTextField *         progressTitle;
    NSTextField *         progressMessage;
    NSProgressIndicator * progressBar;
    NSTextField *         progressText;
    
    ACShellController * shellController;
}

@property (assign, nonatomic) IBOutlet KeynoteDropper * droppedKeynote;
@property (assign, nonatomic) IBOutlet NSTextField * keynoteFileLabel;
@property (assign, nonatomic) IBOutlet NSButton * editButton;

@property (assign, nonatomic) IBOutlet NSTextField * titleField;
@property (assign, nonatomic) IBOutlet NSImageViewWithDroppedFilename * droppedThumbnail;
@property (assign, nonatomic) IBOutlet NSTextField * thumbnailFileLabel;

@property (assign, nonatomic) IBOutlet NSButton * highlightCheckbox;
@property (assign, nonatomic) IBOutlet NSTextField * yearField;

@property (assign, nonatomic) IBOutlet NSButton * okButton;
@property (assign, nonatomic) IBOutlet NSButton * deleteButton;

@property (assign, nonatomic) IBOutlet NSWindow* progressSheet;
@property (assign, nonatomic) IBOutlet NSTextField* progressTitle;
@property (assign, nonatomic) IBOutlet NSTextField* progressMessage;
@property (assign, nonatomic) IBOutlet NSProgressIndicator* progressBar;
@property (assign, nonatomic) IBOutlet NSTextField* progressText;

- (id) initWithShellController:(ACShellController *)theShellController;

- (IBAction) userDidConfirmEdit: (id) sender;
- (IBAction) userDidCancelEdit: (id) sender;
- (IBAction) userDidDropThumbnail: (id) sender;
- (IBAction) userDidDropKeynote: (id) sender;
- (IBAction) editWithKeynote: (id) sender;
- (IBAction) userDidChangeTitle: (id) sender;
- (IBAction) userWantsToDeletePresentation: (id) sender;
- (IBAction) chooseKeynoteFile: (id) sender;
- (IBAction) chooseThumbnailFile: (id) sender;



- (void) edit: (Presentation*) aPresentation;
- (void) add;


@end
