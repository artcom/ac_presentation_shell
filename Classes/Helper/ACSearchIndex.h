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


/**
 Asynchronous full-text search using Search Kit
 */

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


- (ACSearchIndexQuery *)search:(NSString *)query completion:(void(^)(NSArray *results))completion;


/**
 Deletes the existing index file and creates a new empty one.
 */
- (void)reset;

- (void)optimize;

@end
