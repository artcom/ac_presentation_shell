//
//  RsyncController.h
//  rsync_controller
//
//  Created by David Siegel on 7/20/10.
//  Copyright 2010 ART+COM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RsyncTask.h"
@class RsyncController;

@protocol RsyncControllerDelegate <NSObject>

- (void)rsync: (RsyncController *)controller didFinishSyncingSuccesful: (BOOL)successFlag; 

@end

@interface RsyncController : NSObject <RsyncTaskDelegate> {
    //NSAlert * alert;
	
	RsyncTask *rsyncTask;
	id <RsyncControllerDelegate> delegate;
    
    NSAlert * currentSheet;
	NSWindow * documentWindow;
    BOOL terminatedByUser;
}

@property (assign) id <RsyncControllerDelegate> delegate;
@property (retain) NSWindow* documentWindow;

- (void) syncWithSource: (NSString*) source destination: (NSString*) destination;
- (void) initialSyncWithSource: (NSString*) source destination: (NSString*) destination;

@end
