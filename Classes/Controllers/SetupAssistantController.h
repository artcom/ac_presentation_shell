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
    
    NSTabView * __weak pages;
    
    NSButton * __weak nextButton;
    NSButton * __weak backButton;
    
    NSInteger numPages;
    
    NSArrayController * publicKeyArrayController;
    NSMutableArray * publicKeys;
    NSTableView * __weak publicKeyTable;
    NSButton * __weak generateSshKeysButton;
    NSProgressIndicator * __weak sshKeygenSpinner;
    
    NSCollectionView * __weak bonjourServerList;
    NSTextField * __weak rsyncSourceEntry;
    
    BOOL bonjourBrowserRunning;
    NSNetServiceBrowser * bonjourBrowser;
    NSMutableArray * bonjourLibraries;
    NSArrayController * bonjourLibrariesArrayController;
    NSMatrix * __weak discoveryModeButtons;
    
    PublicKeyDraglet * __weak publicKeyDraglet;
    NSTextField * __weak libraryNameLabel;
    NSTextField * __weak administratorAddressLabel;
    NSButton * __weak emailSendToggle;
    
    id<SetupAssistantDelegate> delegate;
    NSTask *sshKeygenTask;
}

@property (weak, nonatomic) IBOutlet NSTabView * pages;

@property (weak, nonatomic) IBOutlet NSButton * nextButton;
@property (weak, nonatomic) IBOutlet NSButton * backButton;

@property (strong, nonatomic) IBOutlet NSArrayController * publicKeyArrayController;
@property (weak, nonatomic) IBOutlet NSTableView * publicKeyTable;
@property (weak, nonatomic) IBOutlet NSButton * generateSshKeysButton;
@property (weak, nonatomic) IBOutlet NSProgressIndicator * sshKeygenSpinner;
@property (strong, nonatomic) NSMutableArray * publicKeys;

@property (weak, nonatomic) IBOutlet NSCollectionView * bonjourServerList;
@property (weak, nonatomic) IBOutlet NSTextField * rsyncSourceEntry;
@property (strong, nonatomic) IBOutlet NSArrayController * bonjourLibrariesArrayController;
@property (weak, nonatomic) IBOutlet NSMatrix * discoveryModeButtons;
@property (strong, nonatomic) NSMutableArray * bonjourLibraries;

@property (weak, nonatomic) IBOutlet NSTextField * administratorAddressLabel;
@property (weak, nonatomic) IBOutlet NSTextField * libraryNameLabel;
@property (weak, nonatomic) IBOutlet NSButton * emailSendToggle;

@property (weak, nonatomic) IBOutlet PublicKeyDraglet * publicKeyDraglet;
@property (strong, nonatomic) NSTask *sshKeygenTask;

- (id) initWithDelegate: (id<SetupAssistantDelegate>) delegate;

- (IBAction) userDidClickNext: (id) sender;
- (IBAction) userDidClickBack: (id) sender;

- (IBAction) generateSshKeys: (id) sender;

- (IBAction) userDidChangeServerDiscoveryMode: (id) sender;
- (IBAction) userDidChangeRsyncSource: (id) sender;

- (IBAction) openMailTemplate: (id) sender;
- (IBAction) userDidSendEmail: (id) sender;

@end
