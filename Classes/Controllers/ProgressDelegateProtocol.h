//
//  ProgressDelegateProtocol.h
//  ACShell
//
//  Created by David Siegel on 8/8/10.
//  Copyright 2010 ART+COM AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol ProgressDelegateProtocol

- (void) setMessage: (NSString*) message;
- (void) setProgress: (double) percent text: (NSString*) text;
- (void) operationDidFinish;

@end
