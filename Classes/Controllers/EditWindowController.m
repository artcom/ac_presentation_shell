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

- (id) initWithShellController: (ACShellController*) theShellController
{
    self = [super initWithWindowNibName: @"PresentationEditWindow"];
    if (self != nil) {
        _shellController = theShellController;
        _selectedCategories = [NSMutableArray new];
    }
    return self;
}

- (void)windowDidLoad
{
    [self.categoryTable registerNib:[[NSNib alloc] initWithNibNamed:@"CategoryCell" bundle:nil] forIdentifier:@"CategoryCell"];
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
        [self.shellController.presentationLibrary addPresentationWithTitle: [self.titleField stringValue]
                                                             thumbnailPath: [self.droppedThumbnail filename]
                                                               keynotePath: [self.droppedKeynote filename]
                                                               isHighlight: [self.highlightCheckbox intValue]
                                                                      year: [self.yearField integerValue]
                                                                categories: self.selectedCategories
                                                          progressDelegate: self];
    } else {
        [progressTitle setStringValue: NSLocalizedString(ACSHELL_STR_UPDATING_PRESENTATION,nil)];
        [self.shellController.presentationLibrary updatePresentation:self.presentation title: [self.titleField stringValue]
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
    NSAlert * alert = [NSAlert new];
    alert.messageText = NSLocalizedString(ACSHELL_STR_DELETE_PRESENTATION_WARNING, nil);
    [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_DELETE, nil)];
    [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_CANCEL, nil)];
    
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        [self userDidDecideDelete:alert returnCode:returnCode];
    }];
}

- (void) userDidDecideDelete:(NSAlert *)sheet returnCode:(NSInteger)returnCode {
    [[sheet window] orderOut: self];
    [NSApp endSheet:[sheet window]];
    
    switch (returnCode) {
        case NSAlertFirstButtonReturn:{
            [self.window beginSheet:progressSheet completionHandler:^(NSModalResponse returnCode) {
                [self didEndSheet:progressSheet returnCode:returnCode];
            }];
            [progressBar setIndeterminate: YES];
            [progressBar startAnimation: nil];
            [progressText setStringValue: @""];
            [progressMessage setStringValue: @""];
            
            [progressTitle setStringValue: NSLocalizedString(ACSHELL_STR_DELETING_PRESENTATION,nil)];
            [self.shellController.presentationLibrary deletePresentation:self.presentation progressDelegate: self];
        }
            break;
        case NSAlertSecondButtonReturn:
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
        if (result == NSModalResponseOK) {
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
        if (result == NSModalResponseOK) {
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
#pragma mark NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.shellController.presentationLibrary.categories.count;
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    LibraryCategory *category = self.shellController.presentationLibrary.categories[row];
    CategoryCell *cell = [tableView makeViewWithIdentifier:@"CategoryCell" owner:self];
    cell.delegate = self;
    cell.checkbox.title = category.title;
    cell.index = row;
    if ([self.presentation.categories containsObject:category.ID]) {
        [cell.checkbox setState:NSControlStateValueOn];
    } else {
        [cell.checkbox setState:NSControlStateValueOff];
    }
    return cell;
}

#pragma mark -
#pragma mark - CategoryCellDelegate

- (void)categoryCellDidCheck:(CategoryCell *)cell withIndex:(NSInteger)index
{
    LibraryCategory *category = self.shellController.presentationLibrary.categories[index];
    [self.selectedCategories addObject:category];
}

- (void)categoryCellDidUncheck:(CategoryCell *)cell withIndex:(NSInteger)index
{
    LibraryCategory *category = self.shellController.presentationLibrary.categories[index];
    [self.selectedCategories removeObject:category];
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
        NSArray *categories = [self.shellController.presentationLibrary.categories filteredArrayUsingPredicate:predicate];
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
    [self.categoryTable reloadData];
    [self.deleteButton setHidden: self.presentation == nil];
    [self updateOkButton];
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
    
    if ([textField isDescendantOf:titleField])
        [self updateOkButton];
}

@end
