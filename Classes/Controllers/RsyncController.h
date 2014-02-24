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
	RsyncTask *rsyncTask;    
    NSAlert *currentSheet;
    BOOL terminatedByUser;
    NSString *lastRsyncMessage;
    BOOL isUploading;
}

@property (weak) id <RsyncControllerDelegate> delegate;
@property (strong) NSWindow* documentWindow;

@property (strong, nonatomic) IBOutlet NSView * progressView;
@property (weak, nonatomic) IBOutlet NSProgressIndicator * fileProgressBar;
@property (weak, nonatomic) IBOutlet NSTextField * fileProgressLabel;
@property (weak, nonatomic) IBOutlet NSProgressIndicator * totalProgressBar;
@property (weak, nonatomic) IBOutlet NSTextField * totalProgressLabel;

- (void) syncWithSource: (NSString*) source destination: (NSString*) destination;
- (void) initialSyncWithSource: (NSString*) source destination: (NSString*) destination;

- (void) uploadWithSource: (NSString*) source destination: (NSString*) destination;
@end
