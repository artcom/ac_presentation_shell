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
#import "localized_text_keys.h"

@interface EditWindowController ()

- (void) postEditCleanUp;
- (void) setGuiValues;
- (void) updateOkButton;
- (void) userDidDecideDelete:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end

@implementation EditWindowController
@synthesize titleField;
@synthesize droppedKeynote;
@synthesize keynoteFileLabel;
@synthesize droppedThumbnail;
@synthesize highlightCheckbox;
@synthesize yearField;
@synthesize editButton;
@synthesize thumbnailFileLabel;
@synthesize okButton;
@synthesize deleteButton;
@synthesize progressSheet;
@synthesize progressTitle;
@synthesize progressMessage;
@synthesize progressBar;
@synthesize progressText;

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
    [progressSheet release];
    
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
    [NSApp beginSheet: progressSheet modalForWindow: [self window] 
        modalDelegate: self 
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
    [progressBar setIndeterminate: YES];
    [progressBar startAnimation: nil];
    [progressText setStringValue: @""];
    [progressMessage setStringValue: @""];
    if (presentation == nil) {
        [progressTitle setStringValue: NSLocalizedString(ACSHELL_STR_ADDING_PRESENTATION,nil)];
        [shellController.presentationLibrary addPresentationWithTitle: [self.titleField stringValue]
                                                        thumbnailPath: [self.droppedThumbnail filename]
                                                          keynotePath: [self.droppedKeynote filename]
                                                          isHighlight: [self.highlightCheckbox intValue]
                                                                 year: [self.yearField integerValue]
                                                     progressDelegate: self];
    } else {
        [progressTitle setStringValue: NSLocalizedString(ACSHELL_STR_UPDATING_PRESENTATION,nil)];
        [shellController.presentationLibrary updatePresentation: presentation title: [self.titleField stringValue]
                                                  thumbnailPath: [self.droppedThumbnail filename]
                                                    keynotePath: [self.droppedKeynote filename]
                                                    isHighlight: [self.highlightCheckbox intValue]
                                                           year: [self.yearField integerValue]
                                               progressDelegate: self];
    }
}

- (IBAction) userDidCancelEdit: (id) sender {
    [self postEditCleanUp];
}

- (IBAction) userDidDropThumbnail: (id) sender {
    [thumbnailFileLabel setStringValue: [[droppedThumbnail filename] lastPathComponent]];
    BOOL fileExists = droppedThumbnail.fileExists;
    [thumbnailFileLabel setTextColor: fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
    [self updateOkButton];
}

- (IBAction) userDidDropKeynote: (id) sender {
    [keynoteFileLabel setStringValue: [[droppedKeynote filename] lastPathComponent]];
    BOOL fileExists = droppedKeynote.fileExists;
    [editButton setEnabled: fileExists];
    [keynoteFileLabel setTextColor: fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
    [self updateOkButton];
}

- (IBAction) userDidChangeTitle: (id) sender {
    [self updateOkButton];
}

- (IBAction) userWantsToDeletePresentation: (id) sender {
    NSAlert * alert = [NSAlert alertWithMessageText: NSLocalizedString(ACSHELL_STR_DELETE_PRESENTATION_WARNING, nil)
                                      defaultButton: NSLocalizedString(ACSHELL_STR_DELETE, nil)
                                    alternateButton: NSLocalizedString(ACSHELL_STR_CANCEL, nil) 
                                        otherButton: nil
                          informativeTextWithFormat: @""];
    [alert beginSheetModalForWindow: [self window]
                      modalDelegate: self
                     didEndSelector: @selector(userDidDecideDelete:returnCode:contextInfo:)
                        contextInfo: nil];
    
}

- (void) userDidDecideDelete:(NSAlert *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[sheet window] orderOut: self];
    [NSApp endSheet:[sheet window]];
    
    switch (returnCode) {
        case NSAlertDefaultReturn:
            [NSApp beginSheet: progressSheet modalForWindow: [self window] 
                modalDelegate: self 
               didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
                  contextInfo: nil];
            [progressBar setIndeterminate: YES];
            [progressBar startAnimation: nil];
            [progressText setStringValue: @""];
            [progressMessage setStringValue: @""];
            
            [progressTitle setStringValue: NSLocalizedString(ACSHELL_STR_DELETING_PRESENTATION,nil)];
            [shellController.presentationLibrary deletePresentation: presentation
                                                   progressDelegate: self];            
            break;
        case NSAlertAlternateReturn:
            break;
        default:
            break;
    }
}

- (IBAction) editWithKeynote: (id) sender {
    [[KeynoteHandler sharedHandler] open: droppedKeynote.filename];
}

// XXX for some reason the NSOpenPanel crashes (sometimes) when generating
// preview images for keynote files. No idea why that is. However, the stack
// always points to foreign threads and foreign code. So, my best guess is:
// It's an apple bug [DS]
- (IBAction) chooseKeynoteFile: (id) sender {
    NSOpenPanel * chooser = [NSOpenPanel openPanel];
    [chooser setAllowsMultipleSelection: NO];
    [chooser setCanChooseFiles: YES];
    [chooser setCanChooseDirectories: NO];
    [chooser setAllowedFileTypes: [NSArray arrayWithObject: @"key"]];
    [chooser beginSheetModalForWindow: [self window] completionHandler: ^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL * fileURL = [[chooser URLs] objectAtIndex: 0];
            [droppedKeynote setFilename: [fileURL path]];
            [self userDidDropKeynote: sender];
        }
    }];
}

