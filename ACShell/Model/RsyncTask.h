//
//  RsyncTask.h
//  ACShell
//
//  Created by Robert Palmer on 22.07.10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RsyncTaskDelegate.h"

@interface RsyncTask : NSObject
@property (weak, atomic) id <RsyncTaskDelegate> delegate;
- (id)initWithSource: (NSString *)source destination: (NSString *)destination;
- (void)sync;
- (void)terminate;
@end
