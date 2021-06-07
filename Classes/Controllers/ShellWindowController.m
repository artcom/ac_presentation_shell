//
//  ShellWindowController.m
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import "ShellWindowController.h"
#import "ACShellAppDelegate.h"

@interface ShellWindowController ()

@end

@implementation ShellWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)toggleSidebar:(id)sender
{
    
    NSSplitViewController *splitViewController = (NSSplitViewController *)self.contentViewController;
    [splitViewController toggleSidebar:nil];
}

- (IBAction)play:(id)sender
{
    [self.shellController play:nil];
}

- (IBAction)sync:(id)sender
{
    [self.shellController sync:nil];
}

- (IBAction)upload:(id)sender
{
    [self.shellController upload:nil];
}

- (ACShellController *)shellController
{
    return ((ACShellAppDelegate *)[[NSApplication sharedApplication] delegate]).shellController;
}

@end
