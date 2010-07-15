//
//  ACShellAppDelegate.h
//  ACShell
//
//  Created by Robert Palmer on 28.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ACShellController;

@interface ACShellAppDelegate : NSObject <NSApplicationDelegate> {
	ACShellController *shellController;
}

@property (retain) IBOutlet ACShellController *shellController;

@end
