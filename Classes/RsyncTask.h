//
//  RsyncTask.h
//  ACShell
//
//  Created by Robert Palmer on 22.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RsyncTask;

@protocol RsyncTaskDelegate <NSObject>

- (void)rsyncTaskDidFinish: (RsyncTask *)task;
- (void)rsyncTask: (RsyncTask *)task didFailWithError: (NSString *)error;
- (void)rsyncTask: (RsyncTask *)task didUpdateProgress: (double)progress;
- (void)rsyncTask: (RsyncTask *)task didUpdateStatusMessage: (NSString *)message;


@end



@interface RsyncTask : NSObject {
	NSTask *task;

	NSPipe *pipe;
	NSPipe *errorPipe;
	
	NSString *source;
	NSString *destination;
	
	NSUInteger targetLibrarySize;
	
	id <RsyncTaskDelegate> delegate;
}

@property (assign) id <RsyncTaskDelegate> delegate;

- (id)initWithSource: (NSString *)source desctination: (NSString *)destination;
- (void)sync;
- (NSUInteger)dryRun;

- (void)terminate;

@end
