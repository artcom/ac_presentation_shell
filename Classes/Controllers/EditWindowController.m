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
#import "localized_text_keys.h"

@interface EditWindowController ()

- (void) postEditCleanUp;
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
    [self setGuiValues];
    [self showWindow: nil];
}

- (IBAction) userDidConfirmEdit: (id) sender {
    NSLog(@"edit confirmed");
	
	FileCopyController *fileCopyController = [[FileCopyController alloc] initWithParentWindow:[self window]];
	fileCopyController.delegate = self;
    if (presentation) {
        [presentation updateWithTitle: [[titleView textStorage] string]
                        thumbnailPath: droppedThumbnail.filename
                          keynotePath: droppedKeynote.filename
                          isHighlight: [highlightCheckbox intValue]
                       copyController: fileCopyController];
    } else {
        NSLog(@"thumb: %@", droppedThumbnail.filename);
        [shellController.presentationLibrary addPresentationWithTitle: [[titleView textStorage] string]
                                                        thumbnailPath: droppedThumbnail.filename
                                                          keynotePath: droppedKeynote.filename
                                                          isHighlight: [highlightCheckbox intValue]
                                                       copyController: fileCopyController];
    }
    
	if (!fileCopyController.isCopying) {
		[self postEditCleanUp];
	}
		
	[fileCopyController release];
}

- (IBAction) userDidCancelEdit: (id) sender {
    NSLog(@"edit canceld");
    [self postEditCleanUp];
}

- (IBAction) userDidDropThumbnail: (id) sender {
}

- (IBAction) userDidDropKeynote: (id) sender {
    [keynoteFileLabel setStringValue: [[sender filename] lastPathComponent]];
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
	NSLog(@"File copy failed");
}

#pragma mark -
#pragma mark Private Methods

- (void) setGuiValues {
    if (presentation) {
        keynoteFileLabel.stringValue = [presentation.absolutePresentationPath lastPathComponent];
        droppedKeynote.filename = presentation.absolutePresentationPath;
        [titleView setString: presentation.title];
        [droppedThumbnail setImage: presentation.thumbnail];
        [highlightCheckbox setState: presentation.highlight];
    } else {
        keynoteFileLabel.stringValue = NSLocalizedString(ACSHELL_STR_DROP_KEYNOTE, nil);
        droppedKeynote.filename = nil;
        [titleView setString: @""];
        [droppedThumbnail setImage: nil];
        [highlightCheckbox setState: FALSE];
    }
}

@end
