//
//  EditWindowController.m
//  ACShell
//
//  Created by David Siegel on 7/25/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "EditWindowController.h"
#import "Presentation.h"
#import "PresentationLibrary.h"
#import "KeynoteDropper.h"
#import "KeynoteHandler.h"
#import "localized_text_keys.h"

@interface EditWindowController ()

@property (nonatomic) NSMutableArray *selectedCategories;

- (void) postEditCleanUp;
- (void) setGuiValues;
- (void) updateOkButton;
- (void) userDidDecideDelete:(NSAlert *)sheet returnCode:(NSInteger)returnCode;

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

- (id) initWithPresentationLibrary: (PresentationLibrary *) thePresentationLibrary
{
    self = [super initWithWindowNibName: @"PresentationEditWindow"];
    if (self != nil) {
        _selectedCategories = [NSMutableArray new];
        _presentationLibrary = thePresentationLibrary;
    }
    return self;
}

- (void) edit: (Presentation*) aPresentation {
    _presentation = aPresentation;
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
    [self.window beginSheet:progressSheet completionHandler:^(NSModalResponse returnCode) {
        [self didEndSheet:progressSheet returnCode:returnCode];
    }];
    
    [progressBar setIndeterminate: YES];
    [progressBar startAnimation: nil];
    [progressText setStringValue: @""];
    [progressMessage setStringValue: @""];
    if (self.presentation == nil) {
        [progressTitle setStringValue: NSLocalizedString(ACSHELL_STR_ADDING_PRESENTATION,nil)];
        [self.presentationLibrary addPresentationWithTitle: [self.titleField stringValue]
                                             thumbnailPath: [self.droppedThumbnail filename]
                                               keynotePath: [self.droppedKeynote filename]
                                               isHighlight: [self.highlightCheckbox intValue]
                                                      year: [self.yearField integerValue]
                                                categories: self.selectedCategories
                                          progressDelegate: self];
    } else {
        [progressTitle setStringValue: NSLocalizedString(ACSHELL_STR_UPDATING_PRESENTATION,nil)];
        [self.presentationLibrary updatePresentation:self.presentation title: [self.titleField stringValue]
                                       thumbnailPath: [self.droppedThumbnail filename]
                                         keynotePath: [self.droppedKeynote filename]
                                         isHighlight: [self.highlightCheckbox intValue]
                                                year: [self.yearField integerValue]
                                          categories: self.selectedCategories
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

- (IBAction) userDidChangeTitle: (id) sender {
    [self updateOkButton];
}

- (IBAction) userWantsToDeletePresentation: (id) sender {
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(ACSHELL_STR_DELETE_PRESENTATION_WARNING, nil);
    [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_CANCEL, nil)];
    [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_DELETE, nil)];
    alert.buttons[1].hasDestructiveAction = YES;
    alert.alertStyle = NSAlertStyleCritical;
    
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        [self userDidDecideDelete:alert returnCode:returnCode];
    }];
}

- (void) userDidDecideDelete:(NSAlert *)sheet returnCode:(NSInteger)returnCode {
    [[sheet window] orderOut: self];
    [NSApp endSheet:[sheet window]];
    
    switch (returnCode) {
        case NSAlertFirstButtonReturn:
            break;
        case NSAlertSecondButtonReturn:{
            [self.window beginSheet:progressSheet completionHandler:^(NSModalResponse returnCode) {
                [self didEndSheet:progressSheet returnCode:returnCode];
            }];
            [progressBar setIndeterminate: YES];
            [progressBar startAnimation: nil];
            [progressText setStringValue: @""];
            [progressMessage setStringValue: @""];
            
            [progressTitle setStringValue: NSLocalizedString(ACSHELL_STR_DELETING_PRESENTATION,nil)];
            [self.presentationLibrary deletePresentation:self.presentation progressDelegate: self];
        }
            break;
        default:
            break;
    }
}

- (void) editWithKeynote
{
    [[KeynoteHandler sharedHandler] open: droppedKeynote.filename];
}

