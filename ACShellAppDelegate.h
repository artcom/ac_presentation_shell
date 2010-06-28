//
//  ACShellAppDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PresentationSelectorViewController;

@interface ACShellAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSView *mainView;
	
	PresentationSelectorViewController *presentationSelectorViewController;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *mainView;

@end
