//
//  ACSearchIndexQuery.m
//  ACShell
//
//  Created by Patrick Juchli on 27.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ACSearchIndexQuery.h"
#import "ACSearchIndexResult.h"


@interface ACSearchIndexQuery ()
@property (nonatomic, assign) SKIndexRef index;
@property (nonatomic, retain) NSString *query;
@property (nonatomic, assign) int maxNumResults;
@property (nonatomic, readwrite, retain) NSMutableArray *results;
@end


@implementation ACSearchIndexQuery

- (void)dealloc {
    CFRelease(_index);
    [_query release];
    [_results release];
    [super dealloc];
}

- (instancetype)initWithQuery:(NSString *)query usingIndex:(SKIndexRef)index maxNumResults:(int)maxNumResults
{
    self = [super init];
    if (self) {
        self.query = query;
        self.maxNumResults = maxNumResults;
        self.index = index;
        CFRetain(index);
    }
    return self;
}

- (void)main {
    
    if (self.isCancelled) return;
    
    self.results = [[NSMutableArray alloc] init];
    
    SKSearchOptions options = kSKSearchOptionDefault;
    SKSearchRef     search = SKSearchCreate(_index, (CFStringRef)self.query, options);
    
    CFIndex         maxNumResults = self.maxNumResults;
    CFIndex         foundCount = 0;
    SKDocumentID    documentIds[maxNumResults];
    float           scores[maxNumResults];
    SKDocumentRef   documentRefs[maxNumResults];
    BOOL            searchInProgress = YES;

    while (!self.isCancelled && searchInProgress) {
    
        searchInProgress = SKSearchFindMatches(search, maxNumResults, documentIds, scores, 0.5, &foundCount);
        
        SKIndexCopyDocumentRefsForDocumentIDs (_index,
                                               (CFIndex)foundCount,
                                               (SKDocumentID *)documentIds,
                                               (SKDocumentRef *)documentRefs
                                               );
        
        for (CFIndex i = 0; i < foundCount; i++) {
            SKDocumentRef doc = (SKDocumentRef)documentRefs[i];
            ACSearchIndexResult *result = [[ACSearchIndexResult alloc] init];
            result.score = scores[i];
            result.documentUrl = (NSURL *)SKDocumentCopyURL(doc);
            result.documentId = documentIds[i];
            [self.results addObject:result];
            [result release];
        }
    }
}

@end
