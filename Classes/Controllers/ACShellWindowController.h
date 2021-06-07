//
//  ShellWindowController.h
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACShellController.h"
#import "RsyncController.h"
#import "KeynoteDelegate.h"
#import "EditWindowController.h"
#import "PresentationWindowController.h"
#import "PresentationLibrary.h"
#import "LibraryViewController.h"
#import "LibraryTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACShellWindowController : NSWindowController <NSToolbarItemValidation, KeynoteDelegate, RsyncControllerDelegate>

@property (strong) LibraryViewController *libraryViewController;
@property (strong) LibraryTableViewController *presentationTableViewController;
@property(strong) PresentationWindowController *presentationWindowController;
@property(strong) EditWindowController * editWindowController;
@property(strong) RsyncController *rsyncController;

@property (strong, nonatomic) NSMutableArray *currentPresentationList;

@property(strong) PresentationLibrary *presentationLibrary;
@property (readonly) BOOL editingEnabled;

- (IBAction)toggleSidebar:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)editPresentation:(id)sender;
- (IBAction)deletePresentation:(id)sender;

@end

NS_ASSUME_NONNULL_END
