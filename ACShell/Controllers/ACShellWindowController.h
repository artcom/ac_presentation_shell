//
//  ShellWindowController.h
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RsyncController.h"
#import "KeynoteLaunchDelegate.h"
#import "EditWindowController.h"
#import "PresentationWindowController.h"
#import "PresentationLibrary.h"
#import "LibraryViewController.h"
#import "LibraryTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACShellWindowController : NSWindowController <NSToolbarItemValidation,
KeynoteLaunchDelegate,KeynotePlaybackDelegate, RsyncControllerDelegate, LibraryTableViewControllerDelegate>

@property (strong) LibraryViewController *libraryViewController;
@property (strong) LibraryTableViewController *libraryTableViewController;
@property(strong) PresentationWindowController *presentationWindowController;
@property(strong) EditWindowController * editWindowController;
@property(strong) RsyncController *rsyncController;

@property (weak, readonly) NSString* libraryDirPath;

@property (strong, nonatomic) NSMutableArray *currentPresentationList;

@property(strong) PresentationLibrary *presentationLibrary;
@property (readonly) BOOL editingEnabled;

- (void)start;
- (IBAction)toggleSidebar:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)upload:(id)sender;

- (IBAction)addCollection:(id)sender;
- (IBAction)addPresentation:(id)sender;
- (IBAction)editPresentation:(id)sender;
- (IBAction)updatePresentationFilter:(id)sender;
@end

NS_ASSUME_NONNULL_END
