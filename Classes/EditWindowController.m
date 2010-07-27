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
#import "FileCopyController.h"

@interface EditWindowController ()

- (void) postEditCleanUp;
- (void) updateFileLabel: (NSTextField*) textLabel filename: (NSString*) aFilename;
- (void) setGuiValues;

@end

@implementation EditWindowController
@synthesize titleView;
@synthesize droppedKeynote;
@synthesize keynoteFileLabel;
@synthesize droppedThumbnail;
@synthesize highlightCheckbox;

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
    presentation = [aPresentation retain];

    [self setGuiValues];
    
    [self showWindow: nil];
}

- (void) add {
    [self showWindow: nil];
}

- (IBAction) userDidConfirmEdit: (id) sender {
    NSLog(@"edit confirmed");
	
	FileCopyController *fileCopyController = [[FileCopyController alloc] initWithParentWindow:[self window]];
	fileCopyController.delegate = self;
    
	BOOL xmlChanged = [presentation updateWithTitle: [[titleView textStorage] string]
                                      thumbnailPath: droppedThumbnail.filename
                                        keynotePath: droppedKeynote.filename
                                        isHighlight: [highlightCheckbox intValue]
                                     copyController: fileCopyController];

#pragma mark XXX move this to PresentationLibrary
	if (xmlChanged) {
		[[shellController presentationLibrary] saveXmlLibrary];
	}
	[shellController.presentationLibrary flushThumbnailCacheForPresentation:presentation];

//	if (!fileCopyController.isCopying) {
		[self postEditCleanUp];
//	}
		
	[fileCopyController release];
}

- (IBAction) userDidCancelEdit: (id) sender {
    NSLog(@"edit canceld");
    [self postEditCleanUp];
}

- (IBAction) userDidDropThumbnail: (id) sender {
}

- (IBAction) userDidDropKeynote: (id) sender {
}

- (IBAction) editWithKeynote: (id) sender {
    [[KeynoteHandler sharedHandler] open: droppedKeynote.filename];
}

- (void) postEditCleanUp {
    [self close];
    [presentation release];
    presentation = nil;
}


#pragma mark -
#pragma mark FileCopyController Delegate Methods

- (void)fileCopyControllerDidFinish: (FileCopyController *)controller; {
	[self postEditCleanUp];
}

- (void)fileCopyControllerDidFail: (FileCopyController *)controller; {
	
}

#pragma mark -
#pragma mark Private Methods
- (void) updateFileLabel: (NSTextField*) textLabel filename: (NSString*) aFilename {
    textLabel.stringValue = [aFilename lastPathComponent];
}

- (void) setGuiValues {
    [self updateFileLabel: keynoteFileLabel filename: presentation.absolutePresentationPath];
    droppedKeynote.filename = presentation.absolutePresentationPath;
    
    [titleView setString: presentation.title];

    [droppedThumbnail setImage: presentation.thumbnail];
    
    [highlightCheckbox setState: presentation.highlight];
}

@end
