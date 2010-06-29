//
//  ACShellAppDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ACShellAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSView *mainView;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *mainView;

- (NSString *)findSystemFolderType:(int)folderType forDomain:(int)domain;
- (NSString *)applicationSupportDirectoryInUserDomain;


@end