#pragma mark -
#pragma mark Progress Sheet Methods
- (void) userDidDropKeynote: (KeynoteDropper *)keynoteDropper
{
    [keynoteFileLabel setStringValue: [[droppedKeynote filename] lastPathComponent]];
    BOOL fileExists = droppedKeynote.fileExists;
    [editButton setEnabled: fileExists];
    [keynoteFileLabel setTextColor: fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
    [self updateOkButton];
}

- (void) userDidDoubleClickKeynote: (KeynoteDropper *)keynoteDropper
{
    if (droppedKeynote.fileExists) {
        [self editWithKeynote];
    }
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

- (void) didEndSheet: (NSWindow*) sheet returnCode: (NSInteger) returnCode {
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
    if (self.presentation) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.ID IN %@", self.presentation.categories];
        NSArray *categories = [self.presentationLibrary.categories filteredArrayUsingPredicate:predicate];
        [self.selectedCategories removeAllObjects];
        [self.selectedCategories addObjectsFromArray:categories];
        
        [[self window] setTitle: NSLocalizedString(ACSHELL_STR_EDIT_WIN_TITLE, nil)];
        BOOL fileExists = self.presentation.presentationFileExists;
        [editButton setEnabled: fileExists];
        [keynoteFileLabel setTextColor: fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
        keynoteFileLabel.stringValue = self.presentation.presentationFilename;
        droppedKeynote.filename = self.presentation.absolutePresentationPath;
        
        [titleField setStringValue: self.presentation.title];
        
        droppedThumbnail.filename = self.presentation.absoluteThumbnailPath;
        thumbnailFileLabel.stringValue = self.presentation.thumbnailFilename;
        [thumbnailFileLabel setTextColor: droppedThumbnail.fileExists ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
        [highlightCheckbox setState: self.presentation.highlight];
        [yearField setStringValue: self.presentation.year ? [self.presentation.year stringValue] : @""];
        
    } else {
        [[self window] setTitle: NSLocalizedString(ACSHELL_STR_ADD_WIN_TITLE, nil)];
        [self.selectedCategories removeAllObjects];
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
    [self updateCategories];
    [self updateTags];
    [self.deleteButton setHidden: self.presentation == nil];
    [self updateOkButton];
}

- (void)updateCategories
{
    [self.categoryStack.subviews enumerateObjectsUsingBlock:^(__kindof NSButton* _Nonnull checkbox, NSUInteger index, BOOL * _Nonnull stop) {
        LibraryCategory *category = self.presentationLibrary.categories[index];
        checkbox.title = category.title;
        checkbox.action = @selector(categorySelected:);
        if ([self.presentation.categories containsObject:category.ID]) {
            [checkbox setState:NSControlStateValueOn];
        } else {
            [checkbox setState:NSControlStateValueOff];
        }
    }];
}

- (void)categorySelected:(id)sender
{
    NSInteger index = [self.categoryStack.subviews indexOfObject:sender];
    if ([sender state] == NSControlStateValueOff) {
        LibraryCategory *category = self.presentationLibrary.categories[index];
        [self.selectedCategories removeObject:category];
    }
    if ([sender state] == NSControlStateValueOn) {
        LibraryCategory *category = self.presentationLibrary.categories[index];
        [self.selectedCategories addObject:category];
    }
}

- (void)updateTags
{
    [self.presentationLibrary.tags enumerateObjectsUsingBlock:^(__kindof LibraryTag*  _Nonnull tag, NSUInteger index, BOOL * _Nonnull stop) {
        // create button
        // add title
        //add to stackview
    }];
}

- (void)tagSelected:(id)sender
{
    
}

- (void) updateOkButton {
    [okButton setEnabled: [[titleField stringValue] length] > 0 &&
     droppedKeynote.fileExists &&
     droppedThumbnail.fileExists];
}

- (void) postEditCleanUp {
    [self close];
    self.presentation = nil;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    NSTextView *textField = [obj.userInfo objectForKey: @"NSFieldEditor"];
    
    if ([textField isDescendantOf:titleField]) {
        [self updateOkButton];
    }
}

@end
