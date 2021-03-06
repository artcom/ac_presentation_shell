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
- (void)rsyncTask: (RsyncTask *)task didUpdateProgress: (double)fileProgress
       itemNumber: (NSInteger) itemNumber
               of: (NSInteger) itemCount;
- (void)rsyncTask: (RsyncTask *)task didUpdateMessage: (NSString *)name;

@end

@interface RsyncTask : NSObject

@property (weak, atomic) id <RsyncTaskDelegate> delegate;

- (id)initWithSource: (NSString *)source destination: (NSString *)destination;
- (void)sync;

- (void)terminate;

@end
