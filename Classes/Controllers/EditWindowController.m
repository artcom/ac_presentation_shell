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
- (void) updateOkButton;

@end

@implementation EditWindowController
@synthesize titleField;
@synthesize droppedKeynote;
@synthesize keynoteFileLabel;
@synthesize droppedThumbnail;
@synthesize highlightCheckbox;
@synthesize editButton;
@synthesize thumbnailFileLabel;
@synthesize okButton;

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
    [self updateOkButton];
}

- (void) add {
    [self setGuiValues];
    [self showWindow: nil];
    [self updateOkButton];
}

- (IBAction) userDidConfirmEdit: (id) sender {
	FileCopyController *fileCopyController = [[FileCopyController alloc] initWithParentWindow:[self window]];
	fileCopyController.delegate = self;
    if (presentation) {
        [presentation updateWithTitle: [titleField stringValue]
                        thumbnailPath: droppedThumbnail.filename
                          keynotePath: droppedKeynote.filename
                          isHighlight: [highlightCheckbox intValue]
                       copyController: fileCopyController];
    } else {
        [shellController.presentationLibrary addPresentationWithTitle: [titleField stringValue]
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
    [self postEditCleanUp];
}

- (IBAction) userDidDropThumbnail: (id) sender {
    BOOL fileExists = droppedThumbnail.fileExists;
    [thumbnailFileLabel setTextColor: fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
    [self updateOkButton];
}

- (IBAction) userDidDropKeynote: (id) sender {
    [keynoteFileLabel setStringValue: [[sender filename] lastPathComponent]];
    BOOL fileExists = droppedKeynote.fileExists;
    [editButton setEnabled: fileExists];
    [keynoteFileLabel setTextColor: fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
    [self updateOkButton];
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
#pragma mark Title Text Field Delegate Methods
- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    BOOL retval = NO;
    if (commandSelector == @selector(insertNewline:) && titleField == control) {
        retval = YES;
        [fieldEditor insertNewlineIgnoringFieldEditor:nil];
    }
    return retval;
}

- (IBAction) titleDidChange: (id) sender {
    [self updateOkButton];
}

#pragma mark -
#pragma mark FileCopyController Delegate Methods

- (void)fileCopyControllerDidFinish: (FileCopyController *)controller; {
	[self postEditCleanUp];
}

- (void)fileCopyControllerDidFail: (FileCopyController *)controller; {
    NSAlert * alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle: NSLocalizedString(ACSHELL_STR_OK, nil)];
    [alert setMessageText: NSLocalizedString(ACSHELL_STR_COPY_FAILED, nil)];
    [alert runModal];
    [self postEditCleanUp];
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

        [titleField setStringValue: presentation.title];
        
        droppedThumbnail.filename = presentation.absoluteThumbnailPath;
        thumbnailFileLabel.stringValue = presentation.relativeThumbnailPath;
        [thumbnailFileLabel setTextColor: droppedThumbnail.fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
        [highlightCheckbox setState: presentation.highlight];

    } else {
        [[self window] setTitle: NSLocalizedString(ACSHELL_STR_ADD_WIN_TITLE, nil)];
        keynoteFileLabel.stringValue = NSLocalizedString(ACSHELL_STR_DROP_KEYNOTE, nil);
        [keynoteFileLabel setTextColor: [NSColor controlTextColor]];
        droppedKeynote.filename = nil;
        [titleField setStringValue: @""];
        droppedThumbnail.filename = nil;
        thumbnailFileLabel.stringValue = NSLocalizedString(ACSHELL_STR_DROP_THUMBNAIL, nil);
        [thumbnailFileLabel setTextColor: [NSColor controlTextColor]];
        [highlightCheckbox setState: FALSE];
        [editButton setEnabled: NO];
    }
    [self updateOkButton];
}

- (void) updateOkButton {
    NSLog(@"%d %d %d", [[titleField stringValue] length] > 0, droppedKeynote.fileExists, droppedThumbnail.fileExists);
    [okButton setEnabled: [[titleField stringValue] length] > 0 && 
                          droppedKeynote.fileExists && 
                          droppedThumbnail.fileExists];
}

@end
