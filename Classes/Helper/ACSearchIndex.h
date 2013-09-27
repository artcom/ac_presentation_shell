//
//  ACSearchIndex.h
//  ACShell
//
//  Created by Patrick Juchli on 25.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>
#import "ACSearchIndexQuery.h"
#import "ACSearchIndexResult.h"


/**
 Asynchronous full-text search using Search Kit
 All method are executed asynchronously but enqueued in a single serial queue, thus calling two methods in direct
 succession is fine. E.g. addDocumentsAt: immediately followed by search: will work as expected, search will
 be executed after addDocumentsAt: has finished.
 Because of this house-keeping this class is opaque and can't hand out a reference to the internally
 used SKIndexRef.
 */


typedef void (^ACSearchResultBlock)(NSArray *results);


@interface ACSearchIndex : NSObject

- (id)initWithFileBasedIndex:(NSString *)path;

/**
 Add a document to the index
 @param path to the document
 @param update the index automatically after the operation
 @param a completion block called after the operation
 */
- (void)addDocumentAt:(NSString *)path completion:(void(^)())completionBlock;;

/**
 Index all documents in a folder and its sub-folders that have a given extension
 @param path to a folder
 @param extenstion to be required
 @param a completion block called after documents have been added
 */
- (void)addDocumentsAt:(NSString *)path withExtension:(NSString *)extension completion:(void(^)(NSInteger numDocuments))completionBlock;

/**
 Searches the index using a query string
 See docs for SKSearchCreate for query string features (phrase searching is enabled):
 https://developer.apple.com/library/mac/documentation/userexperience/Reference/SearchKit/Reference/reference.html#jumpTo_51
 @param a query string
 @param a completion handler with an array of ACSearchIndexResult
 @return a cancelable NSOperation subclass encapsulating the search
 @see ACSearchIndexQuery
 @see ACSearchIndexResult
 */
- (ACSearchIndexQuery *)search:(NSString *)query maxNumResults:(int)maxNumResults completion:(ACSearchResultBlock)completion;



// TODO make async:

- (void)reset;

- (void)optimize;

@end
