//
//  ShellWindowController.m
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import "ACShellWindowController.h"
#import "ACShellAppDelegate.h"
#import "KeynoteHandler.h"
#import "default_keys.h"
#import "localized_text_keys.h"
#import "NSFileManager-DirectoryHelper.h"
#import "ACShellCollection.h"
#import "NSAlert+Dialogs.h"

#define AC_SHELL_TOOLBAR_ITEM_UPLOAD @"ACShellToolbarItemUpload"
#define AC_SHELL_TOOLBAR_ITEM_SEARCH @"ACShellToolbarItemSearch"
#define AC_SHELL_SEARCH_MAX_RESULTS  1000


@interface ACShellWindowController ()

@end

@implementation ACShellWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSSplitViewController *splitViewController = (NSSplitViewController *)self.contentViewController;
    splitViewController.splitView.autosaveName = @"splitview";
    
    self.presentationLibrary = [PresentationLibrary sharedInstance];
    [self setupControllers];
    [self bindMenuItems];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadLibrary) name:ACShellLibraryDidUpdate object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(loadLibrary) name:ACShellLibraryConfigDidChange object:nil];
}

- (void)bindMenuItems
{
    NSMenuItem *file = [NSApplication.sharedApplication.menu itemAtIndex:1];
    NSMenuItem *library = [file.submenu itemAtIndex:3];
    NSMenuItem *upload = [library.submenu itemAtIndex:1];
    [upload bind:@"enabled" toObject:self withKeyPath:@"editingEnabled" options:nil];
}

- (void)setupControllers
{
    self.libraryTableViewController = self.contentViewController.childViewControllers[1];
    self.libraryTableViewController.presentationLibrary = self.presentationLibrary;
    self.libraryTableViewController.delegate = self;
    
    self.libraryViewController = self.contentViewController.childViewControllers[0];
    self.libraryViewController.presentationsArrayController = self.libraryTableViewController.presentationsArrayController;
    
    [self.libraryTableViewController bind: @"currentPresentationList" toObject:self.libraryViewController.collectionTreeController withKeyPath:@"selection.presentations" options:nil];
    
    self.presentationWindowController = PresentationWindowController.new;
    
    if ([NSUserDefaults.standardUserDefaults boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED]) {
        self.editWindowController = [[EditWindowController alloc] initWithPresentationLibrary:self.presentationLibrary];
    }
    
    self.rsyncController = RsyncController.new;
    self.rsyncController.documentWindow = self.window;
    self.rsyncController.delegate = self;
    
    KeynoteHandler.sharedHandler.launchDelegate = self;
    [KeynoteHandler.sharedHandler launch];
    [self loadLibrary];
}

- (NSMutableArray*) library
{
    return self.presentationLibrary.library.children;
}

- (void) setLibrary:(NSMutableArray *) array
{
    self.presentationLibrary.library.children = array;
}

- (void) loadLibrary {
    [self.libraryViewController.collectionView deselectAll:self];
    
    [self.libraryViewController willChangeValueForKey:@"library"];
    [[PresentationLibrary sharedInstance] loadPresentations];
    [self.libraryViewController didChangeValueForKey:@"library"];
    [self.libraryViewController beautifyOutlineView];
}

- (void)start
{
    if (![self.presentationLibrary libraryExistsAtPath]) {
        [self.rsyncController initialSyncWithSource: PresentationLibrary.librarySource destination: PresentationLibrary.libraryDirPath];
    }
}

- (BOOL) editingEnabled
{
    return [NSUserDefaults.standardUserDefaults boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED];
}

- (IBAction)updatePresentationFilter:(id)sender
{
    [self.libraryTableViewController updatePresentationFilter:sender];
}

- (IBAction)toggleSidebar:(id)sender
{
    NSSplitViewController *splitViewController = (NSSplitViewController *)self.contentViewController;
    [splitViewController toggleSidebar:nil];
    
    if ([splitViewController.splitViewItems[0] isCollapsed]) {
        [self.window makeFirstResponder:self.libraryTableViewController.presentationTable];
    } else {
        [self.window makeFirstResponder:self.libraryViewController.collectionView];
    }
}

- (IBAction)play:(id)sender
{
    self.presentationWindowController.categories = self.presentationLibrary.categories;
    self.presentationWindowController.presentations = self.libraryTableViewController.selectedPresentations;
    [self.presentationWindowController showWindow:nil];
}

- (IBAction)sync:(id)sender
{
    if ([self.presentationLibrary hasLibrary]) {
        [self.rsyncController syncWithSource: PresentationLibrary.librarySource destination: PresentationLibrary.libraryDirPath];
    } else {
        [self.rsyncController initialSyncWithSource: PresentationLibrary.librarySource destination: PresentationLibrary.libraryDirPath];
    }
}

- (IBAction)upload:(id)sender
{
    [self.rsyncController uploadWithSource: PresentationLibrary.libraryDirPath destination: PresentationLibrary.libraryTarget];
}

- (IBAction)addCollection:(id)sender
{
    [self.libraryViewController addCollection];
}

- (IBAction)addPresentation: sender {
    [self.libraryViewController beautifyOutlineView];
    [self.editWindowController add];
}

