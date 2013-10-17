//
//  PresentationLibrarySearch.m
//  ACShell
//
//  Created by Patrick Juchli on 11.10.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "PresentationLibrarySearch.h"


@interface PresentationLibrarySearch ()
@property (nonatomic, retain) ACSearchIndex *searchIndex;
@property (nonatomic, retain) NSString *libraryPath;
@end


@implementation PresentationLibrarySearch


- (void)dealloc
{
    [_libraryPath release];
    [_searchIndex release];
    [super dealloc];
}

- (id)initWithLibraryPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.libraryPath = path;
    }
    return self;
}

- (void)updateIndex {
    
    // TODO update only what changed
    // TODO update when new, changed or deleted presentation
    // TODO when re-indexing, can we just overwrite?
    
    if (self.searchIndex) {
        [self.searchIndex reset];
    }
    else {
//        NSString *indexPath = [self.libraryPath stringByAppendingPathComponent:@"index"];
        self.searchIndex = [[ACSearchIndex alloc] initWithMemoryBasedIndex];
        [_searchIndex release];
    }
    
    // Index all documents
    NSLog(@"indexing keynote presentations..");
    [self.searchIndex addDocumentsAt:self.libraryPath withExtension:@"key" completion:^(NSInteger numDocuments) {
        NSLog(@".. indexed %lu documents", numDocuments);
    }];
}

- (void)searchFullText:(NSString *)query maxNumResults:(int)maxNumResults completion:(PresentationLibrarySearchResultBlock)completionBlock {
    
    [self.searchIndex search:query maxNumResults:maxNumResults completion:^(NSArray *results) {
        
        if (completionBlock) {
            
            //            NSLog(@"==>");
            //            for (ACSearchIndexResult *result in results) {
            //                NSLog(@"-->%@, %f", result.documentUrl, result.score);
            //            }
            
            // Sort results by their score
            NSArray *sortedResults = [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if ([obj1 score] < [obj2 score]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                if ([obj1 score] > [obj2 score]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            // Reduce the search result to a sorted array of presentation directory names
            NSMutableArray *sortedPresentationTitles = [NSMutableArray arrayWithCapacity:sortedResults.count];
            for (ACSearchIndexResult *result in sortedResults) {
                
                NSArray *components = result.documentUrl.pathComponents;
                
                // TODO this is quick'n'dirty, make more reliable aka dynamic
                NSUInteger index = [components indexOfObject:@"demo_library"];
                NSString *folderName = components[index+1];
                
                /**
                 UTF-8 detail:
                 There are different ways of encoding an Umlaut e.g. 'ä' in UTF-8. Either as a single character (composed/NFC) or as a combination
                 of two characters: a + diaeresis (decomposed/NFD). The OSX HFS+ filesystem requires that filenames be stored in UTF-8 and in their
                 fully decomposed form NFD. We will later compare these strings with the property 'directory' of the class Presentation where the
                 strings are stored in NFC which is the normalized form mostly used. NSString isEqualToString: will return false if you compare
                 the same strings in different forms. On the console via NSLog they will appear to be exactly the same.
                 To fix that, we will here at this point convert the string to the normalization form C.
                 Read more here: http://stackoverflow.com/questions/12147410/different-utf-8-signature-for-same-diacritics-umlauts-2-binary-ways-to-write
                 */
                NSString *nfcFolderName = [folderName precomposedStringWithCanonicalMapping];
                [sortedPresentationTitles addObject:nfcFolderName];
            }
            
            completionBlock(sortedPresentationTitles);
        }
    }];
}


@end
