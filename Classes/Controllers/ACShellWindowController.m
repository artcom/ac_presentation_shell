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

#define AC_SHELL_TOOLBAR_ITEM_UPLOAD @"ACShellToolbarItemUpload"
#define AC_SHELL_TOOLBAR_ITEM_SEARCH @"ACShellToolbarItemSearch"
#define AC_SHELL_SEARCH_MAX_RESULTS  1000


@interface ACShellWindowController ()

@end

@implementation ACShellWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.presentationLibrary = [PresentationLibrary sharedInstance];
    [self setupControllers];
    [self bindMenuItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(load) name:ACShellLibraryConfigDidChange object:nil];
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
    
    self.presentationWindowController = [[PresentationWindowController alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED]) {
        self.editWindowController = [[EditWindowController alloc] initWithPresentationLibrary:self.presentationLibrary];
    }
    
    self.rsyncController = [[RsyncController alloc] init];
    self.rsyncController.documentWindow = self.window;
    self.rsyncController.delegate = self;
    
    [[KeynoteHandler sharedHandler] launchWithDelegate:self];
    [self load];
}

- (NSMutableArray*) library
{
    return self.presentationLibrary.library.children;
}

- (void) setLibrary:(NSMutableArray *) array
{
    self.presentationLibrary.library.children = array;
}

- (void) load {
    [self.libraryViewController.collectionView deselectAll:self];
    
    [[PresentationLibrary sharedInstance] reload];
    
    [self.libraryViewController willChangeValueForKey:@"library"];
    if (![self.presentationLibrary loadXmlLibraryFromDirectory: self.presentationLibrary.libraryDirPath]) {
        [self.rsyncController initialSyncWithSource: self.presentationLibrary.librarySource destination: self.presentationLibrary.libraryDirPath];
    }
    [self.libraryViewController didChangeValueForKey:@"library"];
    [self.libraryViewController beautifyOutlineView];
}

- (BOOL) editingEnabled
{
    return [[NSUserDefaults standardUserDefaults] boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED];
}

- (IBAction)updatePresentationFilter:(id)sender
{
    [self.libraryTableViewController updatePresentationFilter:sender];
}

- (IBAction)toggleSidebar:(id)sender
{
    NSSplitViewController *splitViewController = (NSSplitViewController *)self.contentViewController;
    [splitViewController toggleSidebar:nil];
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
        [self.rsyncController syncWithSource: self.presentationLibrary.librarySource destination: self.presentationLibrary.libraryDirPath];
    } else {
        [self.rsyncController initialSyncWithSource: self.presentationLibrary.librarySource destination: self.presentationLibrary.libraryDirPath];
    }
}

- (IBAction)upload:(id)sender
{
    [self.rsyncController uploadWithSource: self.presentationLibrary.libraryDirPath destination: self.presentationLibrary.libraryTarget];
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
    
    BOOL deleteIt = [self.libraryViewController runSuppressableBooleanDialogWithIdentifier: @"DeletePresentationFromCollection"
                                                                                   message: ACSHELL_STR_DELETE_PRESENTATION
                                                                                  okButton: ACSHELL_STR_DELETE
                                                                              cancelButton: ACSHELL_STR_CANCEL];
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
#pragma mark KeynoteDelegate Protocol Methods

- (void) keynoteAppDidLaunch: (BOOL) success version:(NSString *)version {
    if (success) {
        NSLog(@"Running Keynote application Version %@", version);
        //run prefs checks
    } else {
        // issue warning
        NSLog(@"Failed to run Keynote application Version %@", version);
    }
}

- (void)keynoteDidStartPresentation:(KeynoteHandler *)keynote {
    // Do nothing
}

- (void)keynoteDidStopPresentation:(KeynoteHandler *)keynote {
    // Do nothing
}

#pragma mark -
#pragma mark RsyncControllerDelegate Protocol Methods

- (void)rsync:(RsyncController *) controller didFinishSyncSuccessfully:(BOOL)successFlag {
    self.presentationLibrary.syncSuccessful = successFlag;
    [self.libraryViewController updateSyncFailedWarning];
    if (successFlag) {
        [self load];
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
        [[KeynoteHandler sharedHandler] play: presentation.absolutePresentationPath withDelegate: self];
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
        if ([[self.libraryTableViewController.presentationTable selectedRowIndexes] count] == 1) {
            return YES;
        }
        return NO;
    } else if (theAction == @selector(remove:)) {
        if (self.window.firstResponder == self.libraryTableViewController.presentationTable) {
            return self.libraryViewController.isPresentationRemovable;
        } else if (self.window.firstResponder == self.libraryViewController.collectionView) {
            return self.libraryViewController.isCollectionSelected;
        }
        return NO;
    }
    return YES;
}


@end
