//
//  ACPresentationIndex.h
//  ACShell
//
//  Created by Patrick Juchli on 09.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACSearch.h"


/**
 * Creates and maintains an index of documents located in a
 * given folder. Uses Search Kit for indexing, parsing documents and searching.
 */
@interface ACPresentationLibraryIndex : NSObject {
    SKIndexRef  _indexRef;
    SKSearchRef _searchRef;
}

/**
 * Initializes the index for a folder. All later operations will be relative to this folder.
 * Creates an index file in the given folder.
 * @param libraryPath Path to the folder containing all Keynote presentations
 * @returns instance
 */
- (id)initWithPath:(NSString *)libraryPath;

/**
 * Add all files in folder and subfolders of the library path with an extension.
 * @param extension The filename extension, e.g. @"key"
 */
- (void)indexFilesWithExtension:(NSString *)extension;

/**
 * Deletes the index file
 * @param extension The filename extension, e.g. @"key"
 */
- (void)resetIndex;

/**
 * Direct access to the index
 * @returns the instance of SKIndexRef
 */
- (SKIndexRef)index;



- (void)find:(NSString *)query;

@end
