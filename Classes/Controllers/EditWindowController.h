//
//  EditWindowController.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileCopyController.h"

@class Presentation;
@class ACShellController;
@class KeynoteDropper;
@class NSImageViewWithDroppedFilename;

@interface EditWindowController : NSWindowController <FileCopyControllerDelegate> {
    Presentation * presentation;

    KeynoteDropper * droppedKeynote;
    NSTextField * keynoteFileLabel;

    NSTextView * titleView;
    
    NSImageViewWithDroppedFilename * droppedThumbnail;
    
    NSButton * highlightCheckbox;
    
    ACShellController * shellController;
}

@property (retain, nonatomic) IBOutlet KeynoteDropper * droppedKeynote;
@property (retain, nonatomic) IBOutlet NSTextField * keynoteFileLabel;

@property (retain, nonatomic) IBOutlet NSTextView * titleView;
@property (retain, nonatomic) IBOutlet NSImageViewWithDroppedFilename * droppedThumbnail;

@property (retain, nonatomic) IBOutlet NSButton * highlightCheckbox;

- (id) initWithShellController:(ACShellController *)theShellController;

- (IBAction) userDidConfirmEdit: (id) sender;
- (IBAction) userDidCancelEdit: (id) sender;
- (IBAction) userDidDropThumbnail: (id) sender;
- (IBAction) userDidDropKeynote: (id) sender;
- (IBAction) editWithKeynote: (id) sender;

- (void) edit: (Presentation*) aPresentation;
- (void) add;


@end