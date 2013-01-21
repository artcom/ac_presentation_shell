//
//  FirstRunAssistantController.h
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SetupAssistantDelegateProtocol.h"

@class PublicKeyDraglet;

@interface SetupAssistantController : NSWindowController <NSTabViewDelegate, NSNetServiceBrowserDelegate> {
    
    NSTabView * pages;
    
    NSButton * nextButton;
    NSButton * backButton;
    
    NSInteger numPages;
    
    NSArrayController * publicKeyArrayController;
    NSMutableArray * publicKeys;
    NSTableView * publicKeyTable;
    NSButton * generateSshKeysButton;
    NSProgressIndicator * sshKeygenSpinner;
    
    NSCollectionView * bonjourServerList;
    NSTextField * rsyncSourceEntry;
    
    BOOL bonjourBrowserRunning;
    NSNetServiceBrowser * bonjourBrowser;
    NSMutableArray * bonjourLibraries;
    NSArrayController * bonjourLibrariesArrayController;
    NSMatrix * discoveryModeButtons;
    
    PublicKeyDraglet * publicKeyDraglet;
    NSTextField * libraryNameLabel;
    NSTextField * administratorAddressLabel;
    NSButton * emailSendToggle;
    
    id<SetupAssistantDelegate> delegate;
}

@property (assign, nonatomic) IBOutlet NSTabView * pages;

@property (assign, nonatomic) IBOutlet NSButton * nextButton;
@property (assign, nonatomic) IBOutlet NSButton * backButton;

@property (retain, nonatomic) IBOutlet NSArrayController * publicKeyArrayController;
@property (assign, nonatomic) IBOutlet NSTableView * publicKeyTable;
@property (assign, nonatomic) IBOutlet NSButton * generateSshKeysButton;
@property (assign, nonatomic) IBOutlet NSProgressIndicator * sshKeygenSpinner;
@property (retain, nonatomic) NSMutableArray * publicKeys;

@property (assign, nonatomic) IBOutlet NSCollectionView * bonjourServerList;
@property (assign, nonatomic) IBOutlet NSTextField * rsyncSourceEntry;
@property (retain, nonatomic) IBOutlet NSArrayController * bonjourLibrariesArrayController;
@property (assign, nonatomic) IBOutlet NSMatrix * discoveryModeButtons;
@property (retain, nonatomic) NSMutableArray * bonjourLibraries;

@property (assign, nonatomic) IBOutlet NSTextField * administratorAddressLabel;
@property (assign, nonatomic) IBOutlet NSTextField * libraryNameLabel;
@property (assign, nonatomic) IBOutlet NSButton * emailSendToggle;

@property (assign, nonatomic) IBOutlet PublicKeyDraglet * publicKeyDraglet;

- (id) initWithDelegate: (id<SetupAssistantDelegate>) delegate;

- (IBAction) userDidClickNext: (id) sender;
- (IBAction) userDidClickBack: (id) sender;

- (IBAction) generateSshKeys: (id) sender;

- (IBAction) userDidChangeServerDiscoveryMode: (id) sender;
- (IBAction) userDidChangeRsyncSource: (id) sender;

- (IBAction) openMailTemplate: (id) sender;
- (IBAction) userDidSendEmail: (id) sender;

@end
