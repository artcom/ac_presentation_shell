//
//  ACPresentationIndex.m
//  ACShell
//
//  Created by Patrick Juchli on 09.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ACPresentationLibraryIndex.h"


NSString * const INDEX_FILENAME = @"index";  // The physical filename in the library folder
NSString * const INDEX_NAME = @"index";      // The index name used by Search Kit (irrelevant for our case)


@interface ACPresentationLibraryIndex ()
@property (retain) NSString *libraryPath;
@end


// TODO has nothing to do with presentations or keynote, is generic, find generic name

@implementation ACPresentationLibraryIndex

- (void)dealloc {
    [self closeIndex];
    [_libraryPath release];
    [super dealloc];
}

- (id)initWithPath:(NSString *)libraryPath
{
    self = [super init];
    if (self) {
        _indexRef = NULL;
        self.libraryPath = libraryPath;
        SKLoadDefaultExtractorPlugIns();   // TODO Expensive? Needs to be loaded only when creating index, not when querying!
        [self openIndex];
    }
    return self;
}

- (void)resetIndex {
    if ([self hasIndex]) {
        [self closeIndex];
        [self removeIndexAtPath:[self indexPath]];
    }
    _indexRef = [self createIndexAtPath:[self indexPath]];
}

- (SKIndexRef)index {
    return _indexRef;
}

- (void)indexFilesWithExtension:(NSString *)extension {
    
    NSString *libraryPath = [self libraryPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:[self libraryPath]];
    
    NSString *file;
    int counter = 0;
    while ((file = [enumerator nextObject])) {
        if ([[file pathExtension] isEqualToString:extension]) {
            
            NSString *filePath = [libraryPath stringByAppendingPathComponent:file];
            /*BOOL result = */[self addDocumentAtPath:filePath];
            //NSLog(@"---> Result = %d", result);
            ++counter;
            //if (++index > 2) break;
        }
    }
    
    SKIndexFlush(_indexRef);
//    SKIndexCompact(_indexRef);
    CFIndex numDocuments = SKIndexGetDocumentCount(_indexRef);
    NSLog(@"--> num documents %ld vs %d", numDocuments, counter);
    
    
//    SKIndexDocumentIteratorRef docIterator = SKIndexDocumentIteratorCreate(_indexRef, NULL);
//    SKDocumentRef subDocument = SKIndexDocumentIteratorCopyNext(docIterator);
//    while (subDocument) {
//        NSLog(@"aha");
//        CFRelease(subDocument);
//        subDocument = SKIndexDocumentIteratorCopyNext(docIterator);
//    }
//    CFRelease(docIterator);
}



//- (NSArray *)documents:(SKDocumentRef)parentDocument ignoreEmptyDocuments:(BOOL)ignoreEmptyDocuments {
//    
//	NSMutableArray *documents = [NSMutableArray array];
//    
//	SKIndexDocumentIteratorRef docIterator = SKIndexDocumentIteratorCreate(_indexRef, parentDocument);
//    if (docIterator) {
//        SKDocumentRef subDocument = SKIndexDocumentIteratorCopyNext(docIterator);
//        while (subDocument) {
//            CFIndex termCount = 0;
//            SKDocumentID subDocumentId = SKIndexGetDocumentID(_indexRef, subDocument);
//            if ( subDocumentId != kCFNotFound ) termCount = SKIndexGetDocumentTermCount(searchIndex, subDocumentId);
//            
//            if ( !( ignoresEmpty && (termCount == 0) ) ) {
//                
//                CFURLRef subDocumentURL = SKDocumentCopyURL(subDocument);
//                if ( subDocumentURL != NULL ) {
//                    [allDocuments addObject:(NSURL*)subDocumentURL];
//                    CFRelease(subDocumentURL);
//                    subDocumentURL = NULL;
//                }
//            }
//            
//            NSArray *subDocuments = [self _allDocumentsForDocumentRef:subDocument ignoreEmptyDocuments:ignoresEmpty];
//            if ( subDocuments ) [allDocuments addObjectsFromArray:subDocuments];
//            
//            CFRelease(subDocument);
//            subDocument = NULL;
//            
//            subDocument = SKIndexDocumentIteratorCopyNext(docIterator);
//        }
//        
//        CFRelease(docIterator);
//    }
//    
//	return documents;
//}

