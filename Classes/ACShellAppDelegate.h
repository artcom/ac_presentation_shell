//
//  ACShellAppDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ACShellController;

@interface ACShellAppDelegate : NSObject <NSApplicationDelegate>

@property (strong) IBOutlet ACShellController *shellController;

@end
