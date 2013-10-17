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


typedef void (^ACSearchResultBlock)(NSArray *results);


/**
 Asynchronous full-text search using Search Kit
 
 All methods are executed asynchronously but enqueued in a single serial queue, thus calling two methods in direct
 succession is fine. E.g. addDocumentsAt: immediately followed by search: will work as expected, search will
 be executed after addDocumentsAt: has finished.
 Because of this house-keeping this class is opaque and can't hand out a reference to the internally
 used SKIndexRef.
 NOTE: Methods have to be called on the main thread.
 */
@interface ACSearchIndex : NSObject

/**
 ACSearchIndex using a file-based index.
 @param path A path where the index file will be saved
 */
- (id)initWithFileBasedIndex:(NSString *)path;

/**
 ACSearchIndex using a memory-based index.
 */
- (id)initWithMemoryBasedIndex;

/**
 Add a document to the index
 @param path File path to the document
 @param completion Block called after the operation
 */
- (void)addDocumentAt:(NSString *)path completion:(void(^)())completionBlock;;

/**
 Index all documents in a folder and its sub-folders that have a given extension
 @param path File path to a folder
 @param extension Method will add all documents using a file @a extension
 @param completion Block called after documents have been added
 */
- (void)addDocumentsAt:(NSString *)path withExtension:(NSString *)extension completion:(void(^)(NSInteger numDocuments))completionBlock;

/**
 Searches the index using a query string
 See docs for SKSearchCreate for query string features (phrase searching is enabled):
 https://developer.apple.com/library/mac/documentation/userexperience/Reference/SearchKit/Reference/reference.html#jumpTo_51
 @param query Query string
 @param maxNumResults The maximum number of results to be collected and returned
 @param completion Block called with an NSArray of ACSearchIndexResult instances
 @return a cancelable NSOperation subclass encapsulating the search
 @see ACSearchIndexQuery
 @see ACSearchIndexResult
 */
- (ACSearchIndexQuery *)search:(NSString *)query maxNumResults:(int)maxNumResults completion:(ACSearchResultBlock)completion;



// TODO make async:

- (void)reset;

- (void)optimize;

@end
