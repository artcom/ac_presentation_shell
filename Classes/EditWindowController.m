//
//  EditWindowController.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "EditWindowController.h"
#import "Presentation.h"
#import "ACShellController.h"
#import "PresentationLibrary.h"
#import "KeynoteDropper.h"
#import "KeynoteHandler.h"

@interface EditWindowController ()

- (void) postEditCleanUp;
- (void) updateFileLabel: (NSTextField*) textLabel filename: (NSString*) aFilename;
- (void) setGuiValues;

@end

@implementation EditWindowController
@synthesize editPresentation;
@synthesize droppedKeynote;
@synthesize thumbnailFileLabel;
@synthesize keynoteFileLabel;

- (id) initWithShellController: (ACShellController*) theShellController {
    self = [super initWithWindowNibName: @"PresentationEditWindow"];
    if (self != nil) {
        shellController = [theShellController retain];
    }
    return self;
}

- (void) awakeFromNib {
    [self setGuiValues];
}

- (void) dealloc {
    [shellController release];
    
    [super dealloc];
}

- (void) edit: (Presentation*) aPresentation {

    originalPresentation = [aPresentation retain];
    self.editPresentation = [aPresentation copy];
    editNode = [[[originalPresentation xmlNode] copyWithZone: nil] retain];
    self.editPresentation.context = self;
    
    [self setGuiValues];
    
    [self showWindow: nil];
}

- (IBAction) userDidConfirmEdit: (id) sender {
    NSLog(@"edit confirmed");
    BOOL xmlChanged = [originalPresentation updateFromPresentation: editPresentation
                                                  newThumbnailPath: thumbnailFilename
                                                    newKeynotePath: keynoteFilename];
    if (xmlChanged) {
        [[shellController presentationLibrary] saveXmlLibrary];
    }
    [self postEditCleanUp];
}

- (IBAction) userDidCancelEdit: (id) sender {
    NSLog(@"edit canceld");
    [self postEditCleanUp];
}

- (IBAction) userDidDropThumbnail: (id) sender {
    thumbnailFilename = [[sender filename] retain];
    [self updateFileLabel: thumbnailFileLabel filename: [sender filename]];
}

- (IBAction) userDidDropKeynote: (id) sender {
    keynoteFilename = [[sender filename] retain];
    [self updateFileLabel: keynoteFileLabel filename: [sender filename]];
}

- (IBAction) editWithKeynote: (id) sender {
    [[KeynoteHandler sharedHandler] open: editPresentation.absolutePresentationPath];
}

- (void) postEditCleanUp {
    [self close];
    [originalPresentation release];
    originalPresentation = nil;
    [editPresentation release];
    editPresentation = nil;
    [editNode release];
    editNode = nil;
    [thumbnailFilename release];
    thumbnailFilename = nil;
    [keynoteFilename release];
    keynoteFilename = nil;
}

#pragma mark -
#pragma mark PresentationDataContext Protocol Methods
- (NSXMLElement*) xmlNode:(id)presentationId {
    return editNode;
}

- (NSString*) libraryDirPath { return shellController.libraryDirPath; }


- (void) updateFileLabel: (NSTextField*) textLabel filename: (NSString*) aFilename {
    textLabel.stringValue = [aFilename lastPathComponent];
}

- (void) setGuiValues {
    [self updateFileLabel: thumbnailFileLabel filename: editPresentation.absoluteThumbnailPath];
    [self updateFileLabel: keynoteFileLabel filename: editPresentation.absolutePresentationPath];
    droppedKeynote.filename = editPresentation.absolutePresentationPath;
}

@end
