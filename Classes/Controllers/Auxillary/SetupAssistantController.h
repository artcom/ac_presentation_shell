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
    
    NSInteger numPages;
    NSMutableArray *publicKeys;
    BOOL bonjourBrowserRunning;
    NSNetServiceBrowser *bonjourBrowser;
    NSMutableArray *bonjourLibraries;
    NSArrayController *bonjourLibrariesArrayController;
    
    id<SetupAssistantDelegate> delegate;
}

@property (weak, nonatomic) IBOutlet NSTabView * pages;

@property (weak, nonatomic) IBOutlet NSButton * nextButton;
@property (weak, nonatomic) IBOutlet NSButton * backButton;

@property (strong, nonatomic) IBOutlet NSArrayController * publicKeyArrayController;
@property (weak, nonatomic) IBOutlet NSTableView * publicKeyTable;
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

- (id) initWithDelegate: (id<SetupAssistantDelegate>) delegate;

- (IBAction) userDidClickNext: (id) sender;
- (IBAction) userDidClickBack: (id) sender;

- (IBAction) userDidChangeServerDiscoveryMode: (id) sender;
- (IBAction) userDidChangeRsyncSource: (id) sender;

- (IBAction) openMailTemplate: (id) sender;
- (IBAction) userDidSendEmail: (id) sender;

@end
