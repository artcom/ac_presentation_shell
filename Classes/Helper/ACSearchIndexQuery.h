//
//  ACSearchIndexQuery.h
//  ACShell
//
//  Created by Patrick Juchli on 27.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACSearchIndexQuery : NSOperation

@property (atomic, readonly, retain) NSMutableArray *results;

- (instancetype)initWithQuery:(NSString *)query usingIndex:(SKIndexRef)index maxNumResults:(int)maxNumResults;

@end
