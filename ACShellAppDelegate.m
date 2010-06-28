//
//  ACShellAppDelegate.m
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import "ACShellAppDelegate.h"
#import "PresentationSelectorViewController.h"

@implementation ACShellAppDelegate

@synthesize window;
@synthesize mainView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	presentationSelectorViewController = [[PresentationSelectorViewController alloc] initWithNibName:@"PresentationSelectViewController" bundle:nil];
	presentationSelectorViewController.view.frame = mainView.frame;
	[presentationSelectorViewController.view setFrameOrigin:NSZeroPoint];

	[mainView addSubview:presentationSelectorViewController.view];
}

@end
