//
//  ACShellAppDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferenceController.h"
#import "SetupAssistantController.h"
#import "SetupAssistantDelegateProtocol.h"
#import "ACShellWindowController.h"

@interface ACShellAppDelegate : NSObject <NSApplicationDelegate, SetupAssistantDelegate>
@property (strong) NSWindowController *mainWindowController;
@property (strong) PreferenceController *preferenceController;
@property(strong) SetupAssistantController *setupAssistantController;

- (IBAction)showPreferences:(id)sender;
@end
