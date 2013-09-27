//
//  ACSearchIndexQuery.m
//  ACShell
//
//  Created by Patrick Juchli on 27.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ACSearchIndexQuery.h"


@interface ACSearchIndexQuery ()
@property (nonatomic, assign) BOOL executing;
@property (nonatomic, assign) BOOL finished;
@end


@implementation ACSearchIndexQuery

- (instancetype)initWithQuery:(NSString *)queryString usingIndex:(SKIndexRef)index
{
    self = [super init];
    if (self) {
        _executing = NO;
        _finished = NO;
    }
    return self;
}

- (void)main {
    if (self.isCancelled) {
        self.finished = YES;
        return;
    }
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)completeOperation {
    self.executing = NO;
    self.finished = YES;
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isExecuting {
    return _executing;
}

@end
