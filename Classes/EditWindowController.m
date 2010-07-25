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

@interface EditWindowController ()

- (void) postEditCleanUp;

@end

@implementation EditWindowController
@synthesize editPresentation;

- (id) initWithShellController: (ACShellController*) theShellController {
    self = [super initWithWindowNibName: @"PresentationEditWindow"];
    if (self != nil) {
        shellController = [theShellController retain];
    }
    return self;
}

- (void) dealloc {
    [editPresentation release];
    [originalPresentation release];
    [shellController release];
    [thumbnailFilename release];
    
    [super dealloc];
}

- (void) edit: (Presentation*) aPresentation {
    originalPresentation = [aPresentation retain];
    self.editPresentation = [aPresentation copy];
    editNode = [[[originalPresentation xmlNode] copyWithZone: nil] retain];
    self.editPresentation.context = self;
    [self showWindow: nil];
}

- (IBAction) userDidConfirmEdit: (id) sender {
    NSLog(@"edit confirmed");
    BOOL xmlChanged = [originalPresentation updateFromPresentation: editPresentation
                                                  newThumbnailPath: thumbnailFilename];
    if (xmlChanged) {
        [[shellController presentationLibrary] saveXmlLibrary];
    }
    [self postEditCleanUp];
}

- (IBAction) userDidCancelEdit: (id) sender {
    NSLog(@"edit canceld");
    [self postEditCleanUp];
}

- (IBAction) userDidDropImage: (id) sender {
    NSLog(@"new image: %@", [sender filename]);
    thumbnailFilename = [[sender filename] retain];
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
}

#pragma mark -
#pragma mark PresentationDataContext Protocol Methods
- (NSXMLElement*) xmlNode:(id)presentationId {
    return editNode;
}

- (NSString*) libraryDirPath { return shellController.libraryDirPath; }

@end