- (IBAction) chooseThumbnailFile: (id) sender {
    NSOpenPanel * chooser = [NSOpenPanel openPanel];
    [chooser setAllowsMultipleSelection: NO];
    [chooser setCanChooseFiles: YES];
    [chooser setCanChooseDirectories: NO];
    [chooser setAllowedFileTypes: [NSArray arrayWithObjects: @"png", @"jpg", @"jpeg", @"tif", @"tiff", nil]];
    [chooser beginSheetModalForWindow: [self window] completionHandler: ^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL * fileURL = [[chooser URLs] objectAtIndex: 0];
            [droppedThumbnail setFilename: [fileURL path]];
            [self userDidDropThumbnail: sender];
        }
    }];    
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

#pragma mark -
#pragma mark Progress Sheet Methods

- (void) operationDidFinish {
    [NSApp endSheet: progressSheet];
}

- (void) didEndSheet: (NSWindow*) sheet returnCode: (NSInteger) returnCode contextInfo: (void*) contextInfo {
    [sheet orderOut:self];
    [self postEditCleanUp];
}

- (void) setMessage: (NSString*) message {
    [progressMessage setStringValue: message];
}

- (void) setProgress: (double) percent text: (NSString*) text {
    [progressBar setIndeterminate: NO];
    [progressBar setDoubleValue: percent];
    [progressText setStringValue: text];
}


#pragma mark -
#pragma mark Private Methods

- (void) setGuiValues {
    if (presentation) {
        [[self window] setTitle: NSLocalizedString(ACSHELL_STR_EDIT_WIN_TITLE, nil)];
        BOOL fileExists = presentation.presentationFileExists;
        [editButton setEnabled: fileExists];
        [keynoteFileLabel setTextColor: fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
        keynoteFileLabel.stringValue = presentation.presentationFilename;
        droppedKeynote.filename = presentation.absolutePresentationPath;

        [titleField setStringValue: presentation.title];
        
        droppedThumbnail.filename = presentation.absoluteThumbnailPath;
        thumbnailFileLabel.stringValue = presentation.thumbnailFilename;
        [thumbnailFileLabel setTextColor: droppedThumbnail.fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
        [highlightCheckbox setState: presentation.highlight];
        [yearField setStringValue: presentation.year ? [presentation.year stringValue] : @""];

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
        [yearField setStringValue: @""];
    }
    [self.deleteButton setHidden: presentation == nil];
    [self updateOkButton];
}

- (void) updateOkButton {
    [okButton setEnabled: [[titleField stringValue] length] > 0 && 
                          droppedKeynote.fileExists && 
                          droppedThumbnail.fileExists];
}

- (void) postEditCleanUp {
    [self close];
    [presentation release];
    presentation = nil;
}


@end
