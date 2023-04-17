//
//  RsyncTaskDelegate.h
//  ACShell
//
//  Created by Julian Krumow on 09.04.23.
//  Copyright © 2023 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class RsyncTask;
@protocol RsyncTaskDelegate <NSObject>
- (void)rsyncTaskDidFinish: (RsyncTask *)task;
- (void)rsyncTask: (RsyncTask *)task didFailWithError: (NSString *)error;
- (void)rsyncTask: (RsyncTask *)task didUpdateProgress: (double)fileProgress
       itemNumber: (NSInteger) itemNumber
               of: (NSInteger) itemCount;
- (void)rsyncTask: (RsyncTask *)task didUpdateMessage: (NSString *)name;
@end

NS_ASSUME_NONNULL_END
