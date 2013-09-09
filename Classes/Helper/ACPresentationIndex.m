//
//  ACPresentationIndex.m
//  ACShell
//
//  Created by patrick on 09.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ACPresentationIndex.h"

/**
 * Creates and maintains index of keynote presentations located in a 
 * given folder. Uses Search Kit for indexing, parsing Keynote files and searching.
 */

NSString * const INDEX_FILENAME = @"index";  // The physical filename in the library folder
NSString * const INDEX_NAME = @"index";      // The index name used by Search Kit (irrelevant for our case)


@interface ACPresentationIndex ()
@property (retain) NSString *libraryPath;
@end


@implementation ACPresentationIndex

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
        SKLoadDefaultExtractorPlugIns();       // TODO Expensive?
    }
    return self;
}

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

- (void)resetIndex {
    if ([self hasIndex]) {
        [self closeIndex];
        [self removeIndexAtPath:[self indexPath]];
    }
    _indexRef = [self createIndexAtPath:[self indexPath]];
}

- (SKIndexRef)skIndexRef {
    return _indexRef;
}

#pragma mark - Private


- (SKIndexRef)createIndexAtPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    SKIndexType indexType = kSKIndexInverted;
    NSSet *stopWords = [NSSet setWithObjects: @"and", @"the", nil]; // TODO use stopwords?
    NSDictionary *properties = @{
                                 @"kSKStartTermChars" : @"",
                                 @"kSKTermChars" : @"-_@.'",        // TODO how many typographical cases do we have to cover?
                                 @"kSKEndTermChars" : @"",
                                 @"kSKMinTermLength" : @3,
                                 @"kSKStopWords" : stopWords,
                                 @"kSKMaximumTerms" : @0,           // TODO Limit this?
                                 @"kSKProximitySearching" : @1};    // Needed for phrase searching
                                 
    return SKIndexCreateWithURL((CFURLRef)url, (CFStringRef)INDEX_NAME, indexType, (CFDictionaryRef)properties);
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




@end
