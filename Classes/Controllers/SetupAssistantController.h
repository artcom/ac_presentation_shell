//
//  FirstRunAssistantController.h
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//=== SetupAssistantController =================================================

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
    
    NSNetServiceBrowser * bonjourBrowser;
    NSMutableArray * bonjourLibraries;
    NSArrayController * bonjourLibrariesArrayController;
    NSMatrix * discoveryModeButtons;
}

@property (retain, nonatomic) IBOutlet NSTabView * pages;

@property (retain, nonatomic) IBOutlet NSButton * nextButton;
@property (retain, nonatomic) IBOutlet NSButton * backButton;

@property (retain, nonatomic) IBOutlet NSArrayController * publicKeyArrayController;
@property (retain, nonatomic) IBOutlet NSTableView * publicKeyTable;
@property (retain, nonatomic) IBOutlet NSButton * generateSshKeysButton;
@property (retain, nonatomic) IBOutlet NSProgressIndicator * sshKeygenSpinner;
@property (retain, nonatomic) NSMutableArray * publicKeys;

@property (retain, nonatomic) IBOutlet NSCollectionView * bonjourServerList;
@property (retain, nonatomic) IBOutlet NSTextField * rsyncSourceEntry;
@property (retain, nonatomic) IBOutlet NSArrayController * bonjourLibrariesArrayController;
@property (retain, nonatomic) IBOutlet NSMatrix * discoveryModeButtons;
@property (retain, nonatomic) NSMutableArray * bonjourLibraries;



- (IBAction) userDidClickNext: (id) sender;
- (IBAction) userDidClickBack: (id) sender;

- (IBAction) generateSshKeys: (id) sender;

- (IBAction) userDidChangeServerDiscoveryMode: (id) sender;
- (IBAction) userDidChangeRsyncSource: (id) sender;

@end
