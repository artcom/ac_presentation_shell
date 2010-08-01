//
//  FirstRunAssistantController.h
//  ACShell
//
//  Created by David Siegel on 8/1/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SetupAssistantController : NSWindowController <NSTabViewDelegate> {
    
    NSTabView * pages;
    
    NSButton * nextButton;
    NSButton * backButton;
    
    NSInteger numPages;
    
    NSArrayController * publicKeyArrayController;
    NSMutableArray * publicKeys;
    NSTableView * publicKeyTable;
    NSButton * generateSshKeysButton;
    NSProgressIndicator * sshKeygenSpinner;
}

@property (retain, nonatomic) IBOutlet NSTabView * pages;

@property (retain, nonatomic) IBOutlet NSButton * nextButton;
@property (retain, nonatomic) IBOutlet NSButton * backButton;
@property (retain, nonatomic) IBOutlet NSArrayController * publicKeyArrayController;
@property (retain, nonatomic) IBOutlet NSTableView * publicKeyTable;
@property (retain, nonatomic) IBOutlet NSButton * generateSshKeysButton;
@property (retain, nonatomic) IBOutlet NSProgressIndicator * sshKeygenSpinner;

- (IBAction) userDidClickNext: (id) sender;
- (IBAction) userDidClickBack: (id) sender;

- (IBAction) generateSshKeys: (id) sender;

@end
