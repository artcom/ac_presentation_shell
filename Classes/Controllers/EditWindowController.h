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

@interface EditWindowController : NSWindowController <ProgressDelegateProtocol, NSTextFieldDelegate>
{
    Presentation * presentation;

    KeynoteDropper * __weak droppedKeynote;
    NSTextField * __weak keynoteFileLabel;
    NSButton * __weak editButton;
    
    NSTextField * __weak titleField;
    NSImageViewWithDroppedFilename * __weak droppedThumbnail;
    NSTextField * __weak thumbnailFileLabel;

    NSButton * __weak highlightCheckbox;
    NSTextField * __weak yearField;
    
    NSButton * __weak okButton;
    NSButton * __weak deleteButton;

    NSWindow *            progressSheet;
    NSTextField *         __weak progressTitle;
    NSTextField *         __weak progressMessage;
    NSProgressIndicator * __weak progressBar;
    NSTextField *         __weak progressText;
    
    ACShellController * shellController;
}

@property (weak, nonatomic) IBOutlet KeynoteDropper * droppedKeynote;
@property (weak, nonatomic) IBOutlet NSTextField * keynoteFileLabel;
@property (weak, nonatomic) IBOutlet NSButton * editButton;

@property (weak, nonatomic) IBOutlet NSTextField * titleField;
@property (weak, nonatomic) IBOutlet NSImageViewWithDroppedFilename * droppedThumbnail;
@property (weak, nonatomic) IBOutlet NSTextField * thumbnailFileLabel;

@property (weak, nonatomic) IBOutlet NSButton * highlightCheckbox;
@property (weak, nonatomic) IBOutlet NSTextField * yearField;

@property (weak, nonatomic) IBOutlet NSButton * okButton;
@property (weak, nonatomic) IBOutlet NSButton * deleteButton;

@property (strong, nonatomic) IBOutlet NSWindow* progressSheet;
@property (weak, nonatomic) IBOutlet NSTextField* progressTitle;
@property (weak, nonatomic) IBOutlet NSTextField* progressMessage;
@property (weak, nonatomic) IBOutlet NSProgressIndicator* progressBar;
@property (weak, nonatomic) IBOutlet NSTextField* progressText;

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
