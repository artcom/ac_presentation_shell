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
@property (nonatomic, retain) NSOperationQueue *operationQueue;
@property (atomic, assign) SKIndexRef indexRef;
@property (nonatomic, retain) NSMutableData *indexData;
@property (nonatomic, retain) NSString *indexFilePath;
@end


@implementation ACSearchIndex

- (void)dealloc {
    if (_indexRef) SKIndexClose(_indexRef);
    [_indexFilePath release];
    [_indexData release];
    [_operationQueue cancelAllOperations];
    [_operationQueue release];
    [super dealloc];
}

- (id)initWithFileBasedIndex:(NSString *)path {
    self = [self init];
    if (self) {
        self.indexFilePath = path;
    }
    return self;
}

- (id)initWithMemoryBasedIndex {
    self = [self init];
    if (self) {
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
        // Keep concurrent operation count to 1, that way all operations are enqueued in
        // a serial queue and there won't be any issues with accessing the same resource
        // from different threads. The queue itself will be running as a whole on a
        // separate thread though.
        self.operationQueue = [[NSOperationQueue alloc] init];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(operation.results);
        });
    }];
    
    [self.operationQueue addOperation:operation];
    return operation;
}


// TODO make reset and optimize async because the need to be enqueued


- (void)reset {
    [self closeIndex];
    if ([self hasIndexFile]) {
        [self removeIndexFileAtPath:self.indexFilePath];
    }
    self.indexRef = [self createIndex];
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


#pragma mark - Index management


- (void)openIndex {
    [self closeIndex];
    if ([self hasIndexFile]) {
        self.indexRef = [self openIndexFileAtPath:self.indexFilePath];
    }
    else {
        self.indexRef = [self createIndex];
    }
}

- (void)closeIndex {
    if (_indexRef) {
        SKIndexClose(_indexRef);
        _indexRef = NULL;
    }
}

- (SKIndexRef)createIndex {
    
    NSSet *stopWords = [NSSet setWithObjects: @"and", @"the", nil]; // TODO use stopwords?
    NSDictionary *properties = @{
                                 @"kSKStartTermChars" : @"",
                                 @"kSKTermChars" : @"-_@.'",        // TODO how many typographical cases do we have to cover?
                                 @"kSKEndTermChars" : @"",
                                 @"kSKMinTermLength" : @3,
                                 @"kSKStopWords" : stopWords,
                                 @"kSKMaximumTerms" : @0,           // TODO Limit this?
                                 @"kSKProximitySearching" : @1};    // Needed for phrase searching
    
    // File-based index
    SKIndexRef index;
    if (self.indexFilePath) {
        NSURL *url = [NSURL fileURLWithPath:self.indexFilePath];
        index = SKIndexCreateWithURL((CFURLRef)url, (CFStringRef)INDEX_NAME, kSKIndexInverted, (CFDictionaryRef)properties);
    }
    
    // Memory-based index
    else {
        NSMutableData *data = [[NSMutableData alloc] init];
        index = SKIndexCreateWithMutableData((CFMutableDataRef)data, (CFStringRef)INDEX_NAME, kSKIndexInverted, (CFDictionaryRef)properties);
        self.indexData = data;
        [data release];
    }

    return index;
}


#pragma mark - File-based index management


- (SKIndexRef)openIndexFileAtPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    return SKIndexOpenWithURL((CFURLRef)url, (CFStringRef)INDEX_NAME, true);
}

- (void)removeIndexFileAtPath:(NSString *)path {
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (BOOL)hasIndexFile {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.indexFilePath];
}

@end