- (IBAction)editPresentation: (id) sender {
    if ( ! [[self.editWindowController window] isVisible]) {
        Presentation *presentation = [[self.libraryTableViewController.presentationsArrayController selectedObjects] objectAtIndex:0];
        [self.editWindowController edit: presentation];
    } else {
        NSBeep();
    }
}

- (IBAction)remove: (id)sender {
    if (self.window.firstResponder == self.libraryTableViewController.presentationTable) {
        [self removePresentation:sender];
    } else if (self.window.firstResponder  == self.libraryViewController.collectionView) {
        [self.libraryViewController removeCollection];
    } else {
        NSBeep();
    }
}

- (void)removePresentation: (id) sender {
    if ( ! [self.libraryViewController isPresentationRemovable]) {
        NSBeep();
        return;
    }
    
    BOOL deleteIt = [NSAlert runSuppressableBooleanDialogWithIdentifier: ACSHELL_STR_DELETE_PRESENTATION
                                                                message: ACSHELL_STR_DELETE_PRESENTATION
                                                               okButton: ACSHELL_STR_DELETE
                                                           cancelButton: ACSHELL_STR_CANCEL
                                                      destructiveAction:YES];
    if (deleteIt) {
        [self.libraryTableViewController.presentationsArrayController removeObjectsAtArrangedObjectIndexes:self.libraryTableViewController.presentationsArrayController.selectionIndexes];
        NSArray * items = [[[self.libraryViewController.collectionTreeController selectedObjects] objectAtIndex:0] presentations];
        NSInteger order = 1;
        for (Presentation* p in items) {
            p.order = order++;
        }
    }
}

#pragma mark -
#pragma mark NSToolbarDelegate Protocol Methods

- (BOOL)validateToolbarItem:(NSToolbarItem *)item
{
    if ([item.itemIdentifier isEqualToString:AC_SHELL_TOOLBAR_ITEM_UPLOAD]) {
        return self.editingEnabled;
    }
    return YES;
}


#pragma mark -
#pragma mark KeynoteLaunchDelegate Protocol Methods

- (void) keynoteAppDidLaunch: (BOOL) success version:(NSString *)version {
    if (success) {
        NSLog(@"Running Keynote application Version %@", version);
        //run prefs checks
    } else {
        // issue warning
        NSLog(@"Failed to run Keynote application Version %@", version);
    }
}

- (void)keynoteDidRunInWindow:(KeynoteHandler *)keynote {
    NSAlert * alert = NSAlert.new;
    alert.messageText = NSLocalizedString(ACSHELL_STR_PRESENTATION_IN_WINDOW, nil);
    alert.informativeText = NSLocalizedString(ACSHELL_STR_PRESENTATION_IN_WINDOW_INFO, nil);
    [alert addButtonWithTitle:NSLocalizedString(ACSHELL_STR_CANCEL, nil)];
    alert.alertStyle = NSAlertStyleCritical;
    
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        [KeynoteHandler.sharedHandler stop];
    }];
}

#pragma mark -
#pragma mark KeynotePlaybackDelegate Protocol Methods

- (void)keynoteDidStartPresentation:(KeynoteHandler *)keynote {}
- (void)keynoteDidStopPresentation:(KeynoteHandler *)keynote {}

#pragma mark -
#pragma mark RsyncControllerDelegate Protocol Methods

- (void)rsync:(RsyncController *) controller didFinishSyncSuccessfully:(BOOL)successFlag {
    self.presentationLibrary.syncSuccessful = successFlag;
    [self.libraryViewController updateSyncFailedWarning];
    if (successFlag) {
        [self loadLibrary];
    }
}

#pragma mark -
#pragma mark LibraryTableDelegate Protocol Methods

- (void)libraryTableViewController:(LibraryTableViewController *)controller openPresentation:(nonnull Presentation *)presentation
{
    if (presentation.presentationFileExists) {
        [[KeynoteHandler sharedHandler] open: presentation.absolutePresentationPath];
    }
}


- (void)libraryTableViewController:(LibraryTableViewController *)controller playPresentation:(nonnull Presentation *)presentation
{
    if (presentation.presentationFileExists) {
        [[KeynoteHandler sharedHandler] play: presentation.absolutePresentationPath withDelegate:self];
    }
}

- (void)libraryTableViewController:(LibraryTableViewController *)controller editPresentation:(nonnull Presentation *)presentation
{
    if (!self.editWindowController.window.isVisible) {
        [self.editWindowController edit:presentation];
    } else {
        NSBeep();
        [[self.editWindowController window] makeKeyAndOrderFront:nil];
    }
}

- (void)libraryTableViewController:(LibraryTableViewController *)controller updatePresentationList:(NSMutableArray *)presentationList
{
    [self.libraryViewController setPresentationList:presentationList];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
{
    SEL theAction = [anItem action];
    if (theAction == @selector(editPresentation:)) {
        if (PresentationLibrary.editingEnabled && [self.libraryTableViewController hasPresentationSelected]) {
            return YES;
        }
        return NO;
    } else if (theAction == @selector(remove:)) {
        if (self.window.firstResponder == self.libraryTableViewController.presentationTable && [self.libraryTableViewController hasPresentationSelected]) {
            return self.libraryViewController.isPresentationRemovable;
        } else if (self.window.firstResponder == self.libraryViewController.collectionView) {
            return self.libraryViewController.isCollectionSelected;
        }
        return NO;
    }
    return YES;
}


@end
