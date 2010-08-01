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
@synthesize editButton;
@synthesize thumbnailFileLabel;

- (id) initWithShellController: (ACShellController*) theShellController {
    self = [super initWithWindowNibName: @"PresentationEditWindow"];
    if (self != nil) {
        shellController = [theShellController retain];
    }
    return self;
}

- (void) awakeFromNib {
    [droppedKeynote setToolTip: NSLocalizedString(ACSHELL_STR_DROP_KEYNOTE, nil)];
    [droppedThumbnail setToolTip: NSLocalizedString(ACSHELL_STR_DROP_THUMBNAIL, nil)];
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
    if (droppedThumbnail.filename != nil && ! [[NSFileManager defaultManager] fileExistsAtPath: droppedThumbnail.filename isDirectory: nil]) {
        [droppedThumbnail setImage: [NSImage imageNamed: @"icn_missing_file"]];
    }
}

- (IBAction) userDidDropKeynote: (id) sender {
    [keynoteFileLabel setStringValue: [[sender filename] lastPathComponent]];
    BOOL fileExists = presentation.presentationFileExists;
    [editButton setEnabled: fileExists];
    [keynoteFileLabel setEnabled: fileExists];
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
        [[self window] setTitle: NSLocalizedString(ACSHELL_STR_EDIT_WIN_TITLE, nil)];
        BOOL fileExists = presentation.presentationFileExists;
        [editButton setEnabled: fileExists];
        [keynoteFileLabel setTextColor: fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
        keynoteFileLabel.stringValue = presentation.relativePresentationPath;
        droppedKeynote.filename = presentation.absolutePresentationPath;

        [titleView setString: presentation.title];
        
        NSImage * thumbnail = presentation.thumbnail;
        [droppedThumbnail setImage: thumbnail ? thumbnail : [NSImage imageNamed: @"icn_missing_file"]];
        thumbnailFileLabel.stringValue = presentation.relativeThumbnailPath;
        [thumbnailFileLabel setTextColor: thumbnail ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
        [highlightCheckbox setState: presentation.highlight];

    } else {
        [[self window] setTitle: NSLocalizedString(ACSHELL_STR_ADD_WIN_TITLE, nil)];
        keynoteFileLabel.stringValue = NSLocalizedString(ACSHELL_STR_DROP_KEYNOTE, nil);
        [keynoteFileLabel setTextColor: [NSColor controlTextColor]];
        droppedKeynote.filename = nil;
        [titleView setString: @""];
        [droppedThumbnail setImage: nil];
        thumbnailFileLabel.stringValue = NSLocalizedString(ACSHELL_STR_DROP_THUMBNAIL, nil);
        [thumbnailFileLabel setTextColor: [NSColor controlTextColor]];
        [highlightCheckbox setState: FALSE];
        [editButton setEnabled: NO];
    }
}

@end
