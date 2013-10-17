//
//  PresentationLibrarySearch.h
//  ACShell
//
//  Created by Patrick Juchli on 11.10.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACSearchIndex.h"


typedef void (^PresentationLibrarySearchResultBlock)(NSArray *results);


/**
 Manages a search index for a PresentationLibrary and offers full-text search
 through its associated Keynote presentations.
 */
@interface PresentationLibrarySearch : NSObject

/**
 Constructor
 @param path The library path
 */
- (id)initWithLibraryPath:(NSString *)path;

/**
 Update the index
 */
- (void)updateIndex;

/**
 Async full-text search
 @param query Search Query
 @param maxNumResults The maximum number of results to collect and return
 @param completionBlock A completion block with an NSArray containing all folder names that contain a Keynote 
 presentation that contains the search query. This name corresponds to Presentation.directory. The array is ordered
 by result score.
 */
- (void)searchFullText:(NSString *)query maxNumResults:(int)maxNumResults completion:(PresentationLibrarySearchResultBlock)completionBlock;

@end
