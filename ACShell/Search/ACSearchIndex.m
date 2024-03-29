//
//  ACSearchIndex.m
//  ACShell
//
//  Created by Patrick Juchli on 25.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ACSearchIndex.h"


// The internal index name used by Search Kit
NSString * const INDEX_NAME = @"DefaultIndex";


@interface ACSearchIndex ()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) NSMutableData *indexData;
@property (atomic, assign) SKIndexRef indexRef;
@end


@implementation ACSearchIndex

- (void)dealloc {
    [_operationQueue cancelAllOperations];
    if (_indexRef) SKIndexClose(_indexRef);
}

- (id)init {
    self = [super init];
    if (self) {
        self.operationQueue = NSOperationQueue.new;
        self.operationQueue.maxConcurrentOperationCount = 1;
        
        SKLoadDefaultExtractorPlugIns();
        [self openIndex];
    }
    return self;
}

- (void)addDocumentsAt:(NSString *)path withExtension:(NSString *)extension completion:(void (^)(NSInteger))completionBlock {
    __weak ACSearchIndex *weakSelf = self;
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
    ACSearchIndexQuery *operation = [[ACSearchIndexQuery alloc] initWithQuery:query
                                                                   usingIndex:self.indexRef
                                                                maxNumResults:maxNumResults];
    __weak ACSearchIndexQuery *weakOperationRef = operation;
    [operation setCompletionBlock:^{
        NSArray *results = [[weakOperationRef results] copy];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(results);
        });
    }];
    [self.operationQueue addOperation:operation];
    return operation;
}


#pragma mark - Private synchronous methods


- (BOOL)syncAddDocumentAt:(NSString *)path updateIndex:(BOOL)updateIndex {
    
    BOOL documentAdded = false;
    NSURL *url = [NSURL fileURLWithPath:path];
    SKDocumentRef document = SKDocumentCreateWithURL((__bridge CFURLRef)url);
    if (document) {
        documentAdded = SKIndexAddDocument(self.indexRef, document, (CFStringRef) NULL, true);
        CFRelease(document);
    }
    if (documentAdded && updateIndex) {
        SKIndexFlush(self.indexRef);
    }
    return documentAdded;
}

- (NSInteger)syncAddDocumentsAt:(NSString *)path withExtension:(NSString *)extension {
    
    NSFileManager *fileManager = NSFileManager.defaultManager;
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:path];
    NSString *filePath;
    NSInteger numFilesAdded = 0;
    while ((filePath = [fileEnumerator nextObject])) {
        BOOL ignore = [filePath.lastPathComponent hasPrefix:@"."];
        if (!ignore && [filePath.pathExtension isEqualToString:extension]) {
            NSString *documentPath = [path stringByAppendingPathComponent:filePath];
            if ([self syncAddDocumentAt:documentPath updateIndex:NO]) {
                ++numFilesAdded;
            }
        }
    }
    SKIndexFlush(self.indexRef);
    return numFilesAdded;
}


#pragma mark - Index management


- (void)openIndex {
    [self closeIndex];
    self.indexRef = [self createIndex];
}

- (void)closeIndex {
    if (self.indexRef) {
        SKIndexClose(self.indexRef);
        self.indexRef = NULL;
    }
}

- (SKIndexRef)createIndex {
    
    NSSet *stopWords = [NSSet setWithObjects: @"and", @"the", @"was", nil];
    NSDictionary *properties = @{
        @"kSKStartTermChars" : @"",
        @"kSKTermChars" : @"-_@./'",
        @"kSKEndTermChars" : @"",
        @"kSKMinTermLength" : @3,
        @"kSKStopWords" : stopWords,
        @"kSKMaximumTerms" : @0,
        @"kSKProximitySearching" : @1};
    
    SKIndexRef index;
    NSMutableData *data = NSMutableData.new;
    index = SKIndexCreateWithMutableData((__bridge CFMutableDataRef)data, (__bridge CFStringRef)INDEX_NAME, kSKIndexInverted, (__bridge CFDictionaryRef)properties);
    self.indexData = data;
    return index;
}

@end
