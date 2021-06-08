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
}

- (void)bindMenuItems
{
    NSMenuItem *file = [NSApplication.sharedApplication.menu itemAtIndex:1];
    NSMenuItem *library = [file.submenu itemAtIndex:3];
    NSMenuItem *upload = [library.submenu itemAtIndex:1];
    NSMenuItem *delete = [library.submenu itemAtIndex:2];
    
    [upload bind:@"enabled" toObject:self withKeyPath:@"editingEnabled" options:nil];
    [delete bind:@"enabled" toObject:self withKeyPath:@"editingEnabled" options:nil];
}

- (void)setupControllers
{
    self.libraryViewController = self.contentViewController.childViewControllers[0];
    self.libraryTableViewController = self.contentViewController.childViewControllers[1];
    self.libraryTableViewController.presentationLibrary = self.presentationLibrary;
    [self.libraryTableViewController bind: @"currentPresentationList" toObject:self.libraryViewController.collectionTreeController withKeyPath:@"selection.presentations" options:nil];
    
    self.presentationWindowController = [[PresentationWindowController alloc] init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey: ACSHELL_DEFAULT_KEY_EDITING_ENABLED]) {
        self.editWindowController = [[EditWindowController alloc] initWithShellController: self];
    }
    
    self.rsyncController = [[RsyncController alloc] init];
    self.rsyncController.delegate = self;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey: ACSHELL_DEFAULT_KEY_SETUP_DONE]) {
        [[KeynoteHandler sharedHandler] launchWithDelegate:self];
//        [[self browserWindow] makeKeyAndOrderFront: self];
//        [self load];
    } else {
//        setupAssistant = [[SetupAssistantController alloc] initWithDelegate: self];
//        [setupAssistant showWindow: self];
    }
}

- (NSMutableArray*) library
{
    return self.presentationLibrary.library.children;
}

- (void) setLibrary:(NSMutableArray *) array
{
    self.presentationLibrary.library.children = array;
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
    NSLog(@"play");
    self.presentationWindowController.categories = self.presentationLibrary.categories;
    self.presentationWindowController.presentations = self.libraryTableViewController.selectedPresentations;
    [self.presentationWindowController showWindow:nil];
}

- (IBAction)sync:(id)sender
{
    NSLog(@"sync");
    //    [self.shellController sync:nil];
}

- (IBAction)upload:(id)sender
{
    NSLog(@"upload");
    //    [self.shellController upload:nil];
}

- (IBAction)deletePresentation:(id)sender
{
    NSLog(@"deletePresentation");
}

- (IBAction)editPresentation:(id)sender
{
    NSLog(@"editPresentation");
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
#pragma mark RsyncControllerDelegate Protocol Methods
- (void)rsync:(RsyncController *) controller didFinishSyncSuccessfully:(BOOL)successFlag {
    self.presentationLibrary.syncSuccessful = successFlag;
    [self.libraryViewController updateSyncFailedWarning];
    if (successFlag) {
//        [self load];
    }
}

@end
