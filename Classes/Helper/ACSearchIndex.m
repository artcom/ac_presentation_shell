//
//  ACSearchIndex.m
//  ACShell
//
//  Created by Patrick Juchli on 25.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ACSearchIndex.h"


// The internal index name used by Search Kit (not the file name of the index)
NSString * const INDEX_NAME = @"DefaultIndex";


@interface ACSearchIndex ()
@property (nonatomic, retain) NSString *indexFilePath;
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (atomic, assign) SKIndexRef indexRef;
@end


@implementation ACSearchIndex

- (void)dealloc {
    if (_indexRef) SKIndexClose(_indexRef);
    [_indexFilePath release];
    [_operationQueue cancelAllOperations];
    [_operationQueue release];
    [super dealloc];
}

- (id)initWithFileBasedIndex:(NSString *)path {
    self = [super init];
    if (self) {
        
        self.indexFilePath = path;
        self.operationQueue = [[NSOperationQueue alloc] init];
        
        // Keep concurrent operation count to 1, that way all operations are enqueued in
        // a serial queue and there won't be any issues with accessing the same resource
        // from different threads. The queue itself will be running as a whole on a
        // separate thread though.
        self.operationQueue.maxConcurrentOperationCount = 1;
        
        SKLoadDefaultExtractorPlugIns();
        [self openIndex];
    }
    return self;
}

- (void)addDocumentAt:(NSString *)path completion:(void (^)())completionBlock {
    
    __block id weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [weakSelf syncAddDocumentAt:path updateIndex:YES];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock();
            });
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

- (void)addDocumentsAt:(NSString *)path withExtension:(NSString *)extension completion:(void (^)(NSInteger))completionBlock {
    
    __block id weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSInteger numDocuments = [weakSelf syncAddDocumentsAt:path withExtension:extension];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(numDocuments);
            });
        }
    }];
    
    [self.operationQueue addOperation:operation];
}


- (ACSearchIndexQuery *)search:(NSString *)query maxNumResults:(int)maxNumResults completion:(ACSearchResultBlock)completion {

    ACSearchIndexQuery *operation = [[ACSearchIndexQuery alloc] initWithQuery:query usingIndex:self.indexRef maxNumResults:maxNumResults];
    [operation setCompletionBlock:^{
        completion(operation.results);
    }];
    
    [self.operationQueue addOperation:operation];
    return operation;
}




// TODO make reset and optimize async because the need to be enqueued


- (void)reset {
    if ([self hasIndex]) {
        [self closeIndex];
        [self removeIndexAtPath:self.indexFilePath];
    }
    self.indexRef = [self createIndexAtPath:self.indexFilePath];
}

- (void)optimize {
    SKIndexCompact(self.indexRef);
}





#pragma mark - Private synchronous methods


- (BOOL)syncAddDocumentAt:(NSString *)path updateIndex:(BOOL)updateIndex {
    
    BOOL documentAdded = false;
    NSURL *url = [NSURL fileURLWithPath:path];
    SKDocumentRef document = SKDocumentCreateWithURL((CFURLRef)url);
    if (document) {
        documentAdded = SKIndexAddDocument(self.indexRef, document, (CFStringRef) NULL, true);
        CFRelease(document);
    }
    
    if (documentAdded && updateIndex) SKIndexFlush(self.indexRef);
    return documentAdded;
}

- (NSInteger)syncAddDocumentsAt:(NSString *)path withExtension:(NSString *)extension {
    
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *filePath;
    NSInteger numFilesAdded = 0;
    while ((filePath = [fileEnumerator nextObject])) {
        
        if ([[filePath pathExtension] isEqualToString:extension]) {
            
            NSString *documentPath = [path stringByAppendingPathComponent:filePath];
            if ([self syncAddDocumentAt:documentPath updateIndex:NO]) {
                ++numFilesAdded;
            }
        }
    }
    
    SKIndexFlush(self.indexRef);
    return numFilesAdded;
}

- (NSInteger)numDocuments {
    return SKIndexGetDocumentCount(_indexRef);
}

- (void)openIndex {
    [self closeIndex];
    if ([self hasIndex]) {
        self.indexRef = [self openIndexAtPath:self.indexFilePath];
    }
    else {
        self.indexRef = [self createIndexAtPath:self.indexFilePath];
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

- (BOOL)hasIndex {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.indexFilePath];
}

@end
