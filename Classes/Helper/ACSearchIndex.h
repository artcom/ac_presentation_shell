//
//  ACSearchIndex.h
//  ACShell
//
//  Created by Patrick Juchli on 25.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

@interface ACSearchIndex : NSObject

@property (nonatomic, readonly, assign) SKIndexRef indexRef;


- (id)initWithFileBasedIndex:(NSString *)path;


/**
 Add a document to the index
 @param path to the document
 @param update the index automatically after the operation or not
 @return whether adding was successful
 */
- (BOOL)addDocumentAt:(NSString *)path updateIndex:(BOOL)updateIndex;


/**
 Index all documents in a folder and its sub-folders that have a given extension
 @param path to a folder
 @param extenstion to be required
 @return number of successfully added documents
 */
- (NSInteger)addDocumentsAt:(NSString *)path withExtension:(NSString *)extension;


/**
 @return the number of documents in the index
 */
- (NSInteger)numDocuments;


/**
 Deletes the existing index file and creates a new empty one.
 */
- (void)reset;

- (void)optimize;

@end
