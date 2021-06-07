//
//  ShellWindowController.h
//  ACShell
//
//  Created by Julian Krumow on 07.06.21.
//  Copyright © 2021 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACShellController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShellWindowController : NSWindowController

- (IBAction)toggleSidebar:(id)sender;
- (IBAction)play:(id)sender;
- (IBAction)sync:(id)sender;
- (IBAction)upload:(id)sender;
@end

NS_ASSUME_NONNULL_END
