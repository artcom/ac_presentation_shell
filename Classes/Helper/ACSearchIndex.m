//
//  ACSearchIndex.m
//  ACShell
//
//  Created by Patrick Juchli on 25.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ACSearchIndex.h"


// The index name used by Search Kit (irrelevant for our case)
NSString * const INDEX_NAME = @"DefaultIndex";


@interface ACSearchIndex ()
@property (nonatomic, readwrite, assign) SKIndexRef indexRef;
@property (nonatomic, retain) NSString *indexFilePath;
@end


@implementation ACSearchIndex


- (void)dealloc {
    if (_indexRef) SKIndexClose(_indexRef);
    [_indexFilePath release];
    [super dealloc];
}

- (id)initWithFileBasedIndex:(NSString *)path {
    self = [super init];
    if (self) {
        self.indexFilePath = path;
        SKLoadDefaultExtractorPlugIns();
        [self openIndex];
    }
    return self;
}

- (BOOL)addDocumentAt:(NSString *)path updateIndex:(BOOL)updateIndex {
    
    BOOL documentAdded = false;
    NSURL *url = [NSURL fileURLWithPath:path];
    SKDocumentRef document = SKDocumentCreateWithURL((CFURLRef)url);
    if (document) {
        documentAdded = SKIndexAddDocument(_indexRef, document, (CFStringRef) NULL, true);
        CFRelease(document);
    }
    
    if (documentAdded && updateIndex) SKIndexFlush(_indexRef);
    return documentAdded;
}

- (NSInteger)addDocumentsAt:(NSString *)path withExtension:(NSString *)extension {
    
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *filePath;
    NSInteger numFilesAdded = 0;
    while ((filePath = [fileEnumerator nextObject])) {
        
        if ([[filePath pathExtension] isEqualToString:extension]) {
            
            NSString *documentPath = [path stringByAppendingPathComponent:filePath];
            if ([self addDocumentAt:documentPath updateIndex:NO]) {
                ++numFilesAdded;
            }
        }
    }
    
    SKIndexFlush(_indexRef);
    return numFilesAdded;
}

- (void)reset {
    if ([self hasIndex]) {
        [self closeIndex];
        [self removeIndexAtPath:self.indexFilePath];
    }
    self.indexRef = [self createIndexAtPath:self.indexFilePath];
}

- (NSInteger)numDocuments {
    return SKIndexGetDocumentCount(_indexRef);
}

- (void)optimize {
    SKIndexCompact(_indexRef);
}


#pragma mark Private


- (void)openIndex {
    [self closeIndex];
    if ([self hasIndex]) {
        SKIndexRef index = [self openIndexAtPath:self.indexFilePath];
        NSLog(@"index : %@", index);
        self.indexRef = index;
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