- (void)find:(NSString *)query
{
    SKSearchOptions options = kSKSearchOptionDefault;
    SKSearchRef search = SKSearchCreate(_indexRef, (CFStringRef)query, options);
    
    CFIndex maxNumResults = 20;
    SKDocumentID    documentIds[maxNumResults];
    float           scores[maxNumResults];
    SKDocumentRef   documentRefs[maxNumResults];
    
    CFIndex foundCount = 0;
    Boolean searchStillRunning = SKSearchFindMatches(search, maxNumResults, documentIds, scores, 1, &foundCount);
    
    
    SKIndexCopyDocumentRefsForDocumentIDs (
                                           _indexRef,
                                           (CFIndex)foundCount,
                                           (SKDocumentID *)documentIds,
                                           (SKDocumentRef *)documentRefs
                                           );
    
    for (CFIndex pos = 0; pos < foundCount; pos++) {
        SKDocumentRef doc = (SKDocumentRef) documentRefs[pos];
        NSURL *url = (NSURL *)SKDocumentCopyURL (doc);
        NSString *urlStr = [url absoluteString];
        NSString *desc = [NSString stringWithFormat:@"DocID: %d, Score: %f, URL: %@",
                    (int) documentIds[pos], scores[pos], urlStr];
        NSLog(@"--> %@", desc);
    }
}

#pragma mark - Manage index

- (void)openIndex {
    [self closeIndex];
    if ([self hasIndex]) {
        _indexRef = [self openIndexAtPath:[self indexPath]];
    }
    else {
        _indexRef = [self createIndexAtPath:[self indexPath]];
    }
}

- (void)closeIndex {
    if (_indexRef) {
        SKIndexClose(_indexRef);
        _indexRef = NULL;
    }
}

- (SKIndexRef)createIndexAtPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSSet *stopWords = [NSSet setWithObjects: @"and", @"the", nil]; // TODO use stopwords?
    NSDictionary *properties = @{
                                 @"kSKStartTermChars" : @"",
                                 @"kSKTermChars" : @"-_@.'",        // TODO how many typographical cases do we have to cover?
                                 @"kSKEndTermChars" : @"",
                                 @"kSKMinTermLength" : @3,
                                 @"kSKStopWords" : stopWords,
                                 @"kSKMaximumTerms" : @0,           // TODO Limit this?
                                 @"kSKProximitySearching" : @1};    // Needed for phrase searching
    
    return SKIndexCreateWithURL((CFURLRef)url, (CFStringRef)INDEX_NAME, kSKIndexInverted, (CFDictionaryRef)properties);
}

- (SKIndexRef)openIndexAtPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    return SKIndexOpenWithURL((CFURLRef)url, (CFStringRef)INDEX_NAME, true);
}

- (void)removeIndexAtPath:(NSString *)path {
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (NSString *)indexPath {
    return [self.libraryPath stringByAppendingPathComponent:INDEX_FILENAME];
}

- (BOOL)hasIndex {
    NSString *path = [self indexPath];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma mark - Manage documents

- (BOOL)addDocumentAtPath:(NSString *)path {
    BOOL result = false;
    if (_indexRef) {
        NSURL *url = [NSURL fileURLWithPath:path];
        SKDocumentRef document = SKDocumentCreateWithURL((CFURLRef)url);
        if (document) {
//            NSLog(@"adding %@, %@", path, document);
            result = SKIndexAddDocument(_indexRef, document, (CFStringRef) NULL, true);
            CFRelease(document);
        }
    }
    return result;
}

//SKIndexFlush(_indexRef);
//
//SKDocumentID docId = SKIndexGetDocumentID(_indexRef, document);
////CFIndex numTerms = SKIndexGetDocumentTermCount(_indexRef, docId);
//CFArrayRef terms = SKIndexCopyTermIDArrayForDocumentID(_indexRef, docId);
//CFIndex numTerms = CFArrayGetCount(terms);
//for (CFIndex i = 0; i < numTerms; ++i) {
//    
//    CFIndex termId;
//    CFNumberGetValue(CFArrayGetValueAtIndex(terms, i), kCFNumberCFIndexType, &termId);
//    
//    NSLog(@"--> %ld", termId);
//    CFStringRef term = SKIndexCopyTermStringForTermID(_indexRef, termId);
//    
//    CFShow(term);
//    NSLog(@"==> %@", term);
//}


@end
