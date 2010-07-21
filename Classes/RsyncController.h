//
//  RsyncController.h
//  rsync_controller
//
//  Created by David Siegel on 7/20/10.
//  Copyright 2010 ART+COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RsyncController;

@protocol RsyncControllerDelegate

- (void)rsync: (RsyncController *)controller didFinishSyncingSuccesful: (BOOL)successFlag; 

@end

@interface RsyncController : NSObject {
    NSString * source;
    NSString * destination;
    
    NSAlert * alert;
    NSTask  * rsyncTask;
    NSPipe * pipe;
    NSUInteger targetLibrarySize;
	NSWindow * sheetOwningWindow;
	
	id <RsyncControllerDelegate> delegate;
}

@property (assign) id <RsyncControllerDelegate> delegate;

- (id) initWithSource:(NSString *)sourceDir destination:(NSString*)destinationDir;
- (void) sync: (NSWindow *) sheetWindow;

@end
