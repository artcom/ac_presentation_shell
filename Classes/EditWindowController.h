//
//  EditWindowController.h
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PresentationDataContext.h"
#import "FileCopyController.h"

@class Presentation;
@class ACShellController;
@class KeynoteDropper;

@interface EditWindowController : NSWindowController <PresentationDataContext, FileCopyControllerDelegate> {
    Presentation * editPresentation;
    Presentation * originalPresentation;
    
    NSXMLElement * editNode;
    ACShellController * shellController;
    
    NSString * thumbnailFilename;
    NSString * keynoteFilename;
    
    KeynoteDropper * droppedKeynote;
    
    NSTextField * thumbnailFileLabel;
    NSTextField * keynoteFileLabel;
}

@property (retain) Presentation * editPresentation;
@property (retain, nonatomic) IBOutlet KeynoteDropper * droppedKeynote;
@property (retain, nonatomic) IBOutlet NSTextField * thumbnailFileLabel;
@property (retain, nonatomic) IBOutlet NSTextField * keynoteFileLabel;


- (id) initWithShellController:(ACShellController *)theShellController;

- (IBAction) userDidConfirmEdit: (id) sender;
- (IBAction) userDidCancelEdit: (id) sender;
- (IBAction) userDidDropThumbnail: (id) sender;
- (IBAction) userDidDropKeynote: (id) sender;
- (IBAction) editWithKeynote: (id) sender;

- (void) edit: (Presentation*) aPresentation;


@end
